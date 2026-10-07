import 'package:flutter/material.dart';
import 'package:staff_attendance/widgets/app_page_widgets.dart';

class HolidayCalendarManagementScreen extends StatelessWidget {
  const HolidayCalendarManagementScreen({super.key});

  static const _holidays = [
    ('31 Aug 2026', 'National Day', 'National', Color(0xFF185FA5)),
    ('16 Sep 2026', 'Malaysia Day', 'National', Color(0xFF16A34A)),
    (
      '9 Nov 2026',
      'Deepavali Replacement',
      'Federal / company',
      Color(0xFFF59E0B),
    ),
    (
      '24 Dec 2026',
      'Company Year-End Closure',
      'Company custom',
      Color(0xFF7F77DD),
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
            const AppPageHeader(title: 'Holiday / Calendar Management'),
            const SizedBox(height: 12),
            AppCard(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Manage national holidays, company replacement holidays, and branch-specific off days for future scheduling.',
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFFCBD5E1)
                            : const Color(0xFF64748B),
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            for (final item in _holidays)
              AppCard(
                margin: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: item.$4.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.event_rounded,
                        color: Color(0xFF185FA5),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.$2,
                            style: TextStyle(
                              color: text,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${item.$1} · ${item.$3}',
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.edit_rounded),
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
