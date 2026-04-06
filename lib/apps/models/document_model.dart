enum DocumentStatus { pending, approved, rejected }

enum DocumentType { mc, emergencyLeave, annualLeave, other }

class DocumentModel {
  final String id;
  final String fileName;
  final String filePath;
  final int fileSizeBytes;
  final DocumentType type;
  final DocumentStatus status;
  final DateTime uploadedAt;
  final String? note;

  const DocumentModel({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.fileSizeBytes,
    required this.type,
    required this.status,
    required this.uploadedAt,
    this.note,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> j) => DocumentModel(
    id: j['id'] as String,
    fileName: j['file_name'] as String,
    filePath: j['file_path'] as String,
    fileSizeBytes: j['file_size'] as int,
    type: DocumentType.values.firstWhere(
      (e) => e.name == j['type'],
      orElse: () => DocumentType.other,
    ),
    status: DocumentStatus.values.firstWhere(
      (e) => e.name == j['status'],
      orElse: () => DocumentStatus.pending,
    ),
    uploadedAt: DateTime.parse(j['uploaded_at'] as String),
    note: j['note'] as String?,
  );

  String get fileSizeFormatted {
    if (fileSizeBytes < 1024) return '$fileSizeBytes B';
    if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(0)} KB';
    }
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String get typeLabel {
    switch (type) {
      case DocumentType.mc:
        return 'Medical cert';
      case DocumentType.emergencyLeave:
        return 'Emergency leave';
      case DocumentType.annualLeave:
        return 'Annual leave';
      case DocumentType.other:
        return 'Document';
    }
  }
}
