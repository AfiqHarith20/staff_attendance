import 'package:flutter/material.dart';
import 'package:staff_attendance/widgets/app_page_widgets.dart';

class AttendanceRegularizationReviewScreen extends StatelessWidget {
  const AttendanceRegularizationReviewScreen({super.key});

  static const _items = [
    (
      'Missing checkout',
      'Nur Iman · 22 Jul 2026',
      'Staff forgot to checkout after offsite visit.',
      'Pending HR review',
      Color(0xFFF59E0B),
    ),
    (
      'Wrong location',
      'Faris Hakim · 23 Jul 2026',
      'Checked in outside radius but attached manager note.',
      'Needs manual adjustment',
      Color(0xFFD85A30),
    ),
    (
      'Missed check-in',
      'Alicia Tan · 18 Jul 2026',
      'System outage reported during morning arrival.',
      'Ready to approve',
      Color(0xFF16A34A),
    ),
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
            const AppPageHeader(title: 'Attendance Regularization Review'),
            const SizedBox(height: 12),
            AppCard(
              child: const Text(
                'Review attendance correction requests, check supporting notes, and prepare manual attendance adjustments before final approval.',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(height: 14),
            for (final item in _items)
              AppCard(
                margin: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppStatusBadge(label: item.$1, color: item.$5),
                    const SizedBox(height: 10),
                    Text(
                      item.$2,
                      style: TextStyle(
                        color: text,
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
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            child: const Text('Review detail'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {},
                            child: const Text('Approve adjustment'),
                          ),
                        ),
                      ],
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
