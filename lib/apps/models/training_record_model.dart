class TrainingRecordModel {
  final int id;
  final String title;
  final String? provider;
  final String type;
  final String typeLabel;
  final String fundedBy;
  final String fundedByLabel;
  final String completedOn;
  final String? expiryDate;
  final double? cost;
  final String? certificateUrl;
  final String? notes;
  final String? verifiedAt;
  final bool isExpired;
  final bool isExpiringSoon;

  const TrainingRecordModel({
    required this.id,
    required this.title,
    this.provider,
    required this.type,
    required this.typeLabel,
    required this.fundedBy,
    required this.fundedByLabel,
    required this.completedOn,
    this.expiryDate,
    this.cost,
    this.certificateUrl,
    this.notes,
    this.verifiedAt,
    required this.isExpired,
    required this.isExpiringSoon,
  });

  factory TrainingRecordModel.fromJson(Map<String, dynamic> json) =>
      TrainingRecordModel(
        id: json['id'] as int,
        title: json['title'] as String? ?? '',
        provider: json['provider'] as String?,
        type: json['type'] as String? ?? '',
        typeLabel: json['type_label'] as String? ?? '',
        fundedBy: json['funded_by'] as String? ?? '',
        fundedByLabel: json['funded_by_label'] as String? ?? '',
        completedOn: json['completed_on'] as String? ?? '',
        expiryDate: json['expiry_date'] as String?,
        cost: (json['cost'] as num?)?.toDouble(),
        certificateUrl: json['certificate_url'] as String?,
        notes: json['notes'] as String?,
        verifiedAt: json['verified_at'] as String?,
        isExpired: json['is_expired'] as bool? ?? false,
        isExpiringSoon: json['is_expiring_soon'] as bool? ?? false,
      );
}
