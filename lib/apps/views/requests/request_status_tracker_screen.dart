import 'package:flutter/material.dart';
import 'package:staff_attendance/widgets/app_page_widgets.dart';

class RequestStatusTrackerScreen extends StatelessWidget {
  const RequestStatusTrackerScreen({super.key});

  static const _requests = [
    (
      'Leave',
      'Annual leave · 29 Jul 2026 to 30 Jul 2026',
      'Pending manager review',
      'Pending',
      'Submitted 2 hours ago',
      Icons.beach_access_rounded,
      Color(0xFFF59E0B),
    ),
    (
      'Overtime',
      'Weekend OT · 26 Jul 2026',
      'Approved by operations manager',
      'Approved',
      'Updated yesterday',
      Icons.more_time_rounded,
      Color(0xFF16A34A),
    ),
    (
      'Claim',
      'Transport claim · RM 84.50',
      'Finance needs clearer receipt image',
      'Needs update',
      'Returned on 22 Jul 2026',
      Icons.receipt_long_rounded,
      Color(0xFFD85A30),
    ),
    (
      'Remote Work',
      'WFH request · 31 Jul 2026',
      'Waiting for department head approval',
      'Pending',
      'Submitted on 23 Jul 2026',
      Icons.home_work_rounded,
      Color(0xFF7F77DD),
    ),
    (
      'Correction',
      'Missing checkout · 18 Jul 2026',
      'HR adjusted your attendance record',
      'Completed',
      'Resolved on 20 Jul 2026',
      Icons.edit_calendar_rounded,
      Color(0xFF185FA5),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            const AppPageHeader(title: 'Request Status Tracker'),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Track every request in one place',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Leave, overtime, claims, remote work, and correction requests are grouped here so staff can quickly see what still needs action.',
                    style: TextStyle(
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: const [
                Expanded(
                  child: _TrackerStat(
                    label: 'Pending',
                    value: '2',
                    color: Color(0xFFF59E0B),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _TrackerStat(
                    label: 'Action needed',
                    value: '1',
                    color: Color(0xFFD85A30),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _TrackerStat(
                    label: 'Completed',
                    value: '2',
                    color: Color(0xFF16A34A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            for (final request in _requests)
              _RequestStatusCard(
                type: request.$1,
                title: request.$2,
                subtitle: request.$3,
                status: request.$4,
                meta: request.$5,
                icon: request.$6,
                color: request.$7,
              ),
          ],
        ),
      ),
    );
  }
}

class _TrackerStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _TrackerStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestStatusCard extends StatelessWidget {
  final String type;
  final String title;
  final String subtitle;
  final String status;
  final String meta;
  final IconData icon;
  final Color color;

  const _RequestStatusCard({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.meta,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = switch (status) {
      'Approved' || 'Completed' => const Color(0xFF16A34A),
      'Pending' => const Color(0xFFF59E0B),
      'Needs update' => const Color(0xFFD85A30),
      _ => const Color(0xFF185FA5),
    };

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AppStatusBadge(label: type, color: color),
                    const SizedBox(width: 8),
                    AppStatusBadge(label: status, color: statusColor),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  meta,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
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
