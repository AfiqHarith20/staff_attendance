import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/dashboard_controller/dashboard_controller.dart';
import '../../../themes/app_colors.dart';
import '../../../widgets/responsive_page.dart';

// ── Private helper data class ──────────────────────────────────────────────
class _QuickItem {
  final IconData icon;
  final String label;
  final Color color;
  const _QuickItem({
    required this.icon,
    required this.label,
    required this.color,
  });
}

// ── Screen ──────────────────────────────────────────────────────────────────
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<DashboardController>()) {
      Get.put(DashboardController());
    }
    final c = Get.find<DashboardController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPad =
        MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: ResponsivePage(
          child: ListView(
            padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPad + 16),
            children: [
              _buildHeader(c, isDark),
              const SizedBox(height: 14),
              _buildHeroCard(c, isDark),
              const SizedBox(height: 12),
              _buildStatRow(c, isDark),
              const SizedBox(height: 16),
              _buildQuickAccess(isDark),
              const SizedBox(height: 16),
              _buildAnnouncements(c, isDark),
              const SizedBox(height: 16),
              _buildLeaveBalance(c, isDark),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header: greeting + avatar ──────────────────────────────────────────
  Widget _buildHeader(DashboardController c, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                c.greetingKey.tr,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                c.userName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.primary,
          child: Text(
            c.userInitials,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  // ── Hero check-in card ──────────────────────────────────────────────────
  Widget _buildHeroCard(DashboardController c, bool isDark) {
    final cardBg = isDark ? const Color(0xFF0D2335) : Colors.white;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: isDark
            ? Border.all(color: Colors.white.withOpacity(0.05), width: 1.5)
            : Border.all(color: const Color(0xFFE6EEF6)),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Obx(() {
        final scan = c.scanController;
        final status = scan.checkInStatus.value;
        final dist = scan.distanceM.value;
        final isIn = scan.isInRange;
        final logs = scan.todayLogs;
        final lastLog = logs.isNotEmpty ? logs.last : null;

        final locLine = c.locationLine(status, dist, isIn);
        final locIsGood = c.locationIsPositive(status);
        final locColor = locIsGood ? AppColors.success : AppColors.textMuted;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time + Live badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  c.timeString,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                    height: 1.0,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0A1828)
                        : const Color(0xFFF0F4F8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFF22C55E),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Live',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            // Date
            Text(
              c.dateString,
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 10),
            // Location row
            Row(
              children: [
                Icon(Icons.location_on_rounded, size: 15, color: locColor),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    locLine,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: locColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Check In Now button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: c.onCheckInTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'check_in_now'.tr,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Last check-in
            Center(
              child: Text(
                c.lastCheckinText(lastLog),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // ── 3 stat cards ────────────────────────────────────────────────────────
  Widget _buildStatRow(DashboardController c, bool isDark) {
    final cardBg = isDark ? const Color(0xFF0D2335) : Colors.white;

    return Obx(
      () => Row(
        children: [
          _statCard(
            c.presentCount.value.toString(),
            'present'.tr,
            const Color(0xFF22C55E),
            cardBg,
            isDark,
          ),
          const SizedBox(width: 10),
          _statCard(
            c.lateCount.value.toString(),
            'late'.tr,
            const Color(0xFFF59E0B),
            cardBg,
            isDark,
          ),
          const SizedBox(width: 10),
          _statCard(
            c.leaveLeft.value.toString(),
            'leave_left'.tr,
            AppColors.primary,
            cardBg,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _statCard(
    String value,
    String label,
    Color valueColor,
    Color bg,
    bool isDark,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: isDark
              ? Border.all(color: Colors.white.withOpacity(0.05), width: 1.5)
              : Border.all(color: const Color(0xFFE6EEF6)),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                height: 1.0,
                color: valueColor,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Quick access (4 buttons) ────────────────────────────────────────────
  Widget _buildQuickAccess(bool isDark) {
    final items = [
      _QuickItem(
        icon: Icons.event_available_rounded,
        label: 'apply_leave'.tr,
        color: AppColors.primary,
      ),
      _QuickItem(
        icon: Icons.more_time_rounded,
        label: 'overtime_label'.tr,
        color: const Color(0xFFF59E0B),
      ),
      _QuickItem(
        icon: Icons.receipt_long_rounded,
        label: 'submit_claim'.tr,
        color: const Color(0xFF22C55E),
      ),
      _QuickItem(
        icon: Icons.upload_file_rounded,
        label: 'upload_mc_short'.tr,
        color: const Color(0xFFEC4899),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'quick_access_label'.tr,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: items.map((item) {
            return Expanded(child: _buildQuickItem(item, isDark));
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuickItem(_QuickItem item, bool isDark) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: item.color.withOpacity(isDark ? 0.15 : 0.10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(item.icon, color: item.color, size: 24),
        ),
        const SizedBox(height: 6),
        Text(
          item.label,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: TextStyle(
            fontSize: 11,
            color: isDark
                ? Colors.white.withOpacity(0.85)
                : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // ── Announcements ────────────────────────────────────────────────────────
  Widget _buildAnnouncements(DashboardController c, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'announcements_title'.tr,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'see_all'.tr,
                style: const TextStyle(color: AppColors.primary, fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Obx(
          () => SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(right: 12),
              itemCount: c.announcements.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, i) =>
                  _buildAnnouncementCard(c.announcements[i], isDark),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnnouncementCard(AnnouncementItem item, bool isDark) {
    final isBirthday = item.type == 'birthday';
    final accent = isBirthday
        ? const Color(0xFFF59E0B)
        : const Color(0xFF6366F1);
    final cardBg = isBirthday
        ? (isDark ? const Color(0xFF1E1400) : const Color(0xFFFFFBEB))
        : (isDark ? const Color(0xFF0E1333) : const Color(0xFFEEF2FF));
    final bottomText = item.team != null
        ? '${item.when} · ${item.team}'
        : item.when;

    return Container(
      width: 168,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              item.badge,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
                color: accent,
              ),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            item.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.3,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            bottomText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  // ── Leave balance ──────────────────────────────────────────────────────
  Widget _buildLeaveBalance(DashboardController c, bool isDark) {
    final cardBg = isDark ? const Color(0xFF0D2335) : Colors.white;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: isDark
            ? Border.all(color: Colors.white.withOpacity(0.05), width: 1.5)
            : Border.all(color: const Color(0xFFE6EEF6)),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'leave_balance_title'.tr,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: c.leaveBalances
                  .map(
                    (b) => Expanded(
                      child: Center(child: _buildBalanceRow(b, isDark)),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 14),
          // Upcoming leaves list
          Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'upcoming_leave_title'.tr,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Column(
                  children: c.upcomingLeaves.map((u) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: _buildUpcomingLeaveRow(u, isDark),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceRow(LeaveBalance b, bool isDark) {
    final color = Color(b.colorValue);
    const double size = 76; // increase this to make circles larger
    final double stroke = 7;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: b.ratio,
                  strokeWidth: stroke,
                  strokeCap: StrokeCap.round,
                  backgroundColor: color.withOpacity(0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${b.taken}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      height: 1.0,
                      color: color,
                    ),
                  ),
                  Text(
                    '/${b.total}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: color.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: size,
          child: Text(
            b.labelKey.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? Colors.white.withOpacity(0.85)
                  : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingLeaveRow(UpcomingLeave u, bool isDark) {
    final statusColor = u.status.toLowerCase() == 'approved'
        ? AppColors.success
        : AppColors.primary;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                u.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                u.period,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            u.status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: statusColor,
            ),
          ),
        ),
      ],
    );
  }
}
