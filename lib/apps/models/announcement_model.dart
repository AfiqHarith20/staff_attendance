class AnnouncementModel {
  final String id;
  final String title;
  final String category;
  final String summary;
  final String body;
  final DateTime publishedAt;
  final bool isPinned;
  final bool isUnread;

  const AnnouncementModel({
    required this.id,
    required this.title,
    required this.category,
    required this.summary,
    required this.body,
    required this.publishedAt,
    required this.isPinned,
    required this.isUnread,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id'].toString(),
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      summary: json['summary'] as String? ?? '',
      body: json['body'] as String? ?? '',
      publishedAt:
          DateTime.tryParse(json['published_at'] as String? ?? '') ??
          DateTime.now(),
      isPinned: json['is_pinned'] as bool? ?? false,
      isUnread: json['is_unread'] as bool? ?? false,
    );
  }
}
