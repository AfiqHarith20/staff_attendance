import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:staff_attendance/api/api_client.dart';
import 'package:staff_attendance/apps/routes/api_routes.dart';
import 'package:staff_attendance/widgets/app_toast.dart';

import '../../models/attendance_history_model.dart';
import '../../models/document_model.dart';
import '../team_attendance_controller/team_attendance_controller.dart';

// ── Check-in status states ──
enum CheckInStatus {
  idle,
  locating,
  ready, // GPS fix obtained — ready to check in/out
  success,
  alreadyIn,
  error,
  inRange,
}

// ── Weekly log day entry ──
class WeekDayEntry {
  final DateTime date;
  final AttendanceRecordModel? record;

  const WeekDayEntry({required this.date, this.record});

  bool get isToday {
    final n = DateTime.now();
    return date.year == n.year && date.month == n.month && date.day == n.day;
  }

  bool get isFuture {
    final n = DateTime.now();
    return DateTime(date.year, date.month, date.day)
        .isAfter(DateTime(n.year, n.month, n.day));
  }

  bool get hasRecord => record != null;
}

// ── Today log entry ──
class AttendanceLog {
  final String type; // 'checkin' | 'checkout'
  final DateTime time;
  final double distanceM;
  final bool inRange;

  const AttendanceLog({
    required this.type,
    required this.time,
    required this.distanceM,
    required this.inRange,
  });

  factory AttendanceLog.fromJson(Map<String, dynamic> j) => AttendanceLog(
    type: j['type'] as String,
    time: DateTime.parse(j['timestamp'] as String).toLocal(),
    distanceM: (j['distance_m'] as num).toDouble(),
    inRange: j['in_range'] as bool,
  );

  String get timeFormatted => DateFormat('h:mm a').format(time);
  String get distanceFormatted =>
      '${distanceM.toStringAsFixed(0)}m from office';
}

class ScanController extends GetxController {
  final _geocoding = Geocoding();

  // ── Office config (normally fetched from API/storage) ──
  static const double _officeLat =
      2.9274494639052575; // 🔧 replace with your office lat
  static const double _officeLng =
      101.66256264406454; // 🔧 replace with your office lng
  static const double _radiusM = 150.0; // allowed radius in metres

  // ── Tab ──
  final tabIndex = 0.obs;

  // ── Geo state ──
  final checkInStatus = CheckInStatus.idle.obs;
  final currentLat = 0.0.obs;
  final currentLng = 0.0.obs;
  final distanceM = 0.0.obs;
  final locationError = ''.obs;
  final isCheckingIn = false.obs;
  final checkInMessage = ''.obs;

  // ── Today check-in flag ──
  final checkedInToday = false.obs;

  // If true, operate in mock mode (no API calls) — useful for local testing
  final mockMode = false.obs;

  // ── Today logs ──
  final todayLogs = <AttendanceLog>[].obs;
  final isLoadingLogs = false.obs;

  // ── Weekly log ──
  final weeklyLog = <WeekDayEntry>[].obs;
  final isWeeklyLogLoading = false.obs;

  // ── Documents ──
  final documents = <DocumentModel>[].obs;
  final isLoadingDocs = false.obs;
  final isUploading = false.obs;
  final uploadError = ''.obs;
  final selectedType = DocumentType.medical.obs;

  // ── Resolved address from reverse geocoding ──
  final locationName = Rxn<String>();

  // ── Live location stream ──
  StreamSubscription<Position>? _locationStream;

  /// True when GPS has a fix and check-in/out can proceed.
  bool get isInRange =>
      checkInStatus.value == CheckInStatus.ready ||
      checkInStatus.value == CheckInStatus.success ||
      checkInStatus.value == CheckInStatus.alreadyIn;

  DateTime get weekStart {
    final today = DateTime.now();
    return DateTime(today.year, today.month, today.day - (today.weekday - 1));
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Refreshes TeamAttendanceController if it is already registered (i.e. the
  /// team screen has been opened this session). This keeps the team list in
  /// sync whenever anyone — staff or admin/HR — checks in or out.
  void _refreshTeamIfActive() {
    if (Get.isRegistered<TeamAttendanceController>()) {
      Get.find<TeamAttendanceController>().fetchTeam();
    }
  }

  @override
  void onInit() {
    super.onInit();
    try {
      final mockStored = GetStorage().read<bool>('mock_mode');
      if (mockStored != null) mockMode(mockStored);
    } catch (_) {}
    _checkTodayStatus();
    _startLocationTracking();
    fetchDocuments();
    fetchTodayLogs();
    fetchWeeklyLog();
  }

  void setMockMode(bool v) {
    mockMode(v);
    try {
      GetStorage().write('mock_mode', v);
    } catch (_) {}
  }

  // ─────────────────────────────────────
  // LOCATION
  // ─────────────────────────────────────
  Future<void> _startLocationTracking() async {
    // Cancel any existing subscription before starting a new one (BUG-06: stream leak on retry).
    await _locationStream?.cancel();
    _locationStream = null;
    checkInStatus(CheckInStatus.locating);
    locationError('');

    // 1. Check if location service enabled
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      locationError('Location service is disabled. Please enable GPS.');
      checkInStatus(CheckInStatus.error);
      return;
    }

    // 2. Check / request permission
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      locationError(
        perm == LocationPermission.deniedForever
            ? 'Location permission permanently denied. Enable in Settings.'
            : 'Location permission denied.',
      );
      checkInStatus(CheckInStatus.error);
      return;
    }

    // 3. Get initial position quickly
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      _updatePosition(pos);
    } catch (_) {
      // non-fatal — stream will update shortly
    }

    // 4. Subscribe to live updates every 5 seconds
    _locationStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 5, // update every 5m movement
          ),
        ).listen(
          _updatePosition,
          onError: (_) {
            locationError('Unable to get location. Check GPS signal.');
            checkInStatus(CheckInStatus.error);
          },
        );
  }

  void _updatePosition(Position pos) {
    currentLat(pos.latitude);
    currentLng(pos.longitude);

    final dist = _haversineDistance(
      pos.latitude,
      pos.longitude,
      _officeLat,
      _officeLng,
    );
    distanceM(dist);

    // Mark GPS as ready (unless a terminal state like success/alreadyIn is set)
    if (checkInStatus.value != CheckInStatus.success &&
        checkInStatus.value != CheckInStatus.alreadyIn) {
      checkInStatus(CheckInStatus.ready);
    }

    _resolveLocationName(pos.latitude, pos.longitude);
  }

  Future<void> _resolveLocationName(double lat, double lng) async {
    try {
      final placemarks = await _geocoding.placemarkFromCoordinates(lat, lng);
      if (placemarks.isEmpty) return;
      final p = placemarks.first;
      final parts = <String>[
        if ((p.street ?? '').isNotEmpty) p.street!,
        if ((p.subLocality ?? '').isNotEmpty) p.subLocality!,
        if ((p.locality ?? '').isNotEmpty) p.locality!,
      ];
      if (parts.isNotEmpty) locationName(parts.join(', '));
    } catch (_) {
      // Non-fatal — server will fall back to office name
    }
  }

  // Haversine formula — accurate distance in metres
  double _haversineDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const r = 6371000.0; // Earth radius metres
    final dLat = _deg2rad(lat2 - lat1);
    final dLng = _deg2rad(lng2 - lng1);
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  double _deg2rad(double deg) => deg * pi / 180;

  Future<void> retryLocation() => _startLocationTracking();

  // ─────────────────────────────────────
  // CHECK-IN
  // ─────────────────────────────────────
  /// Gets a fresh GPS fix at the moment of check-in/out.
  /// Falls back to the last known stream value if GPS times out.
  Future<({double lat, double lng})> _getFreshPosition() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );
      _updatePosition(pos);
      return (lat: pos.latitude, lng: pos.longitude);
    } catch (_) {
      return (lat: currentLat.value, lng: currentLng.value);
    }
  }

  Future<void> checkIn() async {
    debugPrint(
      'CHECKIN: called | isCheckingIn=${isCheckingIn.value} | status=${checkInStatus.value} | lat=${currentLat.value} | lng=${currentLng.value}',
    );
    if (isCheckingIn.value) return;

    try {
      isCheckingIn(true);
      checkInMessage('');

      if (mockMode.value) {
        // Simulate successful check-in
        final today = DateTime.now();
        GetStorage().write(
          _checkinKey,
          '${today.year}-${today.month}-${today.day}',
        );
        checkedInToday(true);
        checkInStatus(CheckInStatus.success);
        checkInMessage('Check-in (mock)');
        final actualInRange = distanceM.value <= _radiusM;
        todayLogs.insert(
          0,
          AttendanceLog(
            type: 'checkin',
            time: DateTime.now(),
            distanceM: distanceM.value,
            inRange: actualInRange,
          ),
        );
        fetchWeeklyLog();
        _refreshTeamIfActive();
        AppToast.success(
          'Check-in (mock)',
          '${distanceM.value.toStringAsFixed(0)}m dari pejabat',
        );
        return;
      }

      // Capture device time and fresh GPS before the network call.
      final checkedAt = DateTime.now().toIso8601String();
      final pos = await _getFreshPosition();

      final response = await ApiClient.instance.post(
        ApiList.checkIn,
        data: {
          'latitude': pos.lat,
          'longitude': pos.lng,
          'checked_at': checkedAt,
          if (locationName.value != null) 'location_name': locationName.value,
        },
      );

      // Successful response: mark checked-in and persist
      final respMsg = response.data is Map
          ? response.data['message'] as String?
          : null;
      final now = DateTime.now();
      GetStorage().write(
        _checkinKey,
        '${now.year}-${now.month}-${now.day}',
      );
      checkedInToday(true);
      checkInStatus(CheckInStatus.success);
      checkInMessage(respMsg ?? 'Check-in successful');
      final actualInRange = pos.lat != 0 && pos.lng != 0
          ? _haversineDistance(pos.lat, pos.lng, _officeLat, _officeLng) <=
                _radiusM
          : distanceM.value <= _radiusM;
      todayLogs.insert(
        0,
        AttendanceLog(
          type: 'checkin',
          time: now,
          distanceM: _haversineDistance(
            pos.lat,
            pos.lng,
            _officeLat,
            _officeLng,
          ),
          inRange: actualInRange,
        ),
      );
      fetchWeeklyLog();
      _refreshTeamIfActive();
      AppToast.success('Check-in', respMsg ?? 'Checked in');
    } on DioException catch (e) {
      debugPrint(
        'CHECKIN DioException: ${e.type} | ${e.message} | ${e.response?.statusCode} | ${e.response?.data}',
      );
      final errMsg = e.response?.data != null
          ? e.response?.data['message'] as String?
          : null;
      if (errMsg != null && errMsg.toLowerCase().contains('already')) {
        checkedInToday(true);
        checkInStatus(CheckInStatus.alreadyIn);
        checkInMessage(errMsg);
      } else {
        checkInStatus(CheckInStatus.ready);
        AppToast.failed('Check-in failed', errMsg ?? 'Please try again');
      }
    } catch (e, st) {
      debugPrint('CHECKIN error: $e\n$st');
      checkInStatus(CheckInStatus.ready);
      AppToast.failed('Error', 'Unexpected error. Please try again.');
    } finally {
      isCheckingIn(false);
    }
  }

  // ─────────────────────────────────────
  // CHECK-OUT
  // ─────────────────────────────────────
  Future<void> checkOut() async {
    // Prevent check-out if a check-in hasn't happened yet.
    if (!checkedInToday.value) {
      AppToast.pending(
        'Check-in required',
        'Please check in before checking out.',
      );
      return;
    }

    if (isCheckingIn.value) return;

    try {
      isCheckingIn(true);
      if (mockMode.value) {
        // simulate checkout locally
        GetStorage().remove(_checkinKey);
        checkedInToday(false);
        checkInStatus(CheckInStatus.idle);
        final actualInRange = distanceM.value <= _radiusM;
        todayLogs.insert(
          0,
          AttendanceLog(
            type: 'checkout',
            time: DateTime.now(),
            distanceM: distanceM.value,
            inRange: actualInRange,
          ),
        );
        fetchWeeklyLog();
        _refreshTeamIfActive();
        AppToast.success('Check-out (mock)', 'Checked out (mock)');
        return;
      }

      // Capture device time and fresh GPS before the network call.
      final checkedAt = DateTime.now().toIso8601String();
      final pos = await _getFreshPosition();

      final response = await ApiClient.instance.post(
        ApiList.checkOut,
        data: {
          'latitude': pos.lat,
          'longitude': pos.lng,
          'checked_at': checkedAt,
          if (locationName.value != null) 'location_name': locationName.value,
        },
      );

      final respMsg = response.data is Map
          ? response.data['message'] as String?
          : null;
      // mark checkout locally
      GetStorage().remove(_checkinKey);
      checkedInToday(false);
      checkInStatus(CheckInStatus.idle);
      final actualInRange = distanceM.value <= _radiusM;
      todayLogs.insert(
        0,
        AttendanceLog(
          type: 'checkout',
          time: DateTime.now(),
          distanceM: distanceM.value,
          inRange: actualInRange,
        ),
      );
      fetchWeeklyLog();
      _refreshTeamIfActive();
      AppToast.success('Check-out', respMsg ?? 'Checked out');
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] as String?;
      AppToast.failed('Check-out failed', msg ?? 'Please try again');
    } catch (_) {
      AppToast.failed('Error', 'Unexpected error. Please try again.');
    } finally {
      isCheckingIn(false);
    }
  }

  // ─────────────────────────────────────
  // TODAY LOGS
  // ─────────────────────────────────────
  Future<void> fetchTodayLogs() async {
    try {
      isLoadingLogs(true);
      final response = await ApiClient.instance.get(ApiList.attendanceToday);
      debugPrint(
        'TODAY LOGS response: ${response.statusCode} | ${response.data}',
      );
      final list = response.data['data'] as List? ?? [];
      todayLogs.assignAll(
        list.map((e) => AttendanceLog.fromJson(e as Map<String, dynamic>)),
      );
      _reconcileCheckedInState();
    } catch (e) {
      debugPrint('TODAY LOGS error: $e');
    } finally {
      isLoadingLogs(false);
    }
  }

  // ─────────────────────────────────────
  // WEEKLY LOG
  // ─────────────────────────────────────
  Future<void> fetchWeeklyLog() async {
    try {
      isWeeklyLogLoading(true);
      final start = weekStart;
      final end = start.add(const Duration(days: 6));

      // BUG-08: week can span two months (e.g. Mon 27 Oct – Sun 2 Nov).
      // Always fetch the month containing the end of the week; also fetch the
      // start month when the week crosses a boundary so no days are blank.
      Future<List<AttendanceRecordModel>> fetchMonth(int month, int year) async {
        final res = await ApiClient.instance.get(
          ApiList.attendanceHistory,
          queryParameters: {'month': month, 'year': year},
        );
        return (res.data['data'] as List? ?? const [])
            .map((item) =>
                AttendanceRecordModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      final records = await fetchMonth(end.month, end.year);
      if (start.month != end.month || start.year != end.year) {
        records.addAll(await fetchMonth(start.month, start.year));
      }

      final days = List.generate(7, (i) {
        final date = start.add(Duration(days: i));
        AttendanceRecordModel? rec;
        for (final r in records) {
          if (_sameDay(r.date, date)) {
            rec = r;
            break;
          }
        }
        return WeekDayEntry(date: date, record: rec);
      });
      weeklyLog.assignAll(days);
    } catch (e) {
      debugPrint('WEEKLY_LOG error: $e');
      final start = weekStart;
      weeklyLog.assignAll(
        List.generate(7, (i) => WeekDayEntry(date: start.add(Duration(days: i)))),
      );
    } finally {
      isWeeklyLogLoading(false);
    }
  }

  // ─────────────────────────────────────
  // DOCUMENTS
  // ─────────────────────────────────────
  Future<void> fetchDocuments() async {
    try {
      isLoadingDocs(true);
      final response = await ApiClient.instance.get(ApiList.documents);
      documents.assignAll(
        (response.data['data'] as List? ?? const []).map(
          (e) => DocumentModel.fromJson(e as Map<String, dynamic>),
        ),
      );
    } catch (_) {
    } finally {
      isLoadingDocs(false);
    }
  }

  Future<void> pickAndUpload() async {
    uploadError('');

    final status = await Permission.photos.request();
    if (status.isPermanentlyDenied) {
      openAppSettings();
      return;
    }

    final picked = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (picked == null || picked.path == null) return;

    if ((picked.lengthSync() ?? 0) > 5 * 1024 * 1024) {
      uploadError('File too large. Maximum 5 MB.');
      return;
    }

    try {
      isUploading(true);
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          picked.path!,
          filename: picked.name,
        ),
        'type': selectedType.value.name,
      });

      final response = await ApiClient.instance.post(
        ApiList.documentsUpload,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
          sendTimeout: const Duration(seconds: 60),
        ),
      );

      final doc = DocumentModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
      documents.insert(0, doc);

      AppToast.pending(
        'Upload berjaya',
        '${doc.typeLabel} submitted for review',
      );
    } on DioException catch (e) {
      uploadError(e.response?.data['message'] as String? ?? 'Upload failed.');
    } catch (_) {
      uploadError('Upload failed. Please try again.');
    } finally {
      isUploading(false);
    }
  }

  // ─────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────

  // Scoped storage key so check-in state never leaks between users.
  String get _checkinKey {
    final uid = GetStorage().read<String>('user_email') ?? 'default';
    return 'last_checkin_date_$uid';
  }

  void _checkTodayStatus() {
    final lastIn = GetStorage().read<String>(_checkinKey);
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';
    if (lastIn == todayStr) {
      checkedInToday(true);
      checkInStatus(CheckInStatus.alreadyIn);
      checkInMessage('You already checked in today');
    }
  }

  // After today's logs load, reconcile checkedInToday with actual API data.
  // This overrides the storage-based optimistic value and fixes cross-user pollution.
  void _reconcileCheckedInState() {
    final hasCheckIn = todayLogs.any((l) => l.type == 'checkin');
    final hasCheckOut = todayLogs.any((l) => l.type == 'checkout');
    if (!hasCheckIn) {
      // No check-in record from server — clear any stale local flag.
      checkedInToday(false);
      if (checkInStatus.value == CheckInStatus.alreadyIn) {
        checkInStatus(CheckInStatus.idle);
      }
      GetStorage().remove(_checkinKey);
    } else if (hasCheckOut) {
      // Day is complete — both check-in and check-out exist.
      checkedInToday(false);
      GetStorage().remove(_checkinKey);
    } else {
      // Checked in but not yet checked out — currently active.
      checkedInToday(true);
      checkInStatus(CheckInStatus.alreadyIn);
    }
  }

  String get distanceLabel {
    final d = distanceM.value;
    if (d < 1) return '<1m from office';
    return '${d.toStringAsFixed(0)}m from office';
  }

  @override
  void onClose() {
    _locationStream?.cancel();
    super.onClose();
  }
}
