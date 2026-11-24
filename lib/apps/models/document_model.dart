enum DocumentStatus { pending, approved, rejected }

// Values match the API's `type` field strings exactly.
enum DocumentType { ic, contract, cert, medical, passport, other }

class DocumentModel {
  final String id;
  final String fileName;
  final String fileUrl;
  final DocumentType type;
  final DocumentStatus status;
  final DateTime uploadedAt;
  final String? note;
  final String? expiresAt;
  final int? fileSizeBytes;

  const DocumentModel({
    required this.id,
    required this.fileName,
    required this.fileUrl,
    required this.type,
    required this.status,
    required this.uploadedAt,
    this.note,
    this.expiresAt,
    this.fileSizeBytes,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> j) => DocumentModel(
    id: j['id'].toString(),
    fileName: j['file_name'] as String,
    fileUrl: j['file_url'] as String? ?? '',
    type: DocumentType.values.firstWhere(
      (e) => e.name == j['type'],
      orElse: () => DocumentType.other,
    ),
    status: DocumentStatus.values.firstWhere(
      (e) => e.name == (j['status'] as String? ?? 'pending'),
      orElse: () => DocumentStatus.pending,
    ),
    uploadedAt: DateTime.parse(j['uploaded_at'] as String).toLocal(),
    note: j['note'] as String?,
    expiresAt: j['expires_at'] as String?,
    fileSizeBytes: j['file_size'] as int?,
  );

  String get fileSizeFormatted {
    final bytes = fileSizeBytes;
    if (bytes == null) return '';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String get typeLabel {
    switch (type) {
      case DocumentType.ic:
        return 'IC / MyKad';
      case DocumentType.contract:
        return 'Employment contract';
      case DocumentType.cert:
        return 'Certificate';
      case DocumentType.medical:
        return 'Medical cert';
      case DocumentType.passport:
        return 'Passport';
      case DocumentType.other:
        return 'Document';
    }
  }
}
