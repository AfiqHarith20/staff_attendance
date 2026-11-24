import 'package:flutter/material.dart';
import 'package:staff_attendance/apps/services/payroll_calculator.dart';
import 'package:staff_attendance/widgets/app_page_widgets.dart';

/// A roster row used to drive the statutory totals shown on this screen.
/// Replace with real employee + salary records once a backend exists.
class _RosterEntry {
  final String name;
  final double monthlyGross;
  final EmployeeTaxProfile profile;
  const _RosterEntry(this.name, this.monthlyGross, this.profile);
}

class PayrollPrepScreen extends StatelessWidget {
  const PayrollPrepScreen({super.key});

  static final _payPeriod = DateTime(2026, 7, 1);

  static final _roster = <_RosterEntry>[
    _RosterEntry(
      'Ahmad Nizam',
      6500,
      EmployeeTaxProfile(
        dateOfBirth: DateTime(1990, 5, 10),
        isMarried: true,
        spouseHasNoIncome: true,
        numberOfChildren: 2,
      ),
    ),
    _RosterEntry(
      'Siti Rahmah',
      4800,
      EmployeeTaxProfile(dateOfBirth: DateTime(1994, 2, 18)),
    ),
    _RosterEntry(
      'Daniel Tan',
      7200,
      EmployeeTaxProfile(
        dateOfBirth: DateTime(1988, 11, 2),
        isMarried: true,
      ),
    ),
    _RosterEntry(
      'Nur Aisyah',
      5200,
      EmployeeTaxProfile(dateOfBirth: DateTime(1996, 7, 30)),
    ),
    _RosterEntry(
      'Farid Hakim',
      3900,
      EmployeeTaxProfile(dateOfBirth: DateTime(1999, 1, 14)),
    ),
  ];

  static List<PayrollBreakdown> get _breakdowns => _roster
      .map(
        (e) => PayrollCalculator.calculate(
          grossPay: e.monthlyGross,
          profile: e.profile,
          ytd: YtdPayrollSummary.zero,
          payPeriod: _payPeriod,
        ),
      )
      .toList();

  static String _rm(double value) {
    final fixed = value.toStringAsFixed(2);
    return 'RM $fixed';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final text = isDark ? Colors.white : const Color(0xFF0F172A);

    final breakdowns = _breakdowns;
    final totalGross = breakdowns.fold<double>(0, (sum, b) => sum + b.grossPay);
    final totalEpf = breakdowns.fold<double>(0, (sum, b) => sum + b.epf.total);
    final totalSocso = breakdowns.fold<double>(0, (sum, b) => sum + b.socso.total);
    final totalEis = breakdowns.fold<double>(0, (sum, b) => sum + b.eis.total);
    final totalPcb = breakdowns.fold<double>(0, (sum, b) => sum + b.pcb);
    final totalEmployerCost =
        breakdowns.fold<double>(0, (sum, b) => sum + b.employerCost);

    final metrics = [
      ('Total gross pay', _rm(totalGross), const Color(0xFF185FA5)),
      ('EPF (employee + employer)', _rm(totalEpf), const Color(0xFF16A34A)),
      ('SOCSO (employee + employer)', _rm(totalSocso), const Color(0xFFF59E0B)),
      ('EIS (employee + employer)', _rm(totalEis), const Color(0xFF0EA5E9)),
      ('PCB (income tax)', _rm(totalPcb), const Color(0xFFDC2626)),
      ('Total employer cost', _rm(totalEmployerCost), const Color(0xFFD85A30)),
    ];

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            const AppPageHeader(title: 'Payroll Prep Page'),
            const SizedBox(height: 4),
            Text(
              'Statutory totals for ${breakdowns.length} staff · '
              '${_monthLabel(_payPeriod)}',
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            AppAdaptiveGrid(
              itemCount: metrics.length,
              minChildWidth: 160,
              childAspectRatio: 1.7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              itemBuilder: (_, index) {
                final item = metrics[index];
                return AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.$2,
                        style: TextStyle(
                          color: item.$3,
                          fontSize: 20,
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
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Per-employee breakdown',
                    style: TextStyle(
                      color: text,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (var i = 0; i < _roster.length; i++)
                    _EmployeeRow(
                      name: _roster[i].name,
                      breakdown: breakdowns[i],
                      isDark: isDark,
                      isLast: i == _roster.length - 1,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ready-to-export payroll files',
                    style: TextStyle(
                      color: text,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final item in _exports)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF185FA5,
                              ).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.file_download_rounded,
                              color: Color(0xFF185FA5),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item,
                              style: TextStyle(
                                color: text,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () {},
                            child: const Text('Export'),
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

  static const _exports = [
    'Attendance-ready payroll summary',
    'Overtime totals by employee',
    'Unpaid leave deductions',
    'Late minutes adjustment sheet',
    'EPF / SOCSO / EIS contribution borang',
    'PCB (CP39) remittance file',
  ];

  static String _monthLabel(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

class _EmployeeRow extends StatelessWidget {
  final String name;
  final PayrollBreakdown breakdown;
  final bool isDark;
  final bool isLast;

  const _EmployeeRow({
    required this.name,
    required this.breakdown,
    required this.isDark,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final text = isDark ? Colors.white : const Color(0xFF0F172A);
    final sub = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: TextStyle(
                  color: text,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Net ${PayrollPrepScreen._rm(breakdown.netPay)}',
                style: const TextStyle(
                  color: Color(0xFF16A34A),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Gross ${PayrollPrepScreen._rm(breakdown.grossPay)}  ·  '
            'EPF ${PayrollPrepScreen._rm(breakdown.epf.employee)}  ·  '
            'SOCSO ${PayrollPrepScreen._rm(breakdown.socso.employee)}  ·  '
            'EIS ${PayrollPrepScreen._rm(breakdown.eis.employee)}  ·  '
            'PCB ${PayrollPrepScreen._rm(breakdown.pcb)}',
            style: TextStyle(color: sub, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
