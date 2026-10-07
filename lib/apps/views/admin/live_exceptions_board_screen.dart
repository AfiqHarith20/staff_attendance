import 'package:flutter/material.dart';
import 'package:staff_attendance/widgets/app_page_widgets.dart';

class LiveExceptionsBoardScreen extends StatelessWidget {
  const LiveExceptionsBoardScreen({super.key});

  static const _exceptions = [
    (
      'No checkout',
      'Alicia Tan · Finance',
      'Checked in 8:54 AM but no checkout yet',
      'Needs follow-up',
      Color(0xFFD85A30),
    ),
    (
      'Outside GPS radius',
      'Faris Hakim · Operations',
      'Checked in 310m outside office radius',
      'Review location proof',
      Color(0xFFF59E0B),
    ),
    (
      'Late arrival',
      'Nur Iman · Support',
      'Arrived 27 minutes after shift start',
      'Monitor pattern',
      Color(0xFF185FA5),
    ),
    (
      'Absent',
      'Daniel Lee · Warehouse',
      'No check-in and no leave record today',
      'Escalate to manager',
      Color(0xFFDC2626),
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
            const AppPageHeader(title: 'Live Exceptions Board'),
            const SizedBox(height: 12),
            Row(
              children: const [
                Expanded(
                  child: _MiniExceptionStat(
                    label: 'Open',
                    value: '4',
                    color: Color(0xFFDC2626),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _MiniExceptionStat(
                    label: 'High risk',
                    value: '2',
                    color: Color(0xFFF59E0B),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _MiniExceptionStat(
                    label: 'Resolved today',
                    value: '7',
                    color: Color(0xFF16A34A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            for (final item in _exceptions)
              AppCard(
                margin: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AppStatusBadge(label: item.$1, color: item.$5),
                        const Spacer(),
                        Text(
                          'Today',
                          style: TextStyle(
                            color: item.$5,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item.$2,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.$3,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.$4,
                      style: TextStyle(
                        color: item.$5,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
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

class _MiniExceptionStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniExceptionStat({
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
