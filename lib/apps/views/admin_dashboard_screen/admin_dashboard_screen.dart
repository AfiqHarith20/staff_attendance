import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/admin_dashboard_controller/admin_dashboard_controller.dart';
import 'package:staff_attendance/apps/models/admin_dashboard_model.dart';
import 'package:staff_attendance/apps/themes/app_colors.dart';
import 'package:staff_attendance/widgets/app_page_widgets.dart';

class AdminDashboardScreen extends GetView<AdminDashboardController> {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final text = isDark ? Colors.white : const Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                  color: AppColors.primary, strokeWidth: 2.5),
            );
          }
          if (controller.hasError.value || controller.stats.value == null) {
            return _ErrorRetry(
              isDark: isDark,
              onRetry: controller.fetchStats,
            );
          }
          final s = controller.stats.value!;
          return RefreshIndicator(
            onRefresh: controller.fetchStats,
            color: AppColors.primary,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                AppPageHeader(
                  title: 'Admin Dashboard',
                  actions: [
                    IconButton(
                      tooltip: 'Refresh',
                      onPressed: controller.fetchStats,
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  s.date,
                  style: TextStyle(
                    color: text.withValues(alpha: 0.5),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                // Top-level stat row
                Row(
                  children: [
                    _StatTile(
                      label: 'Headcount',
                      value: s.headcount.toString(),
                      icon: Icons.people_rounded,
                      color: const Color(0xFF185FA5),
                      isDark: isDark,
                    ),
                    const SizedBox(width: 10),
                    _StatTile(
                      label: 'Pending',
                      value: s.pendingApprovals.toString(),
                      icon: Icons.pending_actions_rounded,
                      color: const Color(0xFFF59E0B),
                      isDark: isDark,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Attendance breakdown
                AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Today\'s Attendance',
                        style: TextStyle(
                          color: text,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 1.6,
                        children: [
                          _AttendanceTile(
                              label: 'Present',
                              value: s.attendance.present,
                              color: const Color(0xFF16A34A),
                              isDark: isDark),
                          _AttendanceTile(
                              label: 'Late',
                              value: s.attendance.late,
                              color: const Color(0xFFF59E0B),
                              isDark: isDark),
                          _AttendanceTile(
                              label: 'On Leave',
                              value: s.attendance.onLeave,
                              color: const Color(0xFF7F77DD),
                              isDark: isDark),
                          _AttendanceTile(
                              label: 'Absent',
                              value: s.attendance.absent,
                              color: const Color(0xFFDC2626),
                              isDark: isDark),
                          _AttendanceTile(
                              label: 'Remote',
                              value: s.attendance.remote,
                              color: const Color(0xFF0284C7),
                              isDark: isDark),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Exceptions
                if (s.exceptions.isNotEmpty) ...[
                  Text(
                    'Exceptions',
                    style: TextStyle(
                      color: text,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...s.exceptions.map(
                    (e) => _ExceptionRow(item: e, isDark: isDark),
                  ),
                  const SizedBox(height: 12),
                ],
                // By department
                if (s.byDepartment.isNotEmpty) ...[
                  Text(
                    'By Department',
                    style: TextStyle(
                      color: text,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...s.byDepartment.map(
                    (d) => _DeptRow(dept: d, isDark: isDark),
                  ),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: (isDark ? Colors.white : const Color(0xFF0F172A))
                        .withValues(alpha: 0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceTile extends StatelessWidget {
  const _AttendanceTile({
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  final String label;
  final int value;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value.toString(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: color.withValues(alpha: 0.8),
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ExceptionRow extends StatelessWidget {
  const _ExceptionRow({required this.item, required this.isDark});

  final ExceptionItem item;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  '${item.kind} · ${item.detail}',
                  style: TextStyle(
                    color: (isDark ? Colors.white : const Color(0xFF0F172A))
                        .withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (item.dept != null)
            Text(
              item.dept!,
              style: TextStyle(
                color: (isDark ? Colors.white : const Color(0xFF0F172A))
                    .withValues(alpha: 0.4),
                fontSize: 11,
              ),
            ),
        ],
      ),
    );
  }
}

class _DeptRow extends StatelessWidget {
  const _DeptRow({required this.dept, required this.isDark});

  final DeptAttendance dept;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final text = isDark ? Colors.white : const Color(0xFF0F172A);
    final presentPct = dept.total > 0
        ? dept.counts.present / dept.total
        : 0.0;
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  dept.department,
                  style: TextStyle(
                    color: text,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              Text(
                '${dept.counts.present}/${dept.total}',
                style: TextStyle(
                  color: text.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: presentPct.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: const Color(0xFF16A34A).withValues(alpha: 0.15),
              color: const Color(0xFF16A34A),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  const _ErrorRetry({required this.isDark, required this.onRetry});

  final bool isDark;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded,
              size: 48, color: Colors.red.withValues(alpha: 0.6)),
          const SizedBox(height: 12),
          Text(
            'Failed to load dashboard',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
