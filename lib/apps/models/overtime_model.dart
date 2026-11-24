enum OvertimeType { weekday, weekend, publicHoliday }

enum OvertimeStatus { pending, approved, rejected }

class OvertimeModel {
  final String id;
  final DateTime date;
  final String startTime;
  final String endTime;
  final OvertimeType type;
  final double hours;
  final String reason;
  final OvertimeStatus status;
  final String? rejectionNote;
  final String? approvedBy;
  final DateTime submittedAt;

  const OvertimeModel({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.type,
    required this.hours,
    required this.reason,
    required this.status,
    this.rejectionNote,
    this.approvedBy,
    required this.submittedAt,
  });

  factory OvertimeModel.fromJson(Map<String, dynamic> j) => OvertimeModel(
    id: j['id'].toString(),
    date: DateTime.parse(j['date'] as String),
    startTime: j['start_time'] as String,
    endTime: j['end_time'] as String,
    type: OvertimeType.values.firstWhere(
      (e) => e.name == j['type'],
      orElse: () => OvertimeType.weekday,
    ),
    hours: (j['hours'] as num).toDouble(),
    reason: j['reason'] as String,
    status: OvertimeStatus.values.firstWhere(
      (e) => e.name == j['status'],
      orElse: () => OvertimeStatus.pending,
    ),
    rejectionNote: j['rejection_note'] as String?,
    approvedBy: j['approved_by'] as String?,
    submittedAt: DateTime.parse(j['submitted_at'] as String).toLocal(),
  );

  // Translation keys — .tr is called at the render site
  static const typeLabels = {
    OvertimeType.weekday: 'ot_weekday',
    OvertimeType.weekend: 'ot_weekend',
    OvertimeType.publicHoliday: 'ot_public_holiday',
  };

  static const statusLabels = {
    OvertimeStatus.pending: 'pending',
    OvertimeStatus.approved: 'approved',
    OvertimeStatus.rejected: 'rejected',
  };

  static const typeColors = {
    OvertimeType.weekday: 0xFFD97706,
    OvertimeType.weekend: 0xFF185FA5,
    OvertimeType.publicHoliday: 0xFF7F77DD,
  };

  static const statusColors = {
    OvertimeStatus.pending: 0xFFF59E0B,
    OvertimeStatus.approved: 0xFF16A34A,
    OvertimeStatus.rejected: 0xFFDC2626,
  };

  static const rateLabels = {
    OvertimeType.weekday: '1.5×',
    OvertimeType.weekend: '2.0×',
    OvertimeType.publicHoliday: '3.0×',
  };

  String get typeLabel => typeLabels[type]!;
  String get statusLabel => statusLabels[status]!;
  int get typeColor => typeColors[type]!;
  int get statusColor => statusColors[status]!;
  String get rateLabel => rateLabels[type]!;
}
