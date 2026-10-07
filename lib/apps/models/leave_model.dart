enum LeaveType { annual, medical, emergency, unpaid, other }

enum LeaveStatus { pending, approved, rejected, cancelled }

class LeaveModel {
  final String id;
  final LeaveType type;
  final LeaveStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;
  final String reason;
  final String? rejectionNote;
  final DateTime appliedAt;
  final String? approvedBy;

  const LeaveModel({
    required this.id,
    required this.type,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.reason,
    this.rejectionNote,
    required this.appliedAt,
    this.approvedBy,
  });

  factory LeaveModel.fromJson(Map<String, dynamic> j) => LeaveModel(
    id: j['id'].toString(),
    type: LeaveType.values.firstWhere(
      (e) => e.name == j['type'],
      orElse: () => LeaveType.other,
    ),
    status: LeaveStatus.values.firstWhere(
      (e) => e.name == j['status'],
      orElse: () => LeaveStatus.pending,
    ),
    startDate: DateTime.parse(j['start_date'] as String),
    endDate: DateTime.parse(j['end_date'] as String),
    totalDays: j['total_days'] as int,
    reason: j['reason'] as String,
    rejectionNote: j['rejection_note'] as String?,
    appliedAt: DateTime.parse(j['applied_at'] as String),
    approvedBy: j['approved_by'] as String?,
  );

  // ── Display helpers ──
  static const typeLabels = {
    LeaveType.annual: 'Annual Leave',
    LeaveType.medical: 'Medical Leave',
    LeaveType.emergency: 'Emergency Leave',
    LeaveType.unpaid: 'Unpaid Leave',
    LeaveType.other: 'Other Leave',
  };

  static const statusLabels = {
    LeaveStatus.pending: 'Pending',
    LeaveStatus.approved: 'Approved',
    LeaveStatus.rejected: 'Rejected',
    LeaveStatus.cancelled: 'Cancelled',
  };

  static const typeColors = {
    LeaveType.annual: 0xFF185FA5,
    LeaveType.medical: 0xFFDC2626,
    LeaveType.emergency: 0xFFF59E0B,
    LeaveType.unpaid: 0xFF7F77DD,
    LeaveType.other: 0xFF64748B,
  };

  static const _statusColors = {
    LeaveStatus.pending: 0xFFF59E0B,
    LeaveStatus.approved: 0xFF16A34A,
    LeaveStatus.rejected: 0xFFDC2626,
    LeaveStatus.cancelled: 0xFF64748B,
  };

  String get typeLabel => typeLabels[type]!;
  String get statusLabel => statusLabels[status]!;
  int get typeColor => typeColors[type]!;
  int get statusColor => _statusColors[status]!;

  bool get canCancel =>
      status == LeaveStatus.pending && startDate.isAfter(DateTime.now());
}

class LeaveBalance {
  final int annualTotal;
  final int annualUsed;
  final int medicalTotal;
  final int medicalUsed;
  final int emergencyTotal;
  final int emergencyUsed;

  const LeaveBalance({
    required this.annualTotal,
    required this.annualUsed,
    required this.medicalTotal,
    required this.medicalUsed,
    required this.emergencyTotal,
    required this.emergencyUsed,
  });

  factory LeaveBalance.fromJson(Map<String, dynamic> j) => LeaveBalance(
    annualTotal: j['annual_total'] as int,
    annualUsed: j['annual_used'] as int,
    medicalTotal: j['medical_total'] as int,
    medicalUsed: j['medical_used'] as int,
    emergencyTotal: j['emergency_total'] as int,
    emergencyUsed: j['emergency_used'] as int,
  );

  int get annualLeft => annualTotal - annualUsed;
  int get medicalLeft => medicalTotal - medicalUsed;
  int get emergencyLeft => emergencyTotal - emergencyUsed;

  // Fallback defaults when API fails
  factory LeaveBalance.defaults() => const LeaveBalance(
    annualTotal: 20,
    annualUsed: 0,
    medicalTotal: 14,
    medicalUsed: 0,
    emergencyTotal: 6,
    emergencyUsed: 0,
  );
}
