import 'package:get/get.dart';
import 'package:staff_attendance/api/api_client.dart';
import 'package:staff_attendance/widgets/app_toast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../apps/models/document_model.dart';
import '../../../apps/models/claim_model.dart';

// Combined document item — wraps both DocumentModel and ClaimModel
class DocItem {
  final String id;
  final String title;
  final String subtitle;
  final String dateLabel;
  final String statusLabel;
  final int statusColor;
  final int typeColor;
  final String? fileUrl;
  final bool isClaim;

  const DocItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.dateLabel,
    required this.statusLabel,
    required this.statusColor,
    required this.typeColor,
    this.fileUrl,
    required this.isClaim,
  });

  factory DocItem.fromDocument(DocumentModel d) => DocItem(
    id: d.id,
    title: d.fileName,
    subtitle: d.typeLabel,
    dateLabel: _fmt(d.uploadedAt),
    statusLabel: d.status.name[0].toUpperCase() + d.status.name.substring(1),
    statusColor: _docStatusColor(d.status),
    typeColor: _docTypeColor(d.type),
    fileUrl: d.filePath,
    isClaim: false,
  );

  factory DocItem.fromClaim(ClaimModel c) => DocItem(
    id: c.id,
    title: '${c.typeLabel} Claim · ${c.amountFormatted}',
    subtitle: c.description,
    dateLabel: _fmt(c.submittedAt),
    statusLabel: c.statusLabel,
    statusColor: c.statusColor,
    typeColor: c.typeColor,
    fileUrl: c.receiptUrl,
    isClaim: true,
  );

  static String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')} ${_months[d.month - 1]} ${d.year}';

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static int _docStatusColor(DocumentStatus s) {
    switch (s) {
      case DocumentStatus.pending:
        return 0xFFF59E0B;
      case DocumentStatus.approved:
        return 0xFF16A34A;
      case DocumentStatus.rejected:
        return 0xFFDC2626;
    }
  }

  static int _docTypeColor(DocumentType t) {
    switch (t) {
      case DocumentType.mc:
        return 0xFFDC2626;
      case DocumentType.emergencyLeave:
        return 0xFFF59E0B;
      case DocumentType.annualLeave:
        return 0xFF185FA5;
      case DocumentType.other:
        return 0xFF64748B;
    }
  }
}

enum DocTab { all, documents, claims }

class MyDocumentsController extends GetxController {
  final documents = <DocItem>[].obs;
  final isLoading = false.obs;
  final activeTab = DocTab.all.obs;
  final activeStatus = Rxn<String>(); // null = all

  List<DocItem> get filtered {
    var list = documents.toList();

    // Filter by tab
    if (activeTab.value == DocTab.documents) {
      list = list.where((d) => !d.isClaim).toList();
    } else if (activeTab.value == DocTab.claims) {
      list = list.where((d) => d.isClaim).toList();
    }

    // Filter by status
    if (activeStatus.value != null) {
      list = list
          .where((d) => d.statusLabel.toLowerCase() == activeStatus.value)
          .toList();
    }

    // Newest first — use dateLabel as-is (sorted server side ideally)
    return list;
  }

  int countPending() =>
      documents.where((d) => d.statusLabel == 'Pending').length;
  int get documentCount => documents.where((d) => !d.isClaim).length;
  int get claimCount => documents.where((d) => d.isClaim).length;
  int get approvedCount =>
      documents.where((d) => d.statusLabel == 'Approved').length;

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  Future<void> fetchAll() async {
    try {
      isLoading(true);
      await Future.wait([_fetchDocuments(), _fetchClaims()]);
    } finally {
      isLoading(false);
    }
  }

  Future<void> _fetchDocuments() async {
    try {
      final res = await ApiClient.instance.get('/documents');
      final docs = (res.data['data'] as List)
          .map(
            (e) => DocItem.fromDocument(
              DocumentModel.fromJson(e as Map<String, dynamic>),
            ),
          )
          .toList();
      // Add / replace documents (not claims)
      documents.removeWhere((d) => !d.isClaim);
      documents.addAll(docs);
    } catch (_) {}
  }

  Future<void> _fetchClaims() async {
    try {
      final res = await ApiClient.instance.get('/claims/my');
      final claims = (res.data['data'] as List)
          .map(
            (e) => DocItem.fromClaim(
              ClaimModel.fromJson(e as Map<String, dynamic>),
            ),
          )
          .toList();
      documents.removeWhere((d) => d.isClaim);
      documents.addAll(claims);
    } catch (_) {}
  }

  Future<void> openFile(String? url) async {
    if (url == null || url.isEmpty) {
      AppToast.failed('No file', 'No file attached to this item');
      return;
    }
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      AppToast.failed('Cannot open', 'Unable to open file');
    }
  }

  void setTab(DocTab tab) => activeTab(tab);
  void setStatus(String? status) {
    activeStatus.value = status == activeStatus.value ? null : status;
  }
}
