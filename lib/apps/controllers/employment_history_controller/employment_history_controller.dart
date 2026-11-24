import 'package:flutter/foundation.dart' show debugPrint;
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:staff_attendance/api/api_client.dart';
import 'package:staff_attendance/apps/routes/api_routes.dart';
import 'package:staff_attendance/apps/models/employment_history_model.dart';

class EmploymentHistoryController extends GetxController {
  final history = <EmploymentHistoryModel>[].obs;
  final isLoading = false.obs;

  List<EmploymentHistoryModel> get sorted =>
      history.toList()..sort((a, b) => b.startedAt.compareTo(a.startedAt));

  @override
  void onInit() {
    super.onInit();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    try {
      isLoading(true);
      final response = await ApiClient.instance.get(ApiList.employmentHistory);
      final list = (response.data['data'] as List? ?? const [])
          .map((item) =>
              EmploymentHistoryModel.fromJson(item as Map<String, dynamic>))
          .toList();
      history.assignAll(list);
    } catch (e) {
      debugPrint('EMPLOYMENT_HISTORY error: $e');
    } finally {
      isLoading(false);
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) return 'Present';
    return DateFormat('MMM yyyy').format(date);
  }

  String durationLabel(DateTime startedAt, DateTime? endedAt) {
    final end = endedAt ?? DateTime.now();
    final months =
        (end.year - startedAt.year) * 12 + end.month - startedAt.month;
    if (months < 1) return '< 1 month';
    if (months < 12) return '$months month${months > 1 ? 's' : ''}';
    final years = months ~/ 12;
    final rem = months % 12;
    final yLabel = '$years yr${years > 1 ? 's' : ''}';
    return rem == 0 ? yLabel : '$yLabel $rem mo';
  }
}
