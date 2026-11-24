enum ClaimCategory { general, travel }

enum ClaimType {
  // General
  medical,
  transport,
  meal,
  accommodation,
  officeExpenses,
  // Travel
  mileage,
  fixedLimit,
  oneShot,
}

enum ClaimStatus { draft, pending, approved, rejected }

class MileageRates {
  final double carFirst;
  final double carSubsequent;
  final double motoFirst;
  final double motoSubsequent;
  final double tierThresholdKm;

  const MileageRates({
    required this.carFirst,
    required this.carSubsequent,
    required this.motoFirst,
    required this.motoSubsequent,
    required this.tierThresholdKm,
  });

  factory MileageRates.fromJson(Map<String, dynamic> j) {
    final rates = j['rates'] as Map<String, dynamic>;
    final car = rates['car'] as Map<String, dynamic>;
    final moto = rates['motorbike'] as Map<String, dynamic>;
    return MileageRates(
      carFirst: (car['first'] as num).toDouble(),
      carSubsequent: (car['subsequent'] as num).toDouble(),
      motoFirst: (moto['first'] as num).toDouble(),
      motoSubsequent: (moto['subsequent'] as num).toDouble(),
      tierThresholdKm: (j['tier_threshold_km'] as num).toDouble(),
    );
  }

  double calculate({required String vehicle, required double distanceKm}) {
    final first = vehicle == 'car' ? carFirst : motoFirst;
    final sub = vehicle == 'car' ? carSubsequent : motoSubsequent;
    if (distanceKm <= tierThresholdKm) return distanceKm * first;
    return tierThresholdKm * first + (distanceKm - tierThresholdKm) * sub;
  }

  String rateNote(String vehicle) {
    final f = (vehicle == 'car' ? carFirst : motoFirst).toStringAsFixed(2);
    final s = (vehicle == 'car' ? carSubsequent : motoSubsequent).toStringAsFixed(2);
    return 'RM $f/km (first ${tierThresholdKm.toInt()} km) · RM $s/km after';
  }
}

class ClaimModel {
  final String id;
  final ClaimType type;
  final ClaimCategory category;
  final ClaimStatus status;
  final double amount;
  final String? description;
  final DateTime claimDate;
  final DateTime submittedAt;
  final String? receiptUrl;
  final String? receiptFileName;
  final String? rejectionNote;
  final String? approvedBy;
  final String? travelFrom;
  final String? travelTo;
  final String? travelPurpose;
  final String? vehicleType;
  final double? distanceKm;

  const ClaimModel({
    required this.id,
    required this.type,
    required this.category,
    required this.status,
    required this.amount,
    required this.description,
    required this.claimDate,
    required this.submittedAt,
    this.receiptUrl,
    this.receiptFileName,
    this.rejectionNote,
    this.approvedBy,
    this.travelFrom,
    this.travelTo,
    this.travelPurpose,
    this.vehicleType,
    this.distanceKm,
  });

  factory ClaimModel.fromJson(Map<String, dynamic> j) => ClaimModel(
    id: j['id'].toString(),
    type: _typeFromString(j['type'] as String? ?? ''),
    category: (j['category'] as String?) == 'travel'
        ? ClaimCategory.travel
        : ClaimCategory.general,
    status: ClaimStatus.values.firstWhere(
      (e) => e.name == j['status'],
      orElse: () => ClaimStatus.pending,
    ),
    amount: (j['amount'] as num).toDouble(),
    description: j['description'] as String?,
    claimDate: DateTime.parse(j['claim_date'] as String),
    submittedAt: DateTime.parse(j['submitted_at'] as String).toLocal(),
    receiptUrl: j['receipt_url'] as String?,
    receiptFileName: j['receipt_file_name'] as String?,
    rejectionNote: j['rejection_note'] as String?,
    approvedBy: j['approved_by'] as String?,
    travelFrom: j['travel_from'] as String?,
    travelTo: j['travel_to'] as String?,
    travelPurpose: j['travel_purpose'] as String?,
    vehicleType: j['vehicle_type'] as String?,
    distanceKm: j['distance_km'] != null
        ? (j['distance_km'] as num).toDouble()
        : null,
  );

  static ClaimType _typeFromString(String s) => const {
    'medical': ClaimType.medical,
    'transport': ClaimType.transport,
    'meal': ClaimType.meal,
    'accommodation': ClaimType.accommodation,
    'office_expenses': ClaimType.officeExpenses,
    'mileage': ClaimType.mileage,
    'fixed_limit': ClaimType.fixedLimit,
    'one_shot': ClaimType.oneShot,
  }[s] ?? ClaimType.medical;

  static String typeToApi(ClaimType t) => const {
    ClaimType.medical: 'medical',
    ClaimType.transport: 'transport',
    ClaimType.meal: 'meal',
    ClaimType.accommodation: 'accommodation',
    ClaimType.officeExpenses: 'office_expenses',
    ClaimType.mileage: 'mileage',
    ClaimType.fixedLimit: 'fixed_limit',
    ClaimType.oneShot: 'one_shot',
  }[t]!;

  static const typeLabels = {
    ClaimType.medical: 'claim_medical',
    ClaimType.transport: 'claim_transport',
    ClaimType.meal: 'claim_meal',
    ClaimType.accommodation: 'claim_accommodation',
    ClaimType.officeExpenses: 'claim_office_expenses',
    ClaimType.mileage: 'claim_mileage',
    ClaimType.fixedLimit: 'claim_fixed_limit',
    ClaimType.oneShot: 'claim_one_shot',
  };

  static const typeColors = {
    ClaimType.medical: 0xFF185FA5,
    ClaimType.transport: 0xFF16A34A,
    ClaimType.meal: 0xFFF59E0B,
    ClaimType.accommodation: 0xFF7F77DD,
    ClaimType.officeExpenses: 0xFF64748B,
    ClaimType.mileage: 0xFF16A34A,
    ClaimType.fixedLimit: 0xFF185FA5,
    ClaimType.oneShot: 0xFFF59E0B,
  };

  static const statusColors = {
    ClaimStatus.draft: 0xFF64748B,
    ClaimStatus.pending: 0xFFF59E0B,
    ClaimStatus.approved: 0xFF16A34A,
    ClaimStatus.rejected: 0xFFDC2626,
  };

  static const statusLabels = {
    ClaimStatus.draft: 'draft',
    ClaimStatus.pending: 'pending',
    ClaimStatus.approved: 'approved',
    ClaimStatus.rejected: 'rejected',
  };

  String get typeKey => typeLabels[type]!;
  String get statusKey => statusLabels[status]!;
  // Aliases kept for compatibility with my_document_controller / other callers
  String get typeLabel => typeKey;
  String get statusLabel => statusKey;
  int get typeColor => typeColors[type]!;
  int get statusColor => statusColors[status]!;
  String get amountFormatted => 'RM ${amount.toStringAsFixed(2)}';
  bool get canCancel => status == ClaimStatus.pending;
  bool get isMileage => type == ClaimType.mileage;
  bool get isTravel => category == ClaimCategory.travel;
}
