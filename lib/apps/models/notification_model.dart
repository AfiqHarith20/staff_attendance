class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String category;
  final DateTime createdAt;
  final bool isUnread;
  final String route;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.createdAt,
    required this.isUnread,
    required this.route,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'].toString(),
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      isUnread: json['is_unread'] as bool? ?? false,
      route: json['route'] as String? ?? '',
    );
  }
}
