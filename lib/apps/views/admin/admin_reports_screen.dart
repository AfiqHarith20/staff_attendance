import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/routes.dart';
import '../../../widgets/app_page_widgets.dart';
import '../../../widgets/app_toast.dart';

class AdminReportsScreen extends StatelessWidget {
  final bool showBackButton;
  const AdminReportsScreen({super.key, this.showBackButton = true});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            AppPageHeader(
              title: 'Reports',
              showBackButton: showBackButton,
              actions: [
                IconButton(
                  onPressed: () => Get.toNamed(Routes.employeeManagement),
                  icon: const Icon(Icons.manage_accounts_rounded),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _ExportPanel(isDark: isDark),
            const SizedBox(height: 16),
            _ReportCard(
              title: 'Monthly Attendance',
              subtitle: 'Presence, absence, late arrivals and missing checkout',
              icon: Icons.calendar_month_rounded,
              color: const Color(0xFF185FA5),
              isDark: isDark,
              route: Routes.monthlyAttendanceReport,
            ),
            _ReportCard(
              title: 'Lateness Report',
              subtitle: 'Late minutes by department, staff and date range',
              icon: Icons.timer_off_rounded,
              color: const Color(0xFFF59E0B),
              isDark: isDark,
              route: Routes.latenessReport,
            ),
            _ReportCard(
              title: 'Overtime Summary',
              subtitle: 'Approved, pending and rejected overtime hours',
              icon: Icons.more_time_rounded,
              color: const Color(0xFF16A34A),
              isDark: isDark,
              route: Routes.overtimeSummaryReport,
            ),
            _ReportCard(
              title: 'Leave & Claim Summary',
              subtitle: 'Leave balances, claim totals and finance status',
              icon: Icons.receipt_long_rounded,
              color: const Color(0xFF7F77DD),
              isDark: isDark,
              route: Routes.leaveClaimSummaryReport,
            ),
          ],
        ),
      ),
    );
  }
}

class _ExportPanel extends StatelessWidget {
  final bool isDark;
  const _ExportPanel({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Export center',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Generate CSV or PDF reports for payroll, HR review, and management meetings.',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => AppToast.pending(
                    'CSV export',
                    'Monthly attendance CSV is being prepared.',
                  ),
                  icon: const Icon(Icons.table_view_rounded, size: 18),
                  label: const Text('CSV'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => AppToast.pending(
                    'PDF export',
                    'Management report PDF is being prepared.',
                  ),
                  icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                  label: const Text('PDF'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isDark;
  final String route;

  const _ReportCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      onTap: () => Get.toNamed(route),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }
}
