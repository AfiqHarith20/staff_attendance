import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:staff_attendance/api/api_client.dart';
import 'package:staff_attendance/apps/models/leave_model.dart';
import 'package:staff_attendance/apps/routes/api_routes.dart';
import 'package:staff_attendance/widgets/app_toast.dart';

class LeaveBalanceController extends GetxController {
  final balance = LeaveBalance.defaults().obs;
  final leaves = <LeaveModel>[].obs;
  final isLoading = false.obs;
  final hasError = false.obs;

  // Leaves sorted newest first, capped at 10 for the "recent activity" list.
  List<LeaveModel> get recentLeaves {
    final sorted = leaves.toList()
      ..sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
    return sorted.take(10).toList();
  }

  int pendingCountFor(LeaveType type) =>
      leaves.where((l) => l.type == type && l.status == LeaveStatus.pending).length;

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  Future<void> fetchAll() async {
    try {
      isLoading(true);
      hasError(false);
      await Future.wait([_fetchBalance(), _fetchLeaves()]);
    } on DioException catch (e) {
      hasError(true);
      AppToast.failed(
        'Failed to load',
        ApiClient.extractError(e, fallback: 'Could not load leave balance.'),
      );
    } catch (_) {
      hasError(true);
    } finally {
      isLoading(false);
    }
  }

  Future<void> _fetchBalance() async {
    final response = await ApiClient.instance.get(ApiList.leaveBalance);
    balance(LeaveBalance.fromJson(response.data['data'] as Map<String, dynamic>));
  }

  Future<void> _fetchLeaves() async {
    final response = await ApiClient.instance.get(
      ApiList.leaveList,
      queryParameters: {'year': DateTime.now().year},
    );
    leaves.assignAll(
      (response.data['data'] as List)
          .map((e) => LeaveModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
