enum RemoteWorkStatus { pending, approved, rejected }

class RemoteWorkModel {
  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final String location;
  final String reason;
  final RemoteWorkStatus status;
  final String? rejectionNote;
  final String? approvedBy;
  final DateTime submittedAt;

  const RemoteWorkModel({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.reason,
    required this.status,
    this.rejectionNote,
    this.approvedBy,
    required this.submittedAt,
  });

  factory RemoteWorkModel.fromJson(Map<String, dynamic> j) => RemoteWorkModel(
    id: j['id'].toString(),
    startDate: DateTime.parse(j['start_date'] as String),
    endDate: DateTime.parse(j['end_date'] as String),
    location: j['location'] as String,
    reason: j['reason'] as String,
    status: RemoteWorkStatus.values.firstWhere(
      (e) => e.name == j['status'],
      orElse: () => RemoteWorkStatus.pending,
    ),
    rejectionNote: j['rejection_note'] as String?,
    approvedBy: j['approved_by'] as String?,
    submittedAt: DateTime.parse(j['submitted_at'] as String).toLocal(),
  );

  static const statusLabels = {
    RemoteWorkStatus.pending: 'pending',
    RemoteWorkStatus.approved: 'approved',
    RemoteWorkStatus.rejected: 'rejected',
  };

  static const statusColors = {
    RemoteWorkStatus.pending: 0xFFF59E0B,
    RemoteWorkStatus.approved: 0xFF16A34A,
    RemoteWorkStatus.rejected: 0xFFDC2626,
  };

  String get statusLabel => statusLabels[status]!;
  int get statusColor => statusColors[status]!;

  int get totalDays => endDate.difference(startDate).inDays + 1;
}
