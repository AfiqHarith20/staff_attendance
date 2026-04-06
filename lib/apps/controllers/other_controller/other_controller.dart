import 'package:get/get.dart';
import 'package:staff_attendance/api/api_client.dart';

class OtherController extends GetxController {
  // ── Badge counts ──
  final pendingLeave = 0.obs;
  final pendingDocuments = 0.obs;
  final unreadAnnouncements = 0.obs;
  final payslipReady = false.obs;
  final payslipMonth = ''.obs;
  final nextHoliday = ''.obs; // e.g. "5 Apr"

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBadgeCounts();
  }

  Future<void> fetchBadgeCounts() async {
    try {
      isLoading(true);
      final response = await ApiClient.instance.get('/staff/dashboard/badges');
      final data = response.data['data'] as Map<String, dynamic>;

      pendingLeave(data['pending_leave'] as int? ?? 0);
      pendingDocuments(data['pending_documents'] as int? ?? 0);
      unreadAnnouncements(data['unread_announcements'] as int? ?? 0);
      payslipReady(data['payslip_ready'] as bool? ?? false);
      payslipMonth(data['payslip_month'] as String? ?? '');
      nextHoliday(data['next_holiday_date'] as String? ?? '');
    } catch (_) {
      // non-blocking — badges just won't show
    } finally {
      isLoading(false);
    }
  }
}
