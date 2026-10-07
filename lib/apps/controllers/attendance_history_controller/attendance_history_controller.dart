import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:staff_attendance/api/api_client.dart';
import 'package:staff_attendance/apps/models/attendance_history_model.dart';

class AttendanceHistoryController extends GetxController {
  final records = <AttendanceRecordModel>[].obs;
  final isLoading = false.obs;
  final selectedMonth = DateTime(DateTime.now().year, DateTime.now().month).obs;
  final selectedStatus = Rxn<AttendanceRecordStatus>();

  List<AttendanceRecordModel> get filtered {
    final month = selectedMonth.value;
    final list = records.where((item) {
      final sameMonth = item.date.year == month.year && item.date.month == month.month;
      final sameStatus =
          selectedStatus.value == null || item.status == selectedStatus.value;
      return sameMonth && sameStatus;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  int get presentDays => filtered
      .where((item) =>
          item.status == AttendanceRecordStatus.present ||
          item.status == AttendanceRecordStatus.late)
      .length;
  int get issueDays => filtered
      .where((item) => item.isLate || item.isEarlyCheckout || item.status == AttendanceRecordStatus.issue)
      .length;
  String get totalHoursLabel => '${filtered.fold<int>(0, (sum, item) {
        final parts = RegExp(r'(\d+)h').firstMatch(item.workingHoursLabel);
        return sum + int.tryParse(parts?.group(1) ?? '0')!;
      })}h';

  @override
  void onInit() {
    super.onInit();
    fetchRecords();
  }

  Future<void> fetchRecords() async {
    try {
      isLoading(true);
      final response = await ApiClient.instance.get('/attendance/history');
      final list = (response.data['data'] as List? ?? const [])
          .map((item) => AttendanceRecordModel.fromJson(item as Map<String, dynamic>))
          .toList();
      records.assignAll(list);
    } finally {
      isLoading(false);
    }
  }

  void previousMonth() {
    final current = selectedMonth.value;
    selectedMonth(DateTime(current.year, current.month - 1));
  }

  void nextMonth() {
    final current = selectedMonth.value;
    selectedMonth(DateTime(current.year, current.month + 1));
  }

  void setStatus(AttendanceRecordStatus? status) {
    selectedStatus(status == selectedStatus.value ? null : status);
  }

  String monthLabel(DateTime value) => DateFormat('MMMM yyyy').format(value);
  String dayLabel(DateTime value) => DateFormat('EEE, d MMM').format(value);
  String timeLabel(DateTime? value) =>
      value == null ? '--:--' : DateFormat('h:mm a').format(value);
  String dateLabel(DateTime value) => DateFormat('EEEE, d MMM yyyy').format(value);
}
