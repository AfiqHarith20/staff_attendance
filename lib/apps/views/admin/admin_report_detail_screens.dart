import 'package:flutter/material.dart';
import 'package:staff_attendance/widgets/app_page_widgets.dart';
import 'package:staff_attendance/widgets/app_toast.dart';

class MonthlyAttendanceReportScreen extends StatelessWidget {
  const MonthlyAttendanceReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ReportDetailScaffold(
      title: 'Monthly Attendance',
      subtitle: 'July 2026 · All departments',
      accent: Color(0xFF185FA5),
      icon: Icons.calendar_month_rounded,
      metrics: [
        _ReportMetric('Present', '486', '+4.2%'),
        _ReportMetric('Absent', '18', '-2 vs Jun'),
        _ReportMetric('Late', '42', '8.6% rate'),
        _ReportMetric('Missing checkout', '11', 'Needs review'),
      ],
      filters: ['July 2026', 'All departments', 'All staff'],
      rows: [
        _ReportRow('Operations', '156 present', '12 late · 3 absent'),
        _ReportRow('Finance', '88 present', '5 late · 1 absent'),
        _ReportRow('Engineering', '142 present', '16 late · 4 absent'),
        _ReportRow('Sales', '100 present', '9 late · 10 absent'),
      ],
    );
  }
}

class LatenessReportScreen extends StatelessWidget {
  const LatenessReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ReportDetailScaffold(
      title: 'Lateness Report',
      subtitle: 'Late minutes by staff and department',
      accent: Color(0xFFF59E0B),
      icon: Icons.timer_off_rounded,
      metrics: [
        _ReportMetric('Late cases', '42', 'This month'),
        _ReportMetric('Late minutes', '681', 'Total'),
        _ReportMetric('Avg delay', '16m', 'Per case'),
        _ReportMetric('Repeat late', '7', 'Staff'),
      ],
      filters: ['This month', 'All departments', 'Late only'],
      rows: [
        _ReportRow('Daniel Tan', 'Engineering', '6 times · 102 minutes'),
        _ReportRow('Farid Hakim', 'Sales', '5 times · 88 minutes'),
        _ReportRow('Siti Rahmah', 'Finance', '3 times · 41 minutes'),
        _ReportRow('Ahmad Nizam', 'Operations', '2 times · 23 minutes'),
      ],
    );
  }
}

class OvertimeSummaryReportScreen extends StatelessWidget {
  const OvertimeSummaryReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ReportDetailScaffold(
      title: 'Overtime Summary',
      subtitle: 'Approved, pending and rejected OT hours',
      accent: Color(0xFF16A34A),
      icon: Icons.more_time_rounded,
      metrics: [
        _ReportMetric('Approved OT', '126h', 'Payroll ready'),
        _ReportMetric('Pending OT', '18h', 'Needs approval'),
        _ReportMetric('Rejected OT', '9h', 'Policy mismatch'),
        _ReportMetric('Cost estimate', 'RM 4.8k', 'Before payroll'),
      ],
      filters: ['July 2026', 'All statuses', 'All departments'],
      rows: [
        _ReportRow('Engineering', '58h approved', '12h pending · RM 2.1k'),
        _ReportRow('Operations', '42h approved', '4h pending · RM 1.6k'),
        _ReportRow('Sales', '18h approved', '2h pending · RM 780'),
        _ReportRow('Finance', '8h approved', '0h pending · RM 320'),
      ],
    );
  }
}

class LeaveClaimSummaryReportScreen extends StatelessWidget {
  const LeaveClaimSummaryReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ReportDetailScaffold(
      title: 'Leave & Claim Summary',
      subtitle: 'Leave usage, claim totals and finance status',
      accent: Color(0xFF7F77DD),
      icon: Icons.receipt_long_rounded,
      metrics: [
        _ReportMetric('Leave taken', '74d', 'This month'),
        _ReportMetric('Leave pending', '9', 'Requests'),
        _ReportMetric('Claims total', 'RM 8.2k', 'Submitted'),
        _ReportMetric('Claims pending', 'RM 1.4k', 'Finance review'),
      ],
      filters: ['July 2026', 'Leave + Claims', 'All statuses'],
      rows: [
        _ReportRow('Annual leave', '38 days taken', '6 pending requests'),
        _ReportRow('Medical leave', '21 days taken', '3 documents pending'),
        _ReportRow('Medical claims', 'RM 3.7k submitted', 'RM 620 pending'),
        _ReportRow('Travel claims', 'RM 4.5k submitted', 'RM 780 pending'),
      ],
    );
  }
}

class _ReportDetailScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color accent;
  final IconData icon;
  final List<_ReportMetric> metrics;
  final List<String> filters;
  final List<_ReportRow> rows;

  const _ReportDetailScaffold({
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.icon,
    required this.metrics,
    required this.filters,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final text = isDark ? Colors.white : const Color(0xFF0F172A);
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            AppPageHeader(
              title: title,
              actions: [
                IconButton(
                  tooltip: 'Export report',
                  onPressed: () => AppToast.pending(
                    'Export started',
                    '$title export is being prepared.',
                  ),
                  icon: const Icon(Icons.ios_share_rounded),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _HeroCard(
              title: title,
              subtitle: subtitle,
              accent: accent,
              icon: icon,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: filters
                  .map(
                    (filter) => Chip(
                      label: Text(filter),
                      avatar: const Icon(Icons.filter_alt_rounded, size: 16),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 14),
            AppAdaptiveGrid(
              itemCount: metrics.length,
              minChildWidth: 155,
              childAspectRatio: 1.55,
              itemBuilder: (_, index) => AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      metrics[index].label,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      metrics[index].value,
                      style: TextStyle(
                        color: text,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      metrics[index].note,
                      style: TextStyle(
                        color: accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Breakdown',
              style: TextStyle(
                color: text,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            for (final row in rows)
              AppCard(
                margin: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: accent.withValues(alpha: 0.12),
                      child: Icon(Icons.analytics_rounded, color: accent),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            row.title,
                            style: TextStyle(
                              color: text,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            row.subtitle,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      row.trailing,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color accent;
  final IconData icon;
  final bool isDark;

  const _HeroCard({
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            accent,
            isDark ? const Color(0xFF1E293B) : accent.withValues(alpha: 0.72),
          ],
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white.withValues(alpha: 0.18),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.82),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportMetric {
  final String label;
  final String value;
  final String note;

  const _ReportMetric(this.label, this.value, this.note);
}

class _ReportRow {
  final String title;
  final String subtitle;
  final String trailing;

  const _ReportRow(this.title, this.subtitle, this.trailing);
}
