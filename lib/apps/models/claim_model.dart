enum ClaimType { medical, transport, meal, accommodation, others }

enum ClaimStatus { draft, pending, approved, rejected }

class ClaimModel {
  final String id;
  final ClaimType type;
  final ClaimStatus status;
  final double amount;
  final String description;
  final DateTime claimDate;
  final DateTime submittedAt;
  final String? receiptUrl;
  final String? receiptFileName;
  final String? rejectionNote;
  final String? approvedBy;

  const ClaimModel({
    required this.id,
    required this.type,
    required this.status,
    required this.amount,
    required this.description,
    required this.claimDate,
    required this.submittedAt,
    this.receiptUrl,
    this.receiptFileName,
    this.rejectionNote,
    this.approvedBy,
  });

  factory ClaimModel.fromJson(Map<String, dynamic> j) => ClaimModel(
    id: j['id'].toString(),
    type: ClaimType.values.firstWhere(
      (e) => e.name == j['type'],
      orElse: () => ClaimType.others,
    ),
    status: ClaimStatus.values.firstWhere(
      (e) => e.name == j['status'],
      orElse: () => ClaimStatus.pending,
    ),
    amount: (j['amount'] as num).toDouble(),
    description: j['description'] as String,
    claimDate: DateTime.parse(j['claim_date'] as String),
    submittedAt: DateTime.parse(j['submitted_at'] as String),
    receiptUrl: j['receipt_url'] as String?,
    receiptFileName: j['receipt_file_name'] as String?,
    rejectionNote: j['rejection_note'] as String?,
    approvedBy: j['approved_by'] as String?,
  );

  static const typeLabels = {
    ClaimType.medical: 'Medical',
    ClaimType.transport: 'Transport',
    ClaimType.meal: 'Meal',
    ClaimType.accommodation: 'Accommodation',
    ClaimType.others: 'Others',
  };

  static const statusLabels = {
    ClaimStatus.draft: 'Draft',
    ClaimStatus.pending: 'Pending',
    ClaimStatus.approved: 'Approved',
    ClaimStatus.rejected: 'Rejected',
  };

  static const typeColors = {
    ClaimType.medical: 0xFF185FA5,
    ClaimType.transport: 0xFF16A34A,
    ClaimType.meal: 0xFFF59E0B,
    ClaimType.accommodation: 0xFF7F77DD,
    ClaimType.others: 0xFF64748B,
  };

  static const statusColors = {
    ClaimStatus.draft: 0xFF64748B,
    ClaimStatus.pending: 0xFFF59E0B,
    ClaimStatus.approved: 0xFF16A34A,
    ClaimStatus.rejected: 0xFFDC2626,
  };

  String get typeLabel => typeLabels[type]!;
  String get statusLabel => statusLabels[status]!;
  int get typeColor => typeColors[type]!;
  int get statusColor => statusColors[status]!;

  String get amountFormatted => 'RM ${amount.toStringAsFixed(2)}';

  bool get canCancel => status == ClaimStatus.pending;
}
