import 'dart:async';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:staff_attendance/api/api_client.dart';
import 'package:staff_attendance/apps/routes/api_routes.dart';
import 'package:staff_attendance/apps/models/attendance_history_model.dart';

import '../scan_controller/scan_controller.dart';
import '../../routes/routes.dart';

// ── Announcement item ──────────────────────────────────────────────────────
class AnnouncementItem {
  final String type; // 'birthday' | 'holiday' | 'event'
  final String badge;
  final String title;
  final String when;
  final String? team;
  final bool isUnread;

  const AnnouncementItem({
    required this.type,
    required this.badge,
    required this.title,
    required this.when,
    this.team,
    this.isUnread = false,
  });
}

// ── Leave balance entry ────────────────────────────────────────────────────
class LeaveBalance {
  final String labelKey; // translation key
  final int taken;
  final int total;
  final int pending;
  final int colorValue; // ARGB

  const LeaveBalance({
    required this.labelKey,
    required this.taken,
    required this.total,
    this.pending = 0,
    required this.colorValue,
  });

  double get ratio => total == 0 ? 0.0 : (taken / total).clamp(0.0, 1.0);
  int get remaining => (total - taken).clamp(0, total);
  bool get isLowBalance => remaining <= 3;
}

// ── Upcoming leave item ───────────────────────────────────────────────────
class UpcomingLeave {
  final String title; // e.g. 'Annual leave'
  final String period; // e.g. '12 Apr 2026 - 14 Apr 2026'
  final String status; // e.g. 'Approved', 'Pending'

  const UpcomingLeave({
    required this.title,
    required this.period,
    required this.status,
  });
}

class PendingApprovalSummary {
  final String label;
  final String subtitle;
  final int count;
  final int colorValue;

  const PendingApprovalSummary({
    required this.label,
    required this.subtitle,
    required this.count,
    required this.colorValue,
  });
}

class StatusSnapshot {
  final String title;
  final String subtitle;
  final String status;
  final int accentColorValue;
  final String route;

  const StatusSnapshot({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.accentColorValue,
    required this.route,
  });
}

// ── Weekly log day ─────────────────────────────────────────────────────────
class WeeklyLogDay {
  final DateTime date;
  final AttendanceRecordStatus? status; // null = future or no record
  final DateTime? checkInAt;
  final DateTime? checkOutAt;
  final String workingHoursLabel;

  const WeeklyLogDay({
    required this.date,
    required this.status,
    required this.checkInAt,
    required this.checkOutAt,
    required this.workingHoursLabel,
  });

  bool get isToday {
    final n = DateTime.now();
    return date.year == n.year && date.month == n.month && date.day == n.day;
  }

  bool get isFuture => date.isAfter(DateTime.now());
  bool get hasRecord => status != null;

  int get statusColorValue {
    switch (status) {
      case AttendanceRecordStatus.present:
        return 0xFF16A34A;
      case AttendanceRecordStatus.late:
        return 0xFFF59E0B;
      case AttendanceRecordStatus.absent:
        return 0xFFDC2626;
      case AttendanceRecordStatus.leave:
        return 0xFF185FA5;
      case AttendanceRecordStatus.issue:
        return 0xFF7F77DD;
      case null:
        return isFuture ? 0xFF94A3B8 : 0xFFCBD5E1;
    }
  }
}

// ── Controller ─────────────────────────────────────────────────────────────
class DashboardController extends GetxController {
  // Live clock
  final now = DateTime.now().obs;
  Timer? _clockTimer;

  // User info (from storage)
  String get userName {
    final box = GetStorage();
    final storedName = box.read<String>('user_name')?.trim();
    if (storedName != null && storedName.isNotEmpty) return storedName;

    return 'Ahmad Nizam';
  }

  String get userInitials {
    final parts = userName
        .trim()
        .split(' ')
        .where((s) => s.isNotEmpty)
        .toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return userName.isNotEmpty ? userName[0].toUpperCase() : '?';
  }

  // Stats — replace with real API data
  final presentCount = 18.obs;
  final lateCount = 3.obs;
  final leaveLeft = 12.obs;

  // Announcements — replace with real API data
  final announcements = <AnnouncementItem>[
    const AnnouncementItem(
      type: 'birthday',
      badge: '🎂 BIRTHDAY',
      title: "Happy Birthday, Siti Rahmah!",
      when: 'Today',
      team: 'Operations Team',
      isUnread: true,
    ),
    const AnnouncementItem(
      type: 'holiday',
      badge: '🇲🇾 PUBLIC HOLIDAY',
      title: 'Hari Raya Aidilfitri',
      when: 'In 5 days · 7–8 Apr 2026',
      isUnread: false,
    ),
  ].obs;

  // Leave balances — replace with real API data
  final leaveBalances = <LeaveBalance>[
    const LeaveBalance(
      labelKey: 'annual_leave_short',
      taken: 6,
      total: 14,
      pending: 2,
      colorValue: 0xFF2196F3,
    ),
    const LeaveBalance(
      labelKey: 'medical_leave',
      taken: 2,
      total: 14,
      pending: 0,
      colorValue: 0xFF4CAF50,
    ),
    const LeaveBalance(
      labelKey: 'emergency_leave',
      taken: 2,
      total: 6,
      pending: 1,
      colorValue: 0xFFFF9800,
    ),
  ].obs;

  // Upcoming leaves — replace with real API data
  final upcomingLeaves = <UpcomingLeave>[
    const UpcomingLeave(
      title: 'Annual Leave',
      period: '12 Apr 2026 - 14 Apr 2026',
      status: 'Approved',
    ),
    const UpcomingLeave(
      title: 'Medical Leave',
      period: '22 Apr 2026',
      status: 'Pending',
    ),
  ].obs;

  final pendingApprovals = <PendingApprovalSummary>[
    const PendingApprovalSummary(
      label: 'Leave approvals',
      subtitle: 'Requests waiting for manager review',
      count: 2,
      colorValue: 0xFF185FA5,
    ),
    const PendingApprovalSummary(
      label: 'Claim review',
      subtitle: 'Claims still pending finance review',
      count: 1,
      colorValue: 0xFF16A34A,
    ),
    const PendingApprovalSummary(
      label: 'Document follow-up',
      subtitle: 'Supporting files missing verification',
      count: 3,
      colorValue: 0xFFF59E0B,
    ),
  ].obs;

  final adminStats = <PendingApprovalSummary>[
    const PendingApprovalSummary(
      label: 'Present',
      subtitle: 'Clocked in today',
      count: 18,
      colorValue: 0xFF16A34A,
    ),
    const PendingApprovalSummary(
      label: 'Late',
      subtitle: 'Arrived after shift start',
      count: 3,
      colorValue: 0xFFF59E0B,
    ),
    const PendingApprovalSummary(
      label: 'Absent',
      subtitle: 'No attendance record',
      count: 2,
      colorValue: 0xFFDC2626,
    ),
    const PendingApprovalSummary(
      label: 'On leave',
      subtitle: 'Approved leave today',
      count: 4,
      colorValue: 0xFF185FA5,
    ),
    const PendingApprovalSummary(
      label: 'Pending approvals',
      subtitle: 'Waiting for action',
      count: 7,
      colorValue: 0xFF7F77DD,
    ),
    const PendingApprovalSummary(
      label: 'Missing checkout',
      subtitle: 'Need follow-up',
      count: 5,
      colorValue: 0xFFEA580C,
    ),
  ].obs;

  final todayExceptions = <StatusSnapshot>[
    const StatusSnapshot(
      title: 'Siti Rahmah checked in late',
      subtitle: '9:22 AM · 22 minutes after shift start',
      status: 'Late',
      accentColorValue: 0xFFF59E0B,
      route: Routes.teamAttendance,
    ),
    const StatusSnapshot(
      title: 'Farid Hakim has no record',
      subtitle: 'Sales · no check-in detected',
      status: 'Absent',
      accentColorValue: 0xFFDC2626,
      route: Routes.teamAttendance,
    ),
    const StatusSnapshot(
      title: 'Daniel Tan working remotely',
      subtitle: 'Approved WFH · location verified',
      status: 'Remote',
      accentColorValue: 0xFF7F77DD,
      route: Routes.teamAttendance,
    ),
  ].obs;

  final latestStatuses = <StatusSnapshot>[
    const StatusSnapshot(
      title: 'Annual Leave · 12-14 Aug 2026',
      subtitle: 'Submitted on 21 Jul 2026',
      status: 'Pending manager approval',
      accentColorValue: 0xFF185FA5,
      route: Routes.timeOff,
    ),
    const StatusSnapshot(
      title: 'Medical Claim · RM 84.50',
      subtitle: 'Receipt uploaded on 10 Jul 2026',
      status: 'Ready for finance review',
      accentColorValue: 0xFF16A34A,
      route: Routes.myDocuments,
    ),
  ].obs;

  // ── Notification badge ──────────────────────────────────────────────────
  final unreadNotifications = 0.obs;

  Future<void> fetchNotificationCount() async {
    try {
      final response = await ApiClient.instance.get(ApiList.dashboardBadges);
      final data = response.data['data'] as Map<String, dynamic>? ?? {};
      unreadNotifications(data['unread_notifications'] as int? ?? 0);
    } catch (_) {
      // non-blocking — badge just won't show
    }
  }

  // ── Weekly log ──────────────────────────────────────────────────────────
  final weeklyLog = <WeeklyLogDay>[].obs;
  final isWeeklyLogLoading = false.obs;

  DateTime get weekStart {
    final today = DateTime.now();
    return DateTime(today.year, today.month, today.day - (today.weekday - 1));
  }

  String get weekRangeLabel {
    final start = weekStart;
    final end = start.add(const Duration(days: 6));
    final fmt = DateFormat('d MMM');
    return '${fmt.format(start)} – ${fmt.format(end)}';
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<void> fetchWeeklyLog() async {
    try {
      isWeeklyLogLoading(true);
      final today = DateTime.now();
      final response = await ApiClient.instance.get(
        ApiList.attendanceHistory,
        queryParameters: {'month': today.month, 'year': today.year},
      );
      final records = (response.data['data'] as List? ?? const [])
          .map((item) =>
              AttendanceRecordModel.fromJson(item as Map<String, dynamic>))
          .toList();

      final start = weekStart;
      final days = List.generate(7, (i) {
        final date = start.add(Duration(days: i));
        AttendanceRecordModel? rec;
        for (final r in records) {
          if (_sameDay(r.date, date)) {
            rec = r;
            break;
          }
        }
        return WeeklyLogDay(
          date: date,
          status: rec?.status,
          checkInAt: rec?.checkInAt,
          checkOutAt: rec?.checkOutAt,
          workingHoursLabel: rec?.workingHoursLabel ?? '—',
        );
      });
      weeklyLog.assignAll(days);
    } catch (e) {
      debugPrint('WEEKLY_LOG error: $e');
      final start = weekStart;
      weeklyLog.assignAll(
        List.generate(
          7,
          (i) => WeeklyLogDay(
            date: start.add(Duration(days: i)),
            status: null,
            checkInAt: null,
            checkOutAt: null,
            workingHoursLabel: '—',
          ),
        ),
      );
    } finally {
      isWeeklyLogLoading(false);
    }
  }

  // ── Scan controller — shared geo / check-in state ────────────────────────
  ScanController get scanController {
    if (!Get.isRegistered<ScanController>()) Get.put(ScanController());
    return Get.find<ScanController>();
  }

  // Formatted strings
  String get timeString => DateFormat('h:mm a').format(now.value);
  String get dateString => DateFormat('EEEE, d MMM yyyy').format(now.value);
  String get greetingKey {
    final h = now.value.hour;
    if (h < 12) return 'good_morning';
    if (h < 18) return 'good_afternoon';
    return 'good_evening';
  }

  String locationLine(CheckInStatus status, double dist, bool inRange) {
    switch (status) {
      case CheckInStatus.locating:
      case CheckInStatus.idle:
        return 'locating'.tr;
      case CheckInStatus.error:
        return 'location_unavailable'.tr;
      default:
        final d = '${dist.toStringAsFixed(0)}m from office';
        final r = inRange ? '· ${'within_range'.tr}' : '· ${'out_of_range'.tr}';
        return '$d $r';
    }
  }

  bool locationIsPositive(CheckInStatus status) =>
      status == CheckInStatus.inRange ||
      status == CheckInStatus.success ||
      status == CheckInStatus.alreadyIn;

  String lastCheckinText(AttendanceLog? log) {
    if (log == null) return 'no_checkin_today'.tr;
    return '${'last_checkin'.tr}: ${_fmtTime(log.time)}';
  }

  String _fmtTime(DateTime t) {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    final tDate = DateFormat('yyyyMMdd').format(t);
    if (tDate == DateFormat('yyyyMMdd').format(today)) {
      return 'Today ${DateFormat('h:mm a').format(t)}';
    }
    if (tDate == DateFormat('yyyyMMdd').format(yesterday)) {
      return 'Yesterday ${DateFormat('h:mm a').format(t)}';
    }
    return DateFormat('d MMM h:mm a').format(t);
  }

  void onCheckInTap() {
    scanController.checkIn();
  }

  void confirmCheckOut() {
    scanController.checkOut();
  }

  void openRoute(String route) => Get.toNamed(route);

  void openAnnouncements() => Get.toNamed(Routes.announcements);

  @override
  void onInit() {
    super.onInit();
    if (!Get.isRegistered<ScanController>()) Get.put(ScanController());
    _clockTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => now(DateTime.now()),
    );
    fetchWeeklyLog();
    fetchNotificationCount();
  }

  @override
  void onClose() {
    _clockTimer?.cancel();
    super.onClose();
  }
}
