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

  const AnnouncementItem({
    required this.type,
    required this.badge,
    required this.title,
    required this.when,
    this.team,
  });
}

// ── Leave balance entry ────────────────────────────────────────────────────
class LeaveBalance {
  final String labelKey; // translation key
  final int taken;
  final int total;
  final int colorValue; // ARGB

  const LeaveBalance({
    required this.labelKey,
    required this.taken,
    required this.total,
    required this.colorValue,
  });

  double get ratio => total == 0 ? 0.0 : (taken / total).clamp(0.0, 1.0);
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

// ── Controller ─────────────────────────────────────────────────────────────
class DashboardController extends GetxController {
  // Live clock
  final now = DateTime.now().obs;
  Timer? _clockTimer;

  // User info (from storage)
  String get userName => GetStorage().read<String>('user_name') ?? 'Staff';
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
    ),
    const AnnouncementItem(
      type: 'holiday',
      badge: '🇲🇾 PUBLIC HOLIDAY',
      title: 'Hari Raya Aidilfitri',
      when: 'In 5 days · 7–8 Apr 2026',
    ),
  ].obs;

  // Leave balances — replace with real API data
  final leaveBalances = <LeaveBalance>[
    const LeaveBalance(
      labelKey: 'annual_leave_short',
      taken: 12,
      total: 20,
      colorValue: 0xFF2196F3,
    ),
    const LeaveBalance(
      labelKey: 'medical_leave',
      taken: 2,
      total: 14,
      colorValue: 0xFF4CAF50,
    ),
    const LeaveBalance(
      labelKey: 'emergency_leave',
      taken: 2,
      total: 6,
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
