import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:staff_attendance/api/api_client.dart';

import '../../models/document_model.dart';

// ── Check-in status states ──
enum CheckInStatus {
  idle,
  locating,
  inRange,
  outOfRange,
  success,
  alreadyIn,
  error,
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
    time: DateTime.parse(j['timestamp'] as String),
    distanceM: (j['distance_m'] as num).toDouble(),
    inRange: j['in_range'] as bool,
  );

  String get timeFormatted => DateFormat('h:mm a').format(time);
  String get distanceFormatted =>
      '${distanceM.toStringAsFixed(0)}m from office';
}

class ScanController extends GetxController {
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
  // Whether geofencing is required for check-in. If false, users may check in from any location; location is still recorded.
  final geofenceEnabled = false.obs;

  // ── Today check-in flag ──
  final checkedInToday = false.obs;

  // If true, operate in mock mode (no API calls) — useful for local testing
  final mockMode = true.obs;

  // ── Today logs ──
  final todayLogs = <AttendanceLog>[].obs;
  final isLoadingLogs = false.obs;

  // ── Documents ──
  final documents = <DocumentModel>[].obs;
  final isLoadingDocs = false.obs;
  final isUploading = false.obs;
  final uploadError = ''.obs;
  final selectedType = DocumentType.mc.obs;

  // ── Live location stream ──
  StreamSubscription<Position>? _locationStream;

  bool get isAdmin => GetStorage().read<String>('user_role') == 'admin';

  /// Returns whether the user is considered "in range" for check-in.
  /// If geofencing is disabled (`geofenceEnabled == false`) this returns true
  /// so users can check in from any location. The actual distance is still
  /// recorded and sent to the server.
  bool get isInRange =>
      (!geofenceEnabled.value) ||
      checkInStatus.value == CheckInStatus.inRange ||
      checkInStatus.value == CheckInStatus.success;

  /// Toggle geofence requirement and persist setting.
  void setGeofenceEnabled(bool v) {
    geofenceEnabled(v);
    try {
      GetStorage().write('geofence_enabled', v);
    } catch (_) {}
  }

  double get officeLat => _officeLat;
  double get officeLng => _officeLng;
  double get radiusM => _radiusM;

  @override
  void onInit() {
    super.onInit();
    // Load geofence preference (persisted)
    try {
      final stored = GetStorage().read<bool>('geofence_enabled');
      if (stored != null) geofenceEnabled(stored);
      final mockStored = GetStorage().read<bool>('mock_mode');
      if (mockStored != null) mockMode(mockStored);
    } catch (_) {}
    _checkTodayStatus();
    _startLocationTracking();
    fetchDocuments();
    fetchTodayLogs();
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

    // Only update status if not in success/alreadyIn state
    if (checkInStatus.value != CheckInStatus.success &&
        checkInStatus.value != CheckInStatus.alreadyIn) {
      checkInStatus(
        dist <= _radiusM ? CheckInStatus.inRange : CheckInStatus.outOfRange,
      );
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
  Future<void> checkIn() async {
    if (isCheckingIn.value) return;
    // If geofence is enabled, require being in range to proceed.
    if (geofenceEnabled.value &&
        !(checkInStatus.value == CheckInStatus.inRange ||
            checkInStatus.value == CheckInStatus.success)) {
      return;
    }

    try {
      isCheckingIn(true);
      checkInMessage('');

      if (mockMode.value) {
        // Simulate successful check-in
        final today = DateTime.now();
        GetStorage().write(
          'last_checkin_date',
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
        Get.snackbar(
          '✅ Check-in (mock)',
          '${distanceM.value.toStringAsFixed(0)}m dari pejabat',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF16A34A),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      final response = await ApiClient.instance.post(
        '/attendance/checkin',
        data: {
          'latitude': currentLat.value,
          'longitude': currentLng.value,
          'distance_m': distanceM.value.toStringAsFixed(2),
        },
      );

      // Successful response: mark checked-in and persist
      final respMsg = response.data is Map
          ? response.data['message'] as String?
          : null;
      final today = DateTime.now();
      GetStorage().write(
        'last_checkin_date',
        '${today.year}-${today.month}-${today.day}',
      );
      checkedInToday(true);
      checkInStatus(CheckInStatus.success);
      checkInMessage(respMsg ?? 'Check-in successful');
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
      Get.snackbar(
        '✅ Check-in',
        respMsg ?? 'Checked in',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF16A34A),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } on DioException catch (e) {
      final errMsg = e.response?.data != null
          ? e.response?.data['message'] as String?
          : null;
      if (errMsg != null && errMsg.toLowerCase().contains('already')) {
        checkedInToday(true);
        checkInStatus(CheckInStatus.alreadyIn);
        checkInMessage(errMsg);
      } else {
        checkInStatus(CheckInStatus.inRange);
        Get.snackbar(
          '❌ Check-in failed',
          errMsg ?? 'Please try again',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFDC2626),
          colorText: Colors.white,
        );
      }
    } catch (_) {
      checkInStatus(CheckInStatus.inRange);
      Get.snackbar(
        '❌ Error',
        'Unexpected error. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFDC2626),
        colorText: Colors.white,
      );
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
      Get.snackbar(
        '⚠️',
        'Please check in before checking out.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFF59E0B),
        colorText: Colors.white,
      );
      return;
    }

    if (isCheckingIn.value) return;

    try {
      isCheckingIn(true);
      if (mockMode.value) {
        // simulate checkout locally
        GetStorage().remove('last_checkin_date');
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
        Get.snackbar(
          '✅ Check-out (mock)',
          'Checked out (mock)',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF16A34A),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      final response = await ApiClient.instance.post(
        '/attendance/checkout',
        data: {
          'latitude': currentLat.value,
          'longitude': currentLng.value,
          'distance_m': distanceM.value.toStringAsFixed(2),
        },
      );

      final respMsg = response.data is Map
          ? response.data['message'] as String?
          : null;
      // mark checkout locally
      GetStorage().remove('last_checkin_date');
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
      Get.snackbar(
        '✅ Check-out',
        respMsg ?? 'Checked out',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF16A34A),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } on DioException catch (e) {
      final msg = e.response?.data['message'] as String?;
      Get.snackbar(
        '❌ Check-out failed',
        msg ?? 'Please try again',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFDC2626),
        colorText: Colors.white,
      );
    } catch (_) {
      Get.snackbar(
        '❌ Error',
        'Unexpected error. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFDC2626),
        colorText: Colors.white,
      );
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
      final response = await ApiClient.instance.get('/attendance/today');
      final list = response.data['data'] as List? ?? [];
      todayLogs.assignAll(
        list.map((e) => AttendanceLog.fromJson(e as Map<String, dynamic>)),
      );
    } catch (_) {
      // silently fail — show empty state
    } finally {
      isLoadingLogs(false);
    }
  }

  // ─────────────────────────────────────
  // DOCUMENTS
  // ─────────────────────────────────────
  Future<void> fetchDocuments() async {
    try {
      isLoadingDocs(true);
      final response = await ApiClient.instance.get('/documents');
      documents.assignAll(
        (response.data['data'] as List).map(
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

    final status = await Permission.storage.request();
    if (status.isPermanentlyDenied) {
      openAppSettings();
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return;

    final picked = result.files.first;
    if (picked.path == null) return;

    if (picked.size > 5 * 1024 * 1024) {
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
        '/documents/upload',
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

      Get.snackbar(
        '📎 Upload berjaya',
        '${doc.typeLabel} submitted for review',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF185FA5),
        colorText: Colors.white,
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
  void _checkTodayStatus() {
    final lastIn = GetStorage().read<String>('last_checkin_date');
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';
    if (lastIn == todayStr) {
      checkedInToday(true);
      checkInStatus(CheckInStatus.alreadyIn);
      checkInMessage('You already checked in today');
    }
  }

  String get distanceLabel {
    final d = distanceM.value;
    if (d < 1) return '<1m from office';
    return '${d.toStringAsFixed(0)}m from office';
  }

  String get remainingLabel {
    final remaining = (_radiusM - distanceM.value).clamp(0, _radiusM);
    if (isInRange) return distanceLabel;
    return '${(distanceM.value - _radiusM).toStringAsFixed(0)}m too far';
  }

  @override
  void onClose() {
    _locationStream?.cancel();
    super.onClose();
  }
}
