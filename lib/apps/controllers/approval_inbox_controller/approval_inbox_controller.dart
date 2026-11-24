import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:get/get.dart';
import 'package:staff_attendance/api/api_client.dart';
import 'package:staff_attendance/apps/routes/api_routes.dart';
import 'package:staff_attendance/widgets/app_toast.dart';

class ApprovalInboxController extends GetxController {
  final isLoading = false.obs;
  final errorMessage = Rxn<String>();
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
    'Remote work',
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
      errorMessage(null);
      final response = await ApiClient.instance.get(ApiList.approvalInbox);
      approvals.assignAll(
        (response.data['data'] as List? ?? const [])
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList(),
      );
    } on DioException catch (e) {
      debugPrint('APPROVAL_INBOX error: $e');
      errorMessage(ApiClient.extractError(e, fallback: 'Failed to load approvals. Tap to retry.'));
    } catch (e) {
      debugPrint('APPROVAL_INBOX unexpected error: $e');
      errorMessage('Something went wrong. Tap to retry.');
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
    var successCount = 0;
    for (final id in ids) {
      if (await decide(id, 'Approved', silent: true)) successCount++;
    }
    selectedIds.clear();
    if (successCount == ids.length) {
      AppToast.approved(
        'Bulk approved',
        '$successCount request(s) have been approved.',
      );
    } else {
      AppToast.approved(
        'Bulk approved',
        '$successCount of ${ids.length} approved. ${ids.length - successCount} failed.',
      );
    }
  }

  /// Returns true if the decision was saved successfully, false otherwise.
  Future<bool> decide(
    String id,
    String decision, {
    String? remarks,
    bool silent = false,
  }) async {
    try {
      await ApiClient.instance.post(
        ApiList.approvalDecision,
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
      return true;
    } on DioException catch (e) {
      debugPrint('APPROVAL_INBOX decide error: ${e.type} | ${e.response?.statusCode} | ${e.response?.data}');
      AppToast.failed(
        'Decision failed',
        ApiClient.extractError(e, fallback: 'Could not save decision. Try again.'),
      );
      return false;
    } catch (e) {
      debugPrint('APPROVAL_INBOX decide error: $e');
      AppToast.failed('Decision failed', 'An unexpected error occurred.');
      return false;
    }
  }
}
