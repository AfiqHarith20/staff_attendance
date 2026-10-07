import 'dart:async';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

import '../scan_controller/scan_controller.dart';
import '../../routes/routes.dart';
import '../bottom_nav_controller/bottom_nav_controller.dart';

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

// ── Controller ─────────────────────────────────────────────────────────────
class DashboardController extends GetxController {
  // Live clock
  final now = DateTime.now().obs;
  Timer? _clockTimer;

  // User info (from storage)
  bool get isAdmin =>
      (GetStorage().read<String>('user_role') ?? 'staff').toLowerCase() ==
      'admin';

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

  // Scan controller — shared geo / check-in state
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
    // If BottomNavController is registered, set its index so the tab switches immediately.
    if (Get.isRegistered<BottomNavController>()) {
      try {
        Get.find<BottomNavController>().setIndex(1);
      } catch (_) {}
    }

    // Ensure app shell is visible: navigate to app route with tabIndex arg if not already there
    if (Get.currentRoute != Routes.app) {
      Get.offNamed(Routes.app, arguments: {'tabIndex': 1});
    }
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
  }

  @override
  void onClose() {
    _clockTimer?.cancel();
    super.onClose();
  }
}
