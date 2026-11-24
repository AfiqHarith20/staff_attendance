class BenefitModel {
  final String type;
  final String category; // "Leave" or "Insurance"

  // Leave-only fields
  final int totalDays;
  final int usedDays;
  final int remainingDays;

  // Insurance-only fields (null for leave items)
  final String? provider;
  final String? policyNo;
  final String? coverageLabel;
  final double? coverageAmount;
  final String? premiumPaidBy;
  final String? startsOn;
  final String? endsOn;
  final int? dependentsCovered;
  final bool? hasLapsed;

  bool get isInsurance => category == 'Insurance';

  const BenefitModel({
    required this.type,
    required this.category,
    this.totalDays = 0,
    this.usedDays = 0,
    this.remainingDays = 0,
    this.provider,
    this.policyNo,
    this.coverageLabel,
    this.coverageAmount,
    this.premiumPaidBy,
    this.startsOn,
    this.endsOn,
    this.dependentsCovered,
    this.hasLapsed,
  });

  factory BenefitModel.fromLeaveJson(Map<String, dynamic> json) {
    return BenefitModel(
      type: json['type'] as String? ?? '',
      category: 'Leave',
      totalDays: (json['total_days'] as num?)?.toInt() ?? 0,
      usedDays: (json['used_days'] as num?)?.toInt() ?? 0,
      remainingDays: (json['remaining_days'] as num?)?.toInt() ?? 0,
    );
  }

  factory BenefitModel.fromInsuranceJson(Map<String, dynamic> json) {
    return BenefitModel(
      type: json['type'] as String? ?? '',
      category: 'Insurance',
      provider: json['provider'] as String?,
      policyNo: json['policy_no'] as String?,
      coverageLabel: json['coverage_label'] as String?,
      coverageAmount: (json['coverage_amount'] as num?)?.toDouble(),
      premiumPaidBy: json['premium_paid_by'] as String?,
      startsOn: json['starts_on'] as String?,
      endsOn: json['ends_on'] as String?,
      dependentsCovered: (json['dependents_covered'] as num?)?.toInt(),
      hasLapsed: json['has_lapsed'] as bool?,
    );
  }

  String get displayName {
    if (type.isEmpty) return 'Unknown';
    switch (type.toLowerCase()) {
      case 'annual':
        return 'Annual Leave';
      case 'medical':
        return 'Medical Leave';
      case 'emergency':
        return 'Emergency Leave';
      case 'hospitalisation':
        return 'Hospitalisation Leave';
      case 'maternity':
        return 'Maternity Leave';
      case 'paternity':
        return 'Paternity Leave';
      case 'unpaid':
        return 'Unpaid Leave';
      default:
        // Insurance names come through as plain strings like "Life Insurance"
        return '${type[0].toUpperCase()}${type.substring(1)}';
    }
  }
}
