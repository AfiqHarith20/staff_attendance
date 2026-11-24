class EmploymentHistoryModel {
  final String id;
  final String position;
  final String department;
  final String employmentType;
  final DateTime startedAt;
  final DateTime? endedAt;
  final bool isCurrent;
  final String salaryGrade;

  const EmploymentHistoryModel({
    required this.id,
    required this.position,
    required this.department,
    required this.employmentType,
    required this.startedAt,
    this.endedAt,
    required this.isCurrent,
    required this.salaryGrade,
  });

  factory EmploymentHistoryModel.fromJson(Map<String, dynamic> json) {
    return EmploymentHistoryModel(
      id: json['id'].toString(),
      position: json['position'] as String? ?? '',
      department: json['department'] as String? ?? '',
      employmentType: json['employment_type'] as String? ?? '',
      startedAt:
          DateTime.tryParse(json['started_at'] as String? ?? '') ??
          DateTime.now(),
      endedAt: json['ended_at'] != null
          ? DateTime.tryParse(json['ended_at'] as String)
          : null,
      isCurrent: json['is_current'] as bool? ?? false,
      salaryGrade: json['salary_grade'] as String? ?? '',
    );
  }
}
