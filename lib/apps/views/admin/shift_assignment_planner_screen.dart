import 'package:flutter/material.dart';
import 'package:staff_attendance/widgets/app_page_widgets.dart';

class ShiftAssignmentPlannerScreen extends StatelessWidget {
  const ShiftAssignmentPlannerScreen({super.key});

  static const _days = [
    ('Mon', 'Morning Shift', '12 assigned', Color(0xFF185FA5)),
    ('Tue', 'Morning Shift', '11 assigned', Color(0xFF185FA5)),
    ('Wed', 'Remote Rotation', '4 assigned', Color(0xFF7F77DD)),
    ('Thu', 'Evening Shift', '6 assigned', Color(0xFFF59E0B)),
    ('Fri', 'Morning Shift', '12 assigned', Color(0xFF16A34A)),
    ('Sat', 'Weekend Coverage', '3 assigned', Color(0xFFD85A30)),
    ('Sun', 'Rest Day', '0 assigned', Color(0xFF94A3B8)),
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
            const AppPageHeader(title: 'Shift Assignment Planner'),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Weekly assignment board',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Use this planner to assign shifts, see coverage gaps, and prepare rest days before final roster approval.',
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
            for (final day in _days)
              AppCard(
                margin: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: day.$4.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          day.$1,
                          style: TextStyle(
                            color: day.$4,
                            fontSize: 16,
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
                            day.$2,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            day.$3,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {},
                      child: const Text('Assign'),
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
