class JobPostingModel {
  final int id;
  final String title;
  final String? department;
  final String employmentType;
  final String employmentTypeLabel;
  final String? location;
  final int? headcount;
  final String? description;
  final String? requirements;
  final String? openedAt;

  const JobPostingModel({
    required this.id,
    required this.title,
    this.department,
    required this.employmentType,
    required this.employmentTypeLabel,
    this.location,
    this.headcount,
    this.description,
    this.requirements,
    this.openedAt,
  });

  factory JobPostingModel.fromJson(Map<String, dynamic> json) => JobPostingModel(
        id: json['id'] as int,
        title: json['title'] as String? ?? '',
        department: json['department'] as String?,
        employmentType: json['employment_type'] as String? ?? '',
        employmentTypeLabel: json['employment_type_label'] as String? ?? '',
        location: json['location'] as String?,
        headcount: (json['headcount'] as num?)?.toInt(),
        description: json['description'] as String?,
        requirements: json['requirements'] as String?,
        openedAt: json['opened_at'] as String?,
      );
}
