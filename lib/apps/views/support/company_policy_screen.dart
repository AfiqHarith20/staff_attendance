import 'package:flutter/material.dart';
import 'package:staff_attendance/widgets/app_page_widgets.dart';

class CompanyPolicyScreen extends StatelessWidget {
  const CompanyPolicyScreen({super.key});

  static const _policyCards = [
    (
      'Attendance policy',
      'Check-in, GPS radius, late rules, missing checkout and regularization flow.',
      Icons.fact_check_rounded,
      Color(0xFF185FA5),
    ),
    (
      'Leave policy',
      'Entitlements, carry forward, supporting documents and approval timing.',
      Icons.event_available_rounded,
      Color(0xFF16A34A),
    ),
    (
      'Claims policy',
      'Medical, travel and meal claims with required proof and cutoff dates.',
      Icons.receipt_long_rounded,
      Color(0xFFF59E0B),
    ),
    (
      'Remote work policy',
      'Hybrid work expectations, approval route and location requirements.',
      Icons.home_work_rounded,
      Color(0xFF7F77DD),
    ),
  ];

  static const _handbookSections = [
    (
      'Late attendance',
      '3 late check-ins in one month may trigger manager review.',
    ),
    (
      'MC upload timing',
      'Medical certificates should be uploaded on the same day or next working day.',
    ),
    (
      'Claim cutoff',
      'Claims submitted after the monthly cutoff may move to the next payroll cycle.',
    ),
    (
      'Security',
      'Do not share login credentials or check in on behalf of another staff member.',
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
            const AppPageHeader(title: 'Company Policy'),
            const SizedBox(height: 12),
            AppCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Core HR policies and handbook shortcuts',
                    style: TextStyle(
                      color: text,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'This page gives staff one clear place to review attendance, leave, claim, remote work, and basic security rules before submitting requests.',
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
              itemCount: _policyCards.length,
              minChildWidth: 170,
              childAspectRatio: 1.35,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              itemBuilder: (_, index) {
                final item = _policyCards[index];
                return AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: item.$4.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(item.$3, color: item.$4),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        item.$1,
                        style: TextStyle(
                          color: text,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.$2,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 14),
            Text(
              'Quick handbook notes',
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
                  for (var i = 0; i < _handbookSections.length; i++) ...[
                    _PolicyRow(
                      title: _handbookSections[i].$1,
                      body: _handbookSections[i].$2,
                    ),
                    if (i != _handbookSections.length - 1)
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
          ],
        ),
      ),
    );
  }
}

class _PolicyRow extends StatelessWidget {
  final String title;
  final String body;

  const _PolicyRow({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = isDark ? Colors.white : const Color(0xFF0F172A);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(color: text, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          body,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 12,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}
