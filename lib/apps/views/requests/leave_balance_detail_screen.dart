import 'package:flutter/material.dart';
import 'package:staff_attendance/widgets/app_page_widgets.dart';

class LeaveBalanceDetailScreen extends StatelessWidget {
  const LeaveBalanceDetailScreen({super.key});

  static const _balances = [
    ('Annual Leave', '8', '14 total', '3 pending', Color(0xFF185FA5)),
    ('Medical Leave', '10', '14 total', '0 pending', Color(0xFF16A34A)),
    ('Emergency Leave', '2', '3 total', '0 pending', Color(0xFFF59E0B)),
    ('Unpaid Leave', 'Flexible', 'As approved', '1 pending', Color(0xFF7F77DD)),
  ];

  static const _history = [
    ('Annual Leave', '29 Jul 2026 - 30 Jul 2026', 'Pending', '2 day(s)'),
    ('Medical Leave', '8 Jul 2026', 'Approved', '1 day(s)'),
    ('Emergency Leave', '18 Jun 2026', 'Approved', '1 day(s)'),
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
            const AppPageHeader(title: 'Leave Balance Detail'),
            const SizedBox(height: 12),
            AppCard(
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFF185FA5).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.summarize_rounded,
                      color: Color(0xFF185FA5),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'See entitlement, remaining days, pending requests, and recent leave usage in one clear summary.',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            for (final item in _balances)
              AppCard(
                margin: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.$1,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${item.$2} left · ${item.$3}',
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppStatusBadge(label: item.$4, color: item.$5),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Text(
              'Recent leave activity',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (var i = 0; i < _history.length; i++) ...[
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _history[i].$1,
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF0F172A),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _history[i].$2,
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              AppStatusBadge(
                                label: _history[i].$3,
                                color: _history[i].$3 == 'Approved'
                                    ? const Color(0xFF16A34A)
                                    : const Color(0xFFF59E0B),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _history[i].$4,
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (i != _history.length - 1) const Divider(height: 1),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
