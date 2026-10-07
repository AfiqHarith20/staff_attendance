import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../controllers/bottom_nav_controller/bottom_nav_controller.dart';
import '../../../controllers/dashboard_controller/dashboard_controller.dart';
import '../../../routes/routes.dart';
import '../../../themes/app_colors.dart';
import '../../../../widgets/responsive_page.dart';
import '../../../../widgets/app_page_widgets.dart';

// ── Private helper data class ──────────────────────────────────────────────
class _QuickItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

class _AdminHeroMetric extends StatelessWidget {
  final String label;
  final String value;
  const _AdminHeroMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
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
    final bottomPad = ResponsivePage.isWide(context) ? 24.0 : 12.0;

    if (c.isAdmin) {
      return _buildAdminDashboard(context, c, isDark, bottomPad);
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: ResponsivePage(
          child: ListView(
            padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPad),
            children: [
              _buildHeader(c, isDark),
              const SizedBox(height: 14),
              _buildHeroCard(c, isDark),
              const SizedBox(height: 12),
              _buildStatRow(c, isDark),
              const SizedBox(height: 16),
              _buildQuickAccess(isDark),
              const SizedBox(height: 16),
              _buildPendingApprovals(c, isDark),
              const SizedBox(height: 16),
              _buildLatestStatuses(c, isDark),
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

  Widget _buildAdminDashboard(
    BuildContext context,
    DashboardController c,
    bool isDark,
    double bottomPad,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: ResponsivePage(
          child: ListView(
            padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPad),
            children: [
              _buildHeader(c, isDark),
              const SizedBox(height: 14),
              _buildAdminHero(c, isDark),
              const SizedBox(height: 16),
              _buildAdminQuickActions(c, isDark),
              const SizedBox(height: 16),
              _buildAdminStatsGrid(c, isDark),
              const SizedBox(height: 16),
              _buildTodayExceptions(c, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminHero(DashboardController c, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F4C81), Color(0xFF185FA5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Admin command center',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${c.dateString} · ${c.timeString}',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.82)),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = (constraints.maxWidth - 16) / 3;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    const [
                      _AdminHeroMetric(label: 'Pending', value: '7'),
                      _AdminHeroMetric(label: 'Exceptions', value: '10'),
                      _AdminHeroMetric(label: 'Missing out', value: '5'),
                    ].map((item) {
                      return SizedBox(width: itemWidth, child: item);
                    }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdminQuickActions(DashboardController c, bool isDark) {
    final actions = [
      _QuickItem(
        icon: Icons.groups_rounded,
        label: 'Team',
        color: const Color(0xFF16A34A),
        onTap: () => c.openRoute(Routes.teamAttendance),
      ),
      _QuickItem(
        icon: Icons.approval_rounded,
        label: 'Approvals',
        color: const Color(0xFFF59E0B),
        onTap: () => c.openRoute(Routes.approvalInbox),
      ),
      _QuickItem(
        icon: Icons.bar_chart_rounded,
        label: 'Reports',
        color: const Color(0xFF185FA5),
        onTap: () => c.openRoute(Routes.adminReports),
      ),
      _QuickItem(
        icon: Icons.manage_accounts_rounded,
        label: 'Employees',
        color: const Color(0xFF7F77DD),
        onTap: () => c.openRoute(Routes.employeeManagement),
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Admin tools',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 360;
            final itemWidth = compact
                ? (constraints.maxWidth - 8) / 2
                : (constraints.maxWidth - 24) / 4;
            return Wrap(
              spacing: 8,
              runSpacing: 12,
              children: actions
                  .map(
                    (item) => SizedBox(
                      width: itemWidth,
                      child: _buildQuickItem(item, isDark),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAdminStatsGrid(DashboardController c, bool isDark) {
    final cardBg = isDark ? const Color(0xFF0D2335) : Colors.white;
    return Obx(
      () => AppAdaptiveGrid(
        itemCount: c.adminStats.length,
        minChildWidth: 160,
        childAspectRatio: 1.85,
        itemBuilder: (_, index) {
          final item = c.adminStats[index];
          final color = Color(item.colorValue);
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : const Color(0xFFE6EEF6),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${item.count}',
                  style: TextStyle(
                    color: color,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.label,
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                Text(
                  item.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTodayExceptions(DashboardController c, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D2335) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : const Color(0xFFE6EEF6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today exceptions',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Obx(
            () => Column(
              children: c.todayExceptions.map((item) {
                final color = Color(item.accentColorValue);
                return InkWell(
                  onTap: () => c.openRoute(item.route),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: color.withValues(alpha: 0.12),
                          child: Icon(
                            Icons.priority_high_rounded,
                            color: color,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                item.subtitle,
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item.status,
                          style: TextStyle(
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header: greeting + avatar ──────────────────────────────────────────
  Widget _buildHeader(DashboardController c, bool isDark) {
    final role = (GetStorage().read<String>('user_role') ?? 'staff')
        .toLowerCase();
    final targetIndex =
        const {'admin', 'super_admin', 'owner', 'hr', 'manager'}.contains(role)
        ? 4
        : 3;
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
        GestureDetector(
          onTap: () {
            final nav = Get.isRegistered<BottomNavController>()
                ? Get.find<BottomNavController>()
                : Get.put(BottomNavController());
            nav.setIndex(targetIndex);
          },
          child: CircleAvatar(
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
            ? Border.all(
                color: Colors.white.withValues(alpha: 0.05),
                width: 1.5,
              )
            : Border.all(color: const Color(0xFFE6EEF6)),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;
        final cardWidth = compact
            ? constraints.maxWidth
            : (constraints.maxWidth - 20) / 3;

        return Obx(() {
          final cards = [
            _statCard(
              c.presentCount.value.toString(),
              'Present this month',
              const Color(0xFF22C55E),
              cardBg,
              isDark,
            ),
            _statCard(
              c.lateCount.value.toString(),
              'Late this month',
              const Color(0xFFF59E0B),
              cardBg,
              isDark,
            ),
            _statCard(
              c.leaveLeft.value.toString(),
              'leave_left'.tr,
              AppColors.primary,
              cardBg,
              isDark,
            ),
          ];

          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: cards
                .map((card) => SizedBox(width: cardWidth, child: card))
                .toList(),
          );
        });
      },
    );
  }

  Widget _statCard(
    String value,
    String label,
    Color valueColor,
    Color bg,
    bool isDark,
  ) {
    return Container(
      constraints: const BoxConstraints(minHeight: 92),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: isDark
            ? Border.all(
                color: Colors.white.withValues(alpha: 0.05),
                width: 1.5,
              )
            : Border.all(color: const Color(0xFFE6EEF6)),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          SizedBox(
            height: 30,
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Quick access (4 buttons) ────────────────────────────────────────────
  Widget _buildQuickAccess(bool isDark) {
    final c = Get.find<DashboardController>();
    final items = [
      _QuickItem(
        icon: Icons.event_available_rounded,
        label: 'apply_leave'.tr,
        color: AppColors.primary,
        onTap: () => c.openRoute(Routes.applyLeave),
      ),
      _QuickItem(
        icon: Icons.track_changes_rounded,
        label: 'Requests',
        color: const Color(0xFF7F77DD),
        onTap: () => c.openRoute(Routes.requestStatusTracker),
      ),
      _QuickItem(
        icon: Icons.upload_file_rounded,
        label: 'upload_mc_short'.tr,
        color: const Color(0xFFEC4899),
        onTap: () => c.openRoute(Routes.documentUpload),
      ),
      _QuickItem(
        icon: Icons.history_rounded,
        label: 'History',
        color: const Color(0xFFF59E0B),
        onTap: () => c.openRoute(Routes.attendanceHistory),
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
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 360;
            final itemWidth = compact
                ? (constraints.maxWidth - 8) / 2
                : (constraints.maxWidth - 24) / 4;
            return Wrap(
              spacing: 8,
              runSpacing: 12,
              children: items
                  .map(
                    (item) => SizedBox(
                      width: itemWidth,
                      child: _buildQuickItem(item, isDark),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickItem(_QuickItem item, bool isDark) {
    return GestureDetector(
      onTap: item.onTap,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: isDark ? 0.15 : 0.10),
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
                  ? Colors.white.withValues(alpha: 0.85)
                  : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingApprovals(DashboardController c, bool isDark) {
    final cardBg = isDark ? const Color(0xFF0D2335) : Colors.white;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: isDark
            ? Border.all(
                color: Colors.white.withValues(alpha: 0.05),
                width: 1.5,
              )
            : Border.all(color: const Color(0xFFE6EEF6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pending items',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Obx(
            () => Column(
              children: c.pendingApprovals.map((item) {
                final accent = Color(item.colorValue);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            item.count.toString(),
                            style: TextStyle(
                              color: accent,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.label,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white
                                    : AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.subtitle,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLatestStatuses(DashboardController c, bool isDark) {
    final cardBg = isDark ? const Color(0xFF0D2335) : Colors.white;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: isDark
            ? Border.all(
                color: Colors.white.withValues(alpha: 0.05),
                width: 1.5,
              )
            : Border.all(color: const Color(0xFFE6EEF6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Latest activity',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Obx(() {
            final items = c.latestStatuses.take(3).toList();
            return Column(
              children: [
                ...items.map((item) {
                  final accent = Color(item.accentColorValue);
                  return GestureDetector(
                    onTap: () => c.openRoute(item.route),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF10243A)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.subtitle,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item.status,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: accent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.35)
                                : const Color(0xFF94A3B8),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => c.openRoute(Routes.requestStatusTracker),
                    child: const Text('View all requests'),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
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
              onPressed: c.openAnnouncements,
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
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(right: 12),
              itemCount: c.announcements.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
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
        border: Border.all(
          color: item.isUnread
              ? accent.withValues(alpha: 0.55)
              : accent.withValues(alpha: 0.3),
          width: item.isUnread ? 1.4 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withValues(
                      alpha: item.isUnread ? 0.22 : 0.15,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.badge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                      color: accent,
                    ),
                  ),
                ),
              ),
              if (item.isUnread) ...[
                const SizedBox(width: 6),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
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
          const Spacer(),
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
            ? Border.all(
                color: Colors.white.withValues(alpha: 0.05),
                width: 1.5,
              )
            : Border.all(color: const Color(0xFFE6EEF6)),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
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
          const SizedBox(height: 4),
          const Text(
            'Remaining days shown first. Used / total and pending requests still included below.',
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 360;
              final itemWidth = compact
                  ? constraints.maxWidth
                  : (constraints.maxWidth - 24) / 3;
              return Obx(
                () => Wrap(
                  spacing: 12,
                  runSpacing: 14,
                  alignment: WrapAlignment.spaceBetween,
                  children: c.leaveBalances
                      .map(
                        (b) => SizedBox(
                          width: itemWidth,
                          child: Center(child: _buildBalanceRow(b, isDark, c)),
                        ),
                      )
                      .toList(),
                ),
              );
            },
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
                if (c.upcomingLeaves.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF10243A)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      'No upcoming leave scheduled. Your next approved leave will appear here.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        height: 1.4,
                      ),
                    ),
                  )
                else
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

  Widget _buildBalanceRow(LeaveBalance b, bool isDark, DashboardController c) {
    final baseColor = Color(b.colorValue);
    final color = b.isLowBalance ? const Color(0xFFF59E0B) : baseColor;
    const double size = 76; // increase this to make circles larger
    final double stroke = 7;

    return GestureDetector(
      onTap: () => c.openRoute(Routes.leaveBalanceDetail),
      child: Column(
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
                    backgroundColor: color.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${b.remaining}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        height: 1.0,
                        color: color,
                      ),
                    ),
                    Text(
                      'left',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: color.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: size + 22,
            child: Column(
              children: [
                Text(
                  b.labelKey.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.85)
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${b.taken} / ${b.total} used',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  b.pending > 0
                      ? '${b.pending} pending approval'
                      : 'No pending request',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: b.pending > 0
                        ? const Color(0xFFF59E0B)
                        : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
            color: statusColor.withValues(alpha: 0.12),
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
