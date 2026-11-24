import 'package:flutter_test/flutter_test.dart';
import 'package:staff_attendance/apps/services/payroll_calculator.dart';

void main() {
  // A plain local, non-senior, single, childless employee — used wherever
  // the test doesn't care about reliefs/age bands.
  final basicProfile = EmployeeTaxProfile(dateOfBirth: DateTime(1994, 1, 1));

  EmployeeTaxProfile seniorProfile({bool malaysian = true}) =>
      EmployeeTaxProfile(
        dateOfBirth: DateTime(1964, 1, 1), // age 61 at payPeriod 2025-01-01
        isMalaysianOrPermanentResident: malaysian,
      );

  final payPeriod = DateTime(2025, 1, 1);

  group('EPF', () {
    test('wage at or below RM5,000 uses 11% employee / 13% employer', () {
      final r = PayrollCalculator.epf(
        grossWage: 3000,
        profile: basicProfile,
        payPeriod: payPeriod,
      );
      expect(r.employee, 330.0); // 3000 * 11%
      expect(r.employer, 390.0); // 3000 * 13%
    });

    test('wage above RM5,000 drops employer rate to 12%', () {
      final r = PayrollCalculator.epf(
        grossWage: 8000,
        profile: basicProfile,
        payPeriod: payPeriod,
      );
      expect(r.employee, 880.0); // 8000 * 11%
      expect(r.employer, 960.0); // 8000 * 12%
    });

    test('wage above the RM20,000 ceiling is capped before computing', () {
      final r = PayrollCalculator.epf(
        grossWage: 25000,
        profile: basicProfile,
        payPeriod: payPeriod,
      );
      expect(r.employee, 2200.0); // 20000 * 11%
      expect(r.employer, 2400.0); // 20000 * 12%
    });

    test('rounding: sen portion of 0.50 or more rounds up to the ringgit', () {
      // 1050 * 11% = 115.50 -> rounds up to 116
      final r = PayrollCalculator.epf(
        grossWage: 1050,
        profile: basicProfile,
        payPeriod: payPeriod,
      );
      expect(r.employee, 116.0);
    });

    test('local employee aged 60+ contributes 0%, employer still pays 4%', () {
      final r = PayrollCalculator.epf(
        grossWage: 5000,
        profile: seniorProfile(),
        payPeriod: payPeriod,
      );
      expect(r.employee, 0.0);
      expect(r.employer, 200.0); // 5000 * 4%
    });

    test('foreign employee uses the flat 2% / 2% rate regardless of age', () {
      final r = PayrollCalculator.epf(
        grossWage: 4000,
        profile: EmployeeTaxProfile(
          dateOfBirth: DateTime(1994, 1, 1),
          isMalaysianOrPermanentResident: false,
        ),
        payPeriod: payPeriod,
      );
      expect(r.employee, 80.0);
      expect(r.employer, 80.0);
    });
  });

  group('SOCSO', () {
    test('first category (under 60) applies 0.5% / 1.75%', () {
      final r = PayrollCalculator.socso(
        grossWage: 3000,
        profile: basicProfile,
        payPeriod: payPeriod,
      );
      expect(r.employee, 15.0);
      expect(r.employer, 52.5);
    });

    test('wage above the RM6,000 ceiling is capped', () {
      final r = PayrollCalculator.socso(
        grossWage: 8000,
        profile: basicProfile,
        payPeriod: payPeriod,
      );
      expect(r.employee, 30.0); // 6000 * 0.5%
      expect(r.employer, 105.0); // 6000 * 1.75%
    });

    test('second category (60+) is employment-injury only, employer-paid', () {
      final r = PayrollCalculator.socso(
        grossWage: 5000,
        profile: seniorProfile(),
        payPeriod: payPeriod,
      );
      expect(r.employee, 0.0);
      expect(r.employer, 62.5); // 5000 * 1.25%
    });
  });

  group('EIS', () {
    test('working-age employee pays 0.2% / 0.2%', () {
      final r = PayrollCalculator.eis(
        grossWage: 4000,
        profile: basicProfile,
        payPeriod: payPeriod,
      );
      expect(r.employee, 8.0);
      expect(r.employer, 8.0);
    });

    test('wage above the RM6,000 ceiling is capped', () {
      final r = PayrollCalculator.eis(
        grossWage: 7000,
        profile: basicProfile,
        payPeriod: payPeriod,
      );
      expect(r.employee, 12.0);
      expect(r.employer, 12.0);
    });

    test('employees aged 60 or over are not covered', () {
      final r = PayrollCalculator.eis(
        grossWage: 4000,
        profile: seniorProfile(),
        payPeriod: payPeriod,
      );
      expect(r.employee, 0.0);
      expect(r.employer, 0.0);
    });

    test('employees under 18 are not covered', () {
      final r = PayrollCalculator.eis(
        grossWage: 2000,
        profile: EmployeeTaxProfile(dateOfBirth: DateTime(2012, 1, 1)),
        payPeriod: payPeriod,
      );
      expect(r.employee, 0.0);
      expect(r.employer, 0.0);
    });
  });

  group('PCB', () {
    test('matches hand-computed tax for RM6,500/mth, married, non-working '
        'spouse, 2 children (first month of the year)', () {
      final profile = EmployeeTaxProfile(
        dateOfBirth: DateTime(1990, 5, 10),
        isMarried: true,
        spouseHasNoIncome: true,
        numberOfChildren: 2,
      );
      // Projected annual gross 78,000; EPF relief capped at 4,000;
      // reliefs = 9,000 (personal) + 4,000 (EPF) + 4,000 (spouse) +
      // 4,000 (2 children) = 21,000 -> chargeable 57,000.
      // Tax = 1,500 + (57,000 - 50,000) * 11% = 2,270. 2,270 / 12 = 189.1666…
      final pcb = PayrollCalculator.pcb(
        grossWageThisMonth: 6500,
        employeeEpfThisMonth: 715, // 6500 * 11%
        profile: profile,
        ytd: YtdPayrollSummary.zero,
        payPeriodMonth: 1,
      );
      expect(pcb, 189.17);
    });

    test('income within personal relief threshold deducts no tax', () {
      final pcb = PayrollCalculator.pcb(
        grossWageThisMonth: 1500,
        employeeEpfThisMonth: 165, // 1500 * 11%
        profile: basicProfile,
        ytd: YtdPayrollSummary.zero,
        payPeriodMonth: 1,
      );
      expect(pcb, 0.0);
    });

    test('no months remaining in the year returns zero defensively', () {
      final pcb = PayrollCalculator.pcb(
        grossWageThisMonth: 10000,
        employeeEpfThisMonth: 1100,
        profile: basicProfile,
        ytd: YtdPayrollSummary.zero,
        payPeriodMonth: 13,
      );
      expect(pcb, 0.0);
    });

    test('already-deducted PCB reduces what remains due later in the year', () {
      final pcb = PayrollCalculator.pcb(
        grossWageThisMonth: 6500,
        employeeEpfThisMonth: 715,
        profile: EmployeeTaxProfile(
          dateOfBirth: DateTime(1990, 5, 10),
          isMarried: true,
          spouseHasNoIncome: true,
          numberOfChildren: 2,
        ),
        ytd: const YtdPayrollSummary(
          cumulativeGrossIncome: 71500, // 11 months * 6500
          cumulativeEmployeeEpf: 7865, // 11 months * 715
          cumulativePcbDeducted: 2080, // already paid most of the 2,270 due
        ),
        payPeriodMonth: 12,
      );
      // Only 1 month remains: remaining tax (2270 - 2080) / 1 = 190.
      expect(pcb, 190.0);
    });

    test('cumulative PCB deducted across all 12 months converges to the '
        'true annual tax despite monthly rounding', () {
      final profile = EmployeeTaxProfile(
        dateOfBirth: DateTime(1990, 5, 10),
        isMarried: true,
        spouseHasNoIncome: true,
        numberOfChildren: 2,
      );
      var ytd = YtdPayrollSummary.zero;
      for (var month = 1; month <= 12; month++) {
        final breakdown = PayrollCalculator.calculate(
          grossPay: 6500,
          profile: profile,
          ytd: ytd,
          payPeriod: DateTime(2025, month, 1),
        );
        ytd = YtdPayrollSummary(
          cumulativeGrossIncome: ytd.cumulativeGrossIncome + 6500,
          cumulativeEmployeeEpf:
              ytd.cumulativeEmployeeEpf + breakdown.epf.employee,
          cumulativePcbDeducted: ytd.cumulativePcbDeducted + breakdown.pcb,
        );
      }
      expect(ytd.cumulativePcbDeducted, closeTo(2270.0, 0.05));
    });
  });

  group('calculate() end-to-end', () {
    test('net pay equals gross minus every employee-side deduction', () {
      final profile = EmployeeTaxProfile(
        dateOfBirth: DateTime(1990, 5, 10),
        isMarried: true,
        spouseHasNoIncome: true,
        numberOfChildren: 2,
      );
      final b = PayrollCalculator.calculate(
        grossPay: 6500,
        profile: profile,
        ytd: YtdPayrollSummary.zero,
        payPeriod: DateTime(2025, 1, 1),
      );

      expect(b.grossPay, 6500.0);
      expect(b.epf.employee, 715.0);
      expect(b.socso.employee, 30.0);
      expect(b.eis.employee, 12.0);
      expect(b.pcb, 189.17);
      expect(
        b.netPay,
        6500.0 - b.epf.employee - b.socso.employee - b.eis.employee - b.pcb,
      );
      expect(b.netPay, 5553.83);
    });

    test(
      'employerCost adds the employer-side contributions on top of gross',
      () {
        final b = PayrollCalculator.calculate(
          grossPay: 3000,
          profile: basicProfile,
          ytd: YtdPayrollSummary.zero,
          payPeriod: payPeriod,
        );
        expect(
          b.employerCost,
          3000.0 + b.epf.employer + b.socso.employer + b.eis.employer,
        );
      },
    );
  });
}
