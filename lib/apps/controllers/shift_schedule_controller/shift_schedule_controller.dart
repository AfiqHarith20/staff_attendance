import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:staff_attendance/api/api_client.dart';
import 'package:staff_attendance/apps/routes/api_routes.dart';
import 'package:staff_attendance/apps/models/shift_schedule_model.dart';

class ShiftScheduleController extends GetxController {
  final shifts = <ShiftScheduleModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final selectedWeekStart = _startOfWeek(DateTime.now()).obs;

  List<ShiftScheduleModel> get weekShifts {
    final start = selectedWeekStart.value;
    final end = start.add(const Duration(days: 7));
    return shifts
        .where((item) => !item.date.isBefore(start) && item.date.isBefore(end))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  @override
  void onInit() {
    super.onInit();
    fetchShifts();
  }

  Future<void> fetchShifts() async {
    try {
      isLoading(true);
      errorMessage('');
      final response = await ApiClient.instance.get(ApiList.shifts);
      final list = (response.data['data'] as List? ?? const [])
          .map((item) => ShiftScheduleModel.fromJson(item as Map<String, dynamic>))
          .toList();
      shifts.assignAll(list);
    } catch (e) {
      errorMessage('could_not_load_shifts'.tr);
    } finally {
      isLoading(false);
    }
  }

  void previousWeek() =>
      selectedWeekStart(selectedWeekStart.value.subtract(const Duration(days: 7)));
  void nextWeek() =>
      selectedWeekStart(selectedWeekStart.value.add(const Duration(days: 7)));

  void goToCurrentWeek() =>
      selectedWeekStart(_startOfWeek(DateTime.now()));

  bool get isCurrentWeek =>
      selectedWeekStart.value == _startOfWeek(DateTime.now());

  bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String weekLabel() {
    final start = selectedWeekStart.value;
    final end = start.add(const Duration(days: 6));
    return '${DateFormat('d MMM').format(start)} - ${DateFormat('d MMM yyyy').format(end)}';
  }

  String dayName(DateTime date) => DateFormat('EEE').format(date);
  String dayNumber(DateTime date) => DateFormat('d').format(date);

  static DateTime _startOfWeek(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return normalized.subtract(Duration(days: normalized.weekday - 1));
  }
}
