import 'package:flutter/foundation.dart' show debugPrint;
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:staff_attendance/api/api_client.dart';
import 'package:staff_attendance/apps/routes/api_routes.dart';
import 'package:staff_attendance/apps/models/payslip_model.dart';

class PayslipController extends GetxController {
  final payslips = <PayslipModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final selectedYear = DateTime.now().year.obs;

  List<PayslipModel> get filtered => payslips
      .where((item) => item.issuedAt.year == selectedYear.value)
      .toList()
    ..sort((a, b) => b.issuedAt.compareTo(a.issuedAt));

  List<int> get availableYears {
    final years = payslips.map((item) => item.issuedAt.year).toSet().toList()
      ..sort((a, b) => b.compareTo(a));
    if (!years.contains(selectedYear.value)) years.insert(0, selectedYear.value);
    return years;
  }

  String formatIssued(DateTime date) => DateFormat('d MMM yyyy').format(date);

  @override
  void onInit() {
    super.onInit();
    fetchPayslips();
  }

  Future<void> fetchPayslips() async {
    try {
      isLoading(true);
      errorMessage('');
      final response = await ApiClient.instance.get(ApiList.payslips);
      debugPrint('PAYSLIPS response: ${response.statusCode}');
      final list = (response.data['data'] as List? ?? const [])
          .map((item) => PayslipModel.fromJson(item as Map<String, dynamic>))
          .toList();
      payslips.assignAll(list);
    } catch (e) {
      debugPrint('PAYSLIPS error: $e');
      errorMessage('could_not_load_payslips'.tr);
    } finally {
      isLoading(false);
    }
  }

  void setYear(int year) => selectedYear(year);
}
