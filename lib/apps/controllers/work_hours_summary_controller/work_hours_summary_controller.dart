import 'package:get/get.dart';
import 'package:staff_attendance/api/api_client.dart';

class WorkHoursSummaryController extends GetxController {
  final isLoading = false.obs;
  final period = 'Weekly'.obs;
  final summary = <String, dynamic>{}.obs;
  final daily = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchSummary();
  }

  Future<void> fetchSummary() async {
    try {
      isLoading(true);
      final response = await ApiClient.instance.get(
        '/work-hours-summary',
        queryParameters: {'period': period.value.toLowerCase()},
      );
      final data = response.data['data'] as Map<String, dynamic>? ?? {};
      summary.assignAll(data);
      daily.assignAll(
        (data['daily'] as List? ?? const [])
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList(),
      );
    } finally {
      isLoading(false);
    }
  }

  void setPeriod(String value) {
    period(value);
    fetchSummary();
  }
}
