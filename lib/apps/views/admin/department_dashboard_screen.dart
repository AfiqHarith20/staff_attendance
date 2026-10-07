import 'package:flutter/material.dart';
import 'package:staff_attendance/widgets/app_page_widgets.dart';

class DepartmentDashboardScreen extends StatelessWidget {
  const DepartmentDashboardScreen({super.key});

  static const _topMetrics = [
    ('Departments', '6', Color(0xFF185FA5)),
    ('Present today', '512', Color(0xFF16A34A)),
    ('Open exceptions', '18', Color(0xFFF59E0B)),
    ('On leave', '27', Color(0xFF7F77DD)),
  ];

  static const _departments = [
    (
      'Operations',
      '156 present',
      '12 late · 3 absent · 4 OT pending',
      Color(0xFF185FA5),
    ),
    (
      'Engineering',
      '142 present',
      '16 late · 4 absent · 8 OT pending',
      Color(0xFF7F77DD),
    ),
    (
      'Sales',
      '100 present',
      '9 late · 10 absent · 3 claims pending',
      Color(0xFF16A34A),
    ),
    (
      'Finance',
      '88 present',
      '5 late · 1 absent · 2 leave pending',
      Color(0xFFF59E0B),
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
            AppPageHeader(
              title: 'Department Dashboard',
              actions: [
                IconButton(
                  tooltip: 'Export dashboard',
                  onPressed: () {},
                  icon: const Icon(Icons.ios_share_rounded),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AppCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Compare attendance and request load by department',
                    style: TextStyle(
                      color: text,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Higher roles can spot which departments are carrying the most lateness, absences, overtime, or pending approvals before drilling into detail.',
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
              itemCount: _topMetrics.length,
              minChildWidth: 150,
              childAspectRatio: 1.7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              itemBuilder: (_, index) {
                final item = _topMetrics[index];
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
              'Department breakdown',
              style: TextStyle(
                color: text,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            for (final item in _departments)
              AppCard(
                margin: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: item.$4.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.apartment_rounded, color: item.$4),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.$1,
                            style: TextStyle(
                              color: text,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.$2,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 6),
                          AppStatusBadge(label: item.$3, color: item.$4),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: isDark
                          ? const Color(0xFF64748B)
                          : const Color(0xFFCBD5E1),
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
