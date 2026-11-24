class ShiftSummary {
  final int id;
  final String date;
  final String? title;
  final String? startTime;
  final String? endTime;

  const ShiftSummary({
    required this.id,
    required this.date,
    this.title,
    this.startTime,
    this.endTime,
  });

  factory ShiftSummary.fromJson(Map<String, dynamic> json) => ShiftSummary(
        id: json['id'] as int,
        date: json['date'] as String? ?? '',
        title: json['title'] as String?,
        startTime: json['start_time'] as String?,
        endTime: json['end_time'] as String?,
      );
}

class ShiftSwapModel {
  final int id;
  final String status;
  final String? reason;
  final String? adminNote;
  final String createdAt;
  final bool isMine;
  final int requesterId;
  final String? requesterName;
  final int? targetId;
  final String? targetName;
  final ShiftSummary? requesterShift;
  final ShiftSummary? targetShift;

  const ShiftSwapModel({
    required this.id,
    required this.status,
    this.reason,
    this.adminNote,
    required this.createdAt,
    required this.isMine,
    required this.requesterId,
    this.requesterName,
    this.targetId,
    this.targetName,
    this.requesterShift,
    this.targetShift,
  });

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  factory ShiftSwapModel.fromJson(Map<String, dynamic> json) {
    final req = json['requester'] as Map<String, dynamic>?;
    final tgt = json['target'] as Map<String, dynamic>?;
    return ShiftSwapModel(
      id: json['id'] as int,
      status: json['status'] as String? ?? 'pending',
      reason: json['reason'] as String?,
      adminNote: json['admin_note'] as String?,
      createdAt: json['created_at'] as String? ?? '',
      isMine: json['is_mine'] as bool? ?? true,
      requesterId: (req?['id'] as num?)?.toInt() ?? 0,
      requesterName: req?['name'] as String?,
      targetId: (tgt?['id'] as num?)?.toInt(),
      targetName: tgt?['name'] as String?,
      requesterShift: json['requester_shift'] != null
          ? ShiftSummary.fromJson(json['requester_shift'] as Map<String, dynamic>)
          : null,
      targetShift: json['target_shift'] != null
          ? ShiftSummary.fromJson(json['target_shift'] as Map<String, dynamic>)
          : null,
    );
  }
}
