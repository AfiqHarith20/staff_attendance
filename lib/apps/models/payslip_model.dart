class PayslipModel {
  final String id;
  final String monthLabel;
  final String periodLabel;
  final String netPayLabel;
  final String status;
  final String fileUrl;
  final DateTime issuedAt;

  // Statutory breakdown. These default to 0 so payslips from older API
  // responses (without a breakdown) still parse, they just show no detail.
  final double grossPay;
  final double epfEmployee;
  final double epfEmployer;
  final double socsoEmployee;
  final double socsoEmployer;
  final double eisEmployee;
  final double eisEmployer;
  final double pcb;
  final double netPay;

  const PayslipModel({
    required this.id,
    required this.monthLabel,
    required this.periodLabel,
    required this.netPayLabel,
    required this.status,
    required this.fileUrl,
    required this.issuedAt,
    this.grossPay = 0,
    this.epfEmployee = 0,
    this.epfEmployer = 0,
    this.socsoEmployee = 0,
    this.socsoEmployer = 0,
    this.eisEmployee = 0,
    this.eisEmployer = 0,
    this.pcb = 0,
    this.netPay = 0,
  });

  /// Whether the statutory breakdown is available to display.
  bool get hasBreakdown => grossPay > 0;

  double get totalEmployeeDeductions =>
      epfEmployee + socsoEmployee + eisEmployee + pcb;

  factory PayslipModel.fromJson(Map<String, dynamic> json) {
    double asDouble(dynamic value) =>
        value == null ? 0 : (value as num).toDouble();

    return PayslipModel(
      id: json['id'].toString(),
      monthLabel: json['month_label'] as String? ?? '',
      periodLabel: json['period_label'] as String? ?? '',
      netPayLabel: json['net_pay_label'] as String? ?? 'RM 0.00',
      status: json['status'] as String? ?? 'Ready',
      fileUrl: json['file_url'] as String? ?? '',
      issuedAt:
          (DateTime.tryParse(json['issued_at'] as String? ?? '') ??
          DateTime.now()).toLocal(),
      grossPay: asDouble(json['gross_pay']),
      epfEmployee: asDouble(json['epf_employee']),
      epfEmployer: asDouble(json['epf_employer']),
      socsoEmployee: asDouble(json['socso_employee']),
      socsoEmployer: asDouble(json['socso_employer']),
      eisEmployee: asDouble(json['eis_employee']),
      eisEmployer: asDouble(json['eis_employer']),
      pcb: asDouble(json['pcb']),
      netPay: asDouble(json['net_pay']),
    );
  }
}
