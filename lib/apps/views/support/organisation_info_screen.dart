import 'package:flutter/material.dart';
import 'package:staff_attendance/widgets/app_page_widgets.dart';

class OrganisationInfoScreen extends StatelessWidget {
  const OrganisationInfoScreen({super.key});

  static const _branches = [
    (
      'HQ Kuala Lumpur',
      'Level 18, Menara South Point',
      'GPS radius 250m · Mon-Fri 9:00 AM-6:00 PM',
      Color(0xFF185FA5),
    ),
    (
      'Penang Branch',
      'Bayan Lepas Operations Hub',
      'GPS radius 180m · Mon-Fri 8:30 AM-5:30 PM',
      Color(0xFF16A34A),
    ),
    (
      'Johor Branch',
      'Tebrau Sales & Support Office',
      'GPS radius 200m · Mon-Fri 9:00 AM-6:00 PM',
      Color(0xFF7F77DD),
    ),
  ];

  static const _contacts = [
    ('HR helpdesk', 'hr@clokk.app', Icons.support_agent_rounded),
    ('Payroll support', 'payroll@clokk.app', Icons.payments_rounded),
    ('Emergency line', '+60 3-5555 0101', Icons.local_phone_rounded),
    ('Security desk', '+60 3-5555 0108', Icons.shield_rounded),
  ];

  static const _quickRules = [
    ('Check-in radius', 'You must be within your assigned office radius.'),
    ('Late threshold', 'Late is counted after your shift start time.'),
    ('Missing checkout', 'Submit a correction request before 12 PM next day.'),
    ('Public holiday', 'Public holidays follow your assigned branch calendar.'),
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
            const AppPageHeader(title: 'Organisation'),
            const SizedBox(height: 12),
            AppCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Office, branch and contact info in one place',
                    style: TextStyle(
                      color: text,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Staff can quickly check assigned office radius, branch working hours, HR contacts, and emergency support numbers without jumping between pages.',
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
            Text(
              'Branch directory',
              style: TextStyle(
                color: text,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            for (final branch in _branches)
              AppCard(
                margin: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: branch.$4.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.location_city_rounded,
                        color: branch.$4,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            branch.$1,
                            style: TextStyle(
                              color: text,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            branch.$2,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 6),
                          AppStatusBadge(label: branch.$3, color: branch.$4),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 6),
            Text(
              'Important rules',
              style: TextStyle(
                color: text,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            AppCard(
              child: Column(
                children: [
                  for (var i = 0; i < _quickRules.length; i++) ...[
                    _InfoLine(
                      title: _quickRules[i].$1,
                      subtitle: _quickRules[i].$2,
                    ),
                    if (i != _quickRules.length - 1)
                      Divider(
                        height: 18,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : const Color(0xFFE2E8F0),
                      ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Contacts',
              style: TextStyle(
                color: text,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            AppAdaptiveGrid(
              itemCount: _contacts.length,
              minChildWidth: 170,
              childAspectRatio: 1.65,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              itemBuilder: (_, index) {
                final item = _contacts[index];
                return AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF185FA5,
                          ).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(item.$3, color: const Color(0xFF185FA5)),
                      ),
                      const Spacer(),
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
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final String title;
  final String subtitle;

  const _InfoLine({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = isDark ? Colors.white : const Color(0xFF0F172A);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 5),
          decoration: const BoxDecoration(
            color: Color(0xFF185FA5),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: text, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
