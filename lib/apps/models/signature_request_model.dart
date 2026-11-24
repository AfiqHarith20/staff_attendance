class SignatureRequestModel {
  final int id;
  final String title;
  final String? description;
  final String? fileName;
  final String? fileUrl;
  final String? dueDate;
  final String status;
  final String? signedAt;
  final String? declinedAt;
  final String? declineReason;
  final bool isOverdue;

  const SignatureRequestModel({
    required this.id,
    required this.title,
    this.description,
    this.fileName,
    this.fileUrl,
    this.dueDate,
    required this.status,
    this.signedAt,
    this.declinedAt,
    this.declineReason,
    required this.isOverdue,
  });

  bool get isPending => status == 'pending';
  bool get isSigned => status == 'signed';
  bool get isDeclined => status == 'declined';

  factory SignatureRequestModel.fromJson(Map<String, dynamic> json) =>
      SignatureRequestModel(
        id: json['id'] as int,
        title: json['title'] as String? ?? '',
        description: json['description'] as String?,
        fileName: json['file_name'] as String?,
        fileUrl: json['file_url'] as String?,
        dueDate: json['due_date'] as String?,
        status: json['status'] as String? ?? 'pending',
        signedAt: json['signed_at'] as String?,
        declinedAt: json['declined_at'] as String?,
        declineReason: json['decline_reason'] as String?,
        isOverdue: json['is_overdue'] as bool? ?? false,
      );
}
