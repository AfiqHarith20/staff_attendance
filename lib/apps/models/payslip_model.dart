class PayslipModel {
  final String id;
  final String monthLabel;
  final String periodLabel;
  final String netPayLabel;
  final String status;
  final String fileUrl;
  final DateTime issuedAt;

  const PayslipModel({
    required this.id,
    required this.monthLabel,
    required this.periodLabel,
    required this.netPayLabel,
    required this.status,
    required this.fileUrl,
    required this.issuedAt,
  });

  factory PayslipModel.fromJson(Map<String, dynamic> json) {
    return PayslipModel(
      id: json['id'].toString(),
      monthLabel: json['month_label'] as String? ?? '',
      periodLabel: json['period_label'] as String? ?? '',
      netPayLabel: json['net_pay_label'] as String? ?? 'RM 0.00',
      status: json['status'] as String? ?? 'Ready',
      fileUrl: json['file_url'] as String? ?? '',
      issuedAt:
          DateTime.tryParse(json['issued_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
