import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:staff_attendance/api/api_client.dart';
import 'package:staff_attendance/apps/models/team_leave_entry_model.dart';
import 'package:staff_attendance/apps/routes/api_routes.dart';
import 'package:staff_attendance/widgets/app_toast.dart';

class TeamLeaveController extends GetxController {
  final entries = <TeamLeaveEntryModel>[].obs;
  final isLoading = false.obs;
  final hasError = false.obs;
  final selectedDept = Rxn<String>();

  late final Rx<DateTime> focusedMonth;

  @override
  void onInit() {
    super.onInit();
    final now = DateTime.now();
    focusedMonth = DateTime(now.year, now.month).obs;
    fetchLeaves();
  }

  void previousMonth() {
    if (isLoading.value) return;
    final m = focusedMonth.value;
    focusedMonth.value = DateTime(m.year, m.month - 1);
    fetchLeaves();
  }

  void nextMonth() {
    if (isLoading.value) return;
    final m = focusedMonth.value;
    focusedMonth.value = DateTime(m.year, m.month + 1);
    fetchLeaves();
  }

  List<TeamLeaveEntryModel> leavesOnDay(DateTime day) {
    return entries.where((e) {
      final start = DateTime.tryParse(e.startDate);
      final end = DateTime.tryParse(e.endDate);
      if (start == null || end == null) return false;
      final d = DateTime(day.year, day.month, day.day);
      return !d.isBefore(DateTime(start.year, start.month, start.day)) &&
          !d.isAfter(DateTime(end.year, end.month, end.day));
    }).toList();
  }

  Future<void> fetchLeaves() async {
    try {
      isLoading(true);
      hasError(false);
      final m = focusedMonth.value;
      final monthStr =
          '${m.year}-${m.month.toString().padLeft(2, '0')}';
      final params = <String, dynamic>{
        'month': monthStr,
        if (selectedDept.value != null) 'department': selectedDept.value,
      };
      final res = await ApiClient.instance.get(
        ApiList.adminTeamLeave,
        queryParameters: params,
      );
      final list = (res.data['data'] as List<dynamic>? ?? [])
          .map((e) => TeamLeaveEntryModel.fromJson(e as Map<String, dynamic>))
          .toList();
      entries.assignAll(list);
    } on DioException catch (e) {
      hasError(true);
      AppToast.failed('Failed', ApiClient.extractError(e, fallback: 'Could not load team leave.'));
    } catch (_) {
      hasError(true);
    } finally {
      isLoading(false);
    }
  }
}
