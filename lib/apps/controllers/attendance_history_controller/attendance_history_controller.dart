import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:staff_attendance/api/api_client.dart';
import 'package:staff_attendance/apps/routes/api_routes.dart';
import 'package:staff_attendance/apps/models/attendance_history_model.dart';

class AttendanceHistoryController extends GetxController {
  final records = <AttendanceRecordModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = Rxn<String>();
  final selectedMonth = DateTime(DateTime.now().year, DateTime.now().month).obs;
  final selectedStatus = Rxn<AttendanceRecordStatus>();

  List<AttendanceRecordModel> get filtered {
    if (selectedStatus.value == null) return records.toList();
    return records.where((r) => r.status == selectedStatus.value).toList();
  }

  int get presentDays => records
      .where((r) =>
          r.status == AttendanceRecordStatus.present ||
          r.status == AttendanceRecordStatus.late)
      .length;

  int get issueDays => records
      .where((r) =>
          r.isLate ||
          r.isEarlyCheckout ||
          r.status == AttendanceRecordStatus.issue)
      .length;

  String get totalHoursLabel {
    final total = records.fold<int>(0, (sum, r) {
      final match = RegExp(r'(\d+)h').firstMatch(r.workingHoursLabel);
      return sum + (int.tryParse(match?.group(1) ?? '0') ?? 0);
    });
    return '${total}h';
  }

  @override
  void onInit() {
    super.onInit();
    fetchRecords();
  }

  Future<void> fetchRecords() async {
    try {
      isLoading(true);
      errorMessage(null);
      final month = selectedMonth.value;
      final response = await ApiClient.instance.get(
        ApiList.attendanceHistory,
        queryParameters: {
          'month': month.month,
          'year': month.year,
        },
      );
      final list = (response.data['data'] as List? ?? const [])
          .map((item) =>
              AttendanceRecordModel.fromJson(item as Map<String, dynamic>))
          .toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      records.assignAll(list);
    } on DioException catch (e) {
      debugPrint('ATTENDANCE_HISTORY error: $e');
      errorMessage(e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout ||
              e.type == DioExceptionType.sendTimeout
          ? 'Connection timed out. Please check your network and try again.'
          : 'Failed to load attendance history. Tap to retry.');
    } catch (e) {
      debugPrint('ATTENDANCE_HISTORY unexpected error: $e');
      errorMessage('Something went wrong. Tap to retry.');
    } finally {
      isLoading(false);
    }
  }

  void previousMonth() {
    final current = selectedMonth.value;
    selectedMonth(DateTime(current.year, current.month - 1));
    fetchRecords();
  }

  void nextMonth() {
    final current = selectedMonth.value;
    final next = DateTime(current.year, current.month + 1);
    if (next.isAfter(DateTime.now())) return;
    selectedMonth(next);
    fetchRecords();
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
