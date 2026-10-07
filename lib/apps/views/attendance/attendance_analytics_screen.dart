import 'package:flutter/material.dart';
import 'package:staff_attendance/widgets/app_page_widgets.dart';

class AttendanceAnalyticsScreen extends StatelessWidget {
  const AttendanceAnalyticsScreen({super.key});

  static const _trendRows = [
    ('Mon', '8:57 AM avg check-in', '0 late', Color(0xFF16A34A)),
    ('Tue', '9:05 AM avg check-in', '2 late', Color(0xFFF59E0B)),
    ('Wed', '8:53 AM avg check-in', '0 late', Color(0xFF16A34A)),
    ('Thu', '9:11 AM avg check-in', '3 late', Color(0xFFDC2626)),
    ('Fri', '8:59 AM avg check-in', '1 late', Color(0xFF185FA5)),
  ];

  static const _insights = [
    ('Attendance score', '92%', Color(0xFF16A34A)),
    ('Average check-in', '8:59 AM', Color(0xFF185FA5)),
    ('Overtime trend', '+6.5h', Color(0xFF7F77DD)),
    ('Late pattern', 'Mostly Thu', Color(0xFFF59E0B)),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final text = isDark ? Colors.white : const Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            const AppPageHeader(title: 'Attendance Analytics'),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'See your attendance patterns',
                    style: TextStyle(
                      color: text,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Track check-in habits, lateness by weekday, attendance score, and overtime trend so staff can spot patterns early.',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            AppAdaptiveGrid(
              itemCount: _insights.length,
              minChildWidth: 150,
              childAspectRatio: 1.7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              itemBuilder: (_, index) {
                final item = _insights[index];
                return AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.$2,
                        style: TextStyle(
                          color: item.$3,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.$1,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Weekday pattern',
              style: TextStyle(
                color: text,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            for (final row in _trendRows)
              AppCard(
                margin: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: row.$4.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          row.$1,
                          style: TextStyle(
                            color: row.$4,
                            fontWeight: FontWeight.w900,
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
                            row.$2,
                            style: TextStyle(
                              color: text,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            row.$3,
                            style: TextStyle(
                              color: row.$4,
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
          ],
        ),
      ),
    );
  }
}
