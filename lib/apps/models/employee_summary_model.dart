class EmployeeSummaryModel {
  final int id;
  final String name;
  final String email;
  final String? employeeNo;
  final String? jobTitle;
  final String? department;
  final String role;
  final String? joinedOn;
  final String? avatarUrl;
  final bool isActive;

  const EmployeeSummaryModel({
    required this.id,
    required this.name,
    required this.email,
    this.employeeNo,
    this.jobTitle,
    this.department,
    required this.role,
    this.joinedOn,
    this.avatarUrl,
    required this.isActive,
  });

  factory EmployeeSummaryModel.fromJson(Map<String, dynamic> json) =>
      EmployeeSummaryModel(
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        employeeNo: json['employee_no'] as String?,
        jobTitle: json['job_title'] as String?,
        department: json['department'] as String?,
        role: json['role'] as String? ?? 'staff',
        joinedOn: json['joined_on'] as String?,
        avatarUrl: json['avatar_url'] as String?,
        isActive: json['is_active'] as bool? ?? true,
      );
}
