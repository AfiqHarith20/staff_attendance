class TeamLeaveEntryModel {
  final int id;
  final String type;
  final int days;
  final String startDate;
  final String endDate;
  final String? reason;
  final int userId;
  final String userName;
  final String? userDepartment;

  const TeamLeaveEntryModel({
    required this.id,
    required this.type,
    required this.days,
    required this.startDate,
    required this.endDate,
    this.reason,
    required this.userId,
    required this.userName,
    this.userDepartment,
  });

  factory TeamLeaveEntryModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    return TeamLeaveEntryModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      type: json['type'] as String? ?? '',
      days: (json['days'] as num?)?.toInt() ?? 0,
      startDate: json['start_date'] as String? ?? '',
      endDate: json['end_date'] as String? ?? '',
      reason: json['reason'] as String?,
      userId: (user['id'] as num?)?.toInt() ?? 0,
      userName: user['name'] as String? ?? '',
      userDepartment: user['department'] as String?,
    );
  }
}
