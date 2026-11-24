/// Malaysian statutory payroll calculator: EPF (KWSP), SOCSO (PERKESO),
/// EIS (SIP) and PCB/MTD (monthly tax deduction).
///
/// Rates below reflect the schedules in force as of late 2025 / early 2026.
/// EPF, SOCSO and EIS rates and wage ceilings are revised periodically by
/// KWSP/PERKESO, and LHDN reissues the PCB tax brackets and relief amounts
/// every year of assessment — review `StatutoryRates` and the tax table in
/// [PayrollCalculator._taxBrackets] at the start of each year.
///
/// PCB here uses LHDN's "Computerised Calculation Method" (the same formula
/// behind e-PCB): it projects the employee's full-year chargeable income from
/// year-to-date figures, works out the annual tax on that projection, then
/// spreads the remaining liability over the months left in the year. This is
/// an approximation of the official method for straightforward monthly-salary
/// cases — bonuses, arrears, TP1/TP3 adjustments and edge cases are not
/// modelled. For legally-binding filing, always reconcile against LHDN's
/// own calculator (calcpcb.hasil.gov.my) or the official Jadual PCB.
library;

/// Marital/dependant profile needed to apply the correct PCB tax reliefs.
class EmployeeTaxProfile {
  final DateTime dateOfBirth;

  /// Malaysian citizens and Permanent Residents follow the standard EPF
  /// rate table; everyone else (foreign workers) uses the flat foreign rate.
  final bool isMalaysianOrPermanentResident;

  final bool isMarried;

  /// Only relevant when [isMarried] is true: whether the spouse has no
  /// income of their own (unlocks the RM4,000 spouse relief).
  final bool spouseHasNoIncome;

  /// Number of qualifying children (basic RM2,000/child relief). Higher
  /// education / disabled-child reliefs are not modelled here.
  final int numberOfChildren;

  const EmployeeTaxProfile({
    required this.dateOfBirth,
    this.isMalaysianOrPermanentResident = true,
    this.isMarried = false,
    this.spouseHasNoIncome = false,
    this.numberOfChildren = 0,
  });

  int ageAt(DateTime date) {
    var age = date.year - dateOfBirth.year;
    final hadBirthdayThisYear =
        (date.month > dateOfBirth.month) ||
        (date.month == dateOfBirth.month && date.day >= dateOfBirth.day);
    if (!hadBirthdayThisYear) age -= 1;
    return age;
  }
}

/// Year-to-date totals carried forward from the employee's previous
/// payslips in the same calendar year, needed because PCB is a cumulative
/// (not single-month) calculation.
class YtdPayrollSummary {
  /// Sum of gross taxable remuneration paid in prior months this year.
  final double cumulativeGrossIncome;

  /// Sum of the employee's own EPF contributions in prior months this year.
  final double cumulativeEmployeeEpf;

  /// Sum of PCB already deducted in prior months this year.
  final double cumulativePcbDeducted;

  const YtdPayrollSummary({
    this.cumulativeGrossIncome = 0,
    this.cumulativeEmployeeEpf = 0,
    this.cumulativePcbDeducted = 0,
  });

  static const zero = YtdPayrollSummary();
}

class StatutoryAmount {
  final double employee;
  final double employer;
  const StatutoryAmount({required this.employee, required this.employer});
  double get total => employee + employer;
}

class PayrollBreakdown {
  final double grossPay;
  final StatutoryAmount epf;
  final StatutoryAmount socso;
  final StatutoryAmount eis;
  final double pcb;
  final double netPay;

  const PayrollBreakdown({
    required this.grossPay,
    required this.epf,
    required this.socso,
    required this.eis,
    required this.pcb,
    required this.netPay,
  });

  /// Total employer cost (gross pay + employer-side statutory contributions).
  double get employerCost => grossPay + epf.employer + socso.employer + eis.employer;
}

/// Current statutory rates and wage ceilings. Update these at the start of
/// each year against the official KWSP/PERKESO/LHDN schedules.
class StatutoryRates {
  // --- EPF (KWSP) ---
  static const epfWageCeiling = 20000.0;
  static const epfEmployeeRateStandard = 0.11;
  static const epfEmployerRateLowWage = 0.13; // wage <= RM5,000
  static const epfEmployerRateHighWage = 0.12; // wage > RM5,000
  static const epfLowWageThreshold = 5000.0;
  static const epfEmployeeRateSenior = 0.0; // age >= 60, local
  static const epfEmployerRateSenior = 0.04; // age >= 60, local
  static const epfForeignRate = 0.02; // both sides, foreign employee

  // --- SOCSO (PERKESO) ---
  static const socsoWageCeiling = 6000.0;
  static const socsoEmployeeRate = 0.005; // 1st category, age < 60
  static const socsoEmployerRateFull = 0.0175; // 1st category, age < 60
  static const socsoEmployerRateInjuryOnly = 0.0125; // 2nd category, age >= 60
  static const socsoSeniorAge = 60;

  // --- EIS (SIP) ---
  static const eisWageCeiling = 6000.0;
  static const eisRate = 0.002; // both sides
  static const eisMinAge = 18;
  static const eisMaxAge = 60; // not covered once 60 or over

  // --- PCB / income tax reliefs (per year of assessment) ---
  static const pcbPersonalRelief = 9000.0;
  static const pcbSpouseRelief = 4000.0;
  static const pcbChildRelief = 2000.0;
  static const pcbEpfReliefCap = 4000.0;
  static const pcbRebateThreshold = 35000.0;
  static const pcbRebateAmount = 400.0;
}

class PayrollCalculator {
  const PayrollCalculator._();

  /// EPF rounding rule: the sen portion of the contribution is rounded to
  /// the next ringgit once it reaches 50 sen or more, otherwise dropped.
  static double _roundToRinggit(double amount) {
    final ringgit = amount.floor();
    final sen = amount - ringgit;
    return (sen >= 0.5 ? ringgit + 1 : ringgit).toDouble();
  }

  static double _roundCents(double amount) =>
      (amount * 100).round() / 100;

  /// EPF (KWSP) — monthly contribution split.
  static StatutoryAmount epf({
    required double grossWage,
    required EmployeeTaxProfile profile,
    required DateTime payPeriod,
  }) {
    final wage = grossWage > StatutoryRates.epfWageCeiling
        ? StatutoryRates.epfWageCeiling
        : grossWage;
    final age = profile.ageAt(payPeriod);

    if (!profile.isMalaysianOrPermanentResident) {
      final amount = _roundToRinggit(wage * StatutoryRates.epfForeignRate);
      return StatutoryAmount(employee: amount, employer: amount);
    }

    if (age >= StatutoryRates.socsoSeniorAge) {
      return StatutoryAmount(
        employee: _roundToRinggit(wage * StatutoryRates.epfEmployeeRateSenior),
        employer: _roundToRinggit(wage * StatutoryRates.epfEmployerRateSenior),
      );
    }

    final employerRate = wage <= StatutoryRates.epfLowWageThreshold
        ? StatutoryRates.epfEmployerRateLowWage
        : StatutoryRates.epfEmployerRateHighWage;

    return StatutoryAmount(
      employee: _roundToRinggit(wage * StatutoryRates.epfEmployeeRateStandard),
      employer: _roundToRinggit(wage * employerRate),
    );
  }

  /// SOCSO (PERKESO) — approximates the official wage-band contribution
  /// table using the underlying percentages. For exact sen-matching against
  /// the gazette table, swap this for the published wage bands.
  static StatutoryAmount socso({
    required double grossWage,
    required EmployeeTaxProfile profile,
    required DateTime payPeriod,
  }) {
    final wage = grossWage > StatutoryRates.socsoWageCeiling
        ? StatutoryRates.socsoWageCeiling
        : grossWage;
    final age = profile.ageAt(payPeriod);

    if (age >= StatutoryRates.socsoSeniorAge) {
      return StatutoryAmount(
        employee: 0,
        employer: _roundCents(wage * StatutoryRates.socsoEmployerRateInjuryOnly),
      );
    }

    return StatutoryAmount(
      employee: _roundCents(wage * StatutoryRates.socsoEmployeeRate),
      employer: _roundCents(wage * StatutoryRates.socsoEmployerRateFull),
    );
  }

  /// EIS (SIP) — approximates the official wage-band table via percentage.
  static StatutoryAmount eis({
    required double grossWage,
    required EmployeeTaxProfile profile,
    required DateTime payPeriod,
  }) {
    final age = profile.ageAt(payPeriod);
    if (age < StatutoryRates.eisMinAge || age >= StatutoryRates.eisMaxAge) {
      return const StatutoryAmount(employee: 0, employer: 0);
    }

    final wage = grossWage > StatutoryRates.eisWageCeiling
        ? StatutoryRates.eisWageCeiling
        : grossWage;
    final amount = _roundCents(wage * StatutoryRates.eisRate);
    return StatutoryAmount(employee: amount, employer: amount);
  }

  /// Resident individual progressive tax brackets (YA 2025/2026), as
  /// (chargeable income threshold, cumulative tax at that threshold, rate on
  /// the excess above it).
  static const _taxBrackets = <(double, double, double)>[
    (0, 0, 0.00),
    (5000, 0, 0.01),
    (20000, 150, 0.03),
    (35000, 600, 0.06),
    (50000, 1500, 0.11),
    (70000, 3700, 0.19),
    (100000, 9400, 0.25),
    (400000, 84400, 0.26),
    (600000, 136400, 0.28),
    (2000000, 528400, 0.30),
  ];

  static double _annualTaxOn(double chargeableIncome) {
    if (chargeableIncome <= 0) return 0;
    var bracket = _taxBrackets.first;
    for (final b in _taxBrackets) {
      if (chargeableIncome >= b.$1) {
        bracket = b;
      } else {
        break;
      }
    }
    final tax = bracket.$2 + (chargeableIncome - bracket.$1) * bracket.$3;
    return tax < 0 ? 0 : tax;
  }

  /// PCB/MTD — computerised (cumulative projection) method.
  ///
  /// [payPeriodMonth] is 1-12 for the month this payslip covers.
  static double pcb({
    required double grossWageThisMonth,
    required double employeeEpfThisMonth,
    required EmployeeTaxProfile profile,
    required YtdPayrollSummary ytd,
    required int payPeriodMonth,
  }) {
    final monthsRemaining = 13 - payPeriodMonth; // includes current month
    if (monthsRemaining <= 0) return 0;

    final projectedAnnualGross =
        ytd.cumulativeGrossIncome + grossWageThisMonth * monthsRemaining;
    final projectedAnnualEpf =
        ytd.cumulativeEmployeeEpf + employeeEpfThisMonth * monthsRemaining;
    final epfRelief = projectedAnnualEpf > StatutoryRates.pcbEpfReliefCap
        ? StatutoryRates.pcbEpfReliefCap
        : projectedAnnualEpf;

    var reliefs = StatutoryRates.pcbPersonalRelief + epfRelief;
    if (profile.isMarried && profile.spouseHasNoIncome) {
      reliefs += StatutoryRates.pcbSpouseRelief;
    }
    reliefs += StatutoryRates.pcbChildRelief * profile.numberOfChildren;

    final chargeableIncome = projectedAnnualGross - reliefs;
    var annualTax = _annualTaxOn(chargeableIncome);

    if (chargeableIncome <= StatutoryRates.pcbRebateThreshold) {
      annualTax = annualTax - StatutoryRates.pcbRebateAmount;
      if (annualTax < 0) annualTax = 0;
    }

    final remainingTax = annualTax - ytd.cumulativePcbDeducted;
    if (remainingTax <= 0) return 0;

    return _roundCents(remainingTax / monthsRemaining);
  }

  /// Convenience: computes the full statutory breakdown and net pay for one
  /// payslip in a single call.
  static PayrollBreakdown calculate({
    required double grossPay,
    required EmployeeTaxProfile profile,
    required YtdPayrollSummary ytd,
    required DateTime payPeriod,
  }) {
    final epfAmount = epf(grossWage: grossPay, profile: profile, payPeriod: payPeriod);
    final socsoAmount = socso(grossWage: grossPay, profile: profile, payPeriod: payPeriod);
    final eisAmount = eis(grossWage: grossPay, profile: profile, payPeriod: payPeriod);
    final pcbAmount = pcb(
      grossWageThisMonth: grossPay,
      employeeEpfThisMonth: epfAmount.employee,
      profile: profile,
      ytd: ytd,
      payPeriodMonth: payPeriod.month,
    );

    final netPay = grossPay -
        epfAmount.employee -
        socsoAmount.employee -
        eisAmount.employee -
        pcbAmount;

    return PayrollBreakdown(
      grossPay: grossPay,
      epf: epfAmount,
      socso: socsoAmount,
      eis: eisAmount,
      pcb: pcbAmount,
      netPay: _roundCents(netPay),
    );
  }
}
