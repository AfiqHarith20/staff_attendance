import 'package:get/get.dart';
import 'package:staff_attendance/api/api_client.dart';
import 'package:staff_attendance/widgets/app_toast.dart';

class ApprovalInboxController extends GetxController {
  final isLoading = false.obs;
  final selectedType = 'All'.obs;
  final selectedStatus = 'Pending'.obs;
  final selectedDate = 'All dates'.obs;
  final filtersExpanded = false.obs;
  final selectedIds = <String>{}.obs;
  final approvals = <Map<String, dynamic>>[].obs;

  final types = const [
    'All',
    'Leave',
    'Overtime',
    'Claim',
    'Correction',
    'Document',
  ];

  final statuses = const ['Pending', 'Approved', 'Rejected', 'All'];
  final dates = const ['All dates', 'Today', 'This week', 'Older'];

  List<Map<String, dynamic>> get filtered {
    return approvals.where((item) {
      final typeOk =
          selectedType.value == 'All' || item['type'] == selectedType.value;
      final statusOk =
          selectedStatus.value == 'All' ||
          item['status'] == selectedStatus.value;
      final dateOk =
          selectedDate.value == 'All dates' ||
          item['date_bucket'] == selectedDate.value;
      return typeOk && statusOk && dateOk;
    }).toList();
  }

  List<Map<String, dynamic>> get selectedItems =>
      approvals.where((item) => selectedIds.contains('${item['id']}')).toList();

  int get activeFilterCount {
    var total = 0;
    if (selectedType.value != 'All') total++;
    if (selectedStatus.value != 'Pending') total++;
    if (selectedDate.value != 'All dates') total++;
    return total;
  }

  String get filterSummary {
    final parts = <String>[
      if (selectedType.value != 'All') selectedType.value,
      selectedStatus.value,
      if (selectedDate.value != 'All dates') selectedDate.value,
    ];
    return parts.join(' · ');
  }

  @override
  void onInit() {
    super.onInit();
    fetchApprovals();
  }

  Future<void> fetchApprovals() async {
    try {
      isLoading(true);
      final response = await ApiClient.instance.get('/approval-inbox');
      approvals.assignAll(
        (response.data['data'] as List? ?? const [])
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList(),
      );
    } finally {
      isLoading(false);
    }
  }

  void setType(String value) => selectedType(value);
  void setStatus(String value) => selectedStatus(value);
  void setDate(String value) => selectedDate(value);
  void toggleFilters() => filtersExpanded.toggle();
  void collapseFilters() => filtersExpanded(false);

  void resetFilters() {
    selectedType('All');
    selectedStatus('Pending');
    selectedDate('All dates');
  }

  void toggleSelection(String id) {
    final next = Set<String>.from(selectedIds);
    next.contains(id) ? next.remove(id) : next.add(id);
    selectedIds
      ..clear()
      ..addAll(next);
  }

  void clearSelection() => selectedIds.clear();

  Future<void> bulkApprove() async {
    final ids = selectedIds.toList();
    for (final id in ids) {
      await decide(id, 'Approved', silent: true);
    }
    selectedIds.clear();
    AppToast.approved(
      'Bulk approved',
      '${ids.length} request(s) have been approved.',
    );
  }

  Future<void> decide(
    String id,
    String decision, {
    String? remarks,
    bool silent = false,
  }) async {
    await ApiClient.instance.post(
      '/approval-inbox/decision',
      data: {'id': id, 'decision': decision, 'remarks': remarks},
    );
    final index = approvals.indexWhere((item) => item['id'] == id);
    if (index != -1) {
      approvals[index] = {
        ...approvals[index],
        'status': decision,
        'audit': [
          ...(approvals[index]['audit'] as List? ?? const []),
          'Admin marked as $decision${remarks?.isNotEmpty == true ? ': $remarks' : ''}',
        ],
      };
      approvals.refresh();
    }
    if (!silent) {
      final title = decision == 'Approved'
          ? 'Request approved'
          : 'Request rejected';
      final message = 'Request has been ${decision.toLowerCase()}.';
      decision == 'Approved'
          ? AppToast.approved(title, message)
          : AppToast.failed(title, message);
    }
  }
}
