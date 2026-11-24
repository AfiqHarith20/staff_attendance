class AdminAnnouncementModel {
  final int id;
  final String title;
  final String? category;
  final String? summary;
  final String body;
  final bool isPinned;
  final String? publishedAt;
  final String? createdBy;
  final List<String>? targetDepartments;
  final List<String>? targetRoles;
  final String createdAt;

  const AdminAnnouncementModel({
    required this.id,
    required this.title,
    this.category,
    this.summary,
    required this.body,
    required this.isPinned,
    this.publishedAt,
    this.createdBy,
    this.targetDepartments,
    this.targetRoles,
    required this.createdAt,
  });

  bool get isPublished => publishedAt != null;

  factory AdminAnnouncementModel.fromJson(Map<String, dynamic> json) =>
      AdminAnnouncementModel(
        id: (json['id'] as num?)?.toInt() ?? 0,
        title: json['title'] as String? ?? '',
        category: json['category'] as String?,
        summary: json['summary'] as String?,
        body: json['body'] as String? ?? '',
        isPinned: json['is_pinned'] as bool? ?? false,
        publishedAt: json['published_at'] as String?,
        createdBy: json['created_by'] as String?,
        targetDepartments: (json['target_departments'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        targetRoles: (json['target_roles'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        createdAt: json['created_at'] as String? ?? '',
      );
}
