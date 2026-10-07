import 'package:get/get.dart';
import 'package:staff_attendance/api/api_client.dart';
import 'package:staff_attendance/widgets/app_toast.dart';
import '../../../apps/models/leave_model.dart';

class TimeOffController extends GetxController {
  // ── State ──
  final leaves = <LeaveModel>[].obs;
  final balance = LeaveBalance.defaults().obs;
  final isLoading = false.obs;
  final isCancelling = false.obs;
  final errorMsg = ''.obs;

  // ── Filters ──
  final selectedStatus = Rxn<LeaveStatus>(); // null = all
  final selectedType = Rxn<LeaveType>(); // null = all
  final selectedYear = DateTime.now().year.obs;

  // ── Derived ──
  List<LeaveModel> get filtered {
    var list = leaves.toList();
    if (selectedStatus.value != null) {
      list = list.where((l) => l.status == selectedStatus.value).toList();
    }
    if (selectedType.value != null) {
      list = list.where((l) => l.type == selectedType.value).toList();
    }
    list = list.where((l) => l.startDate.year == selectedYear.value).toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
    return list;
  }

  int countByStatus(LeaveStatus s) => leaves.where((l) => l.status == s).length;

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  Future<void> fetchAll() async {
    try {
      isLoading(true);
      errorMsg('');
      await Future.wait([_fetchLeaves(), _fetchBalance()]);
    } finally {
      isLoading(false);
    }
  }

  Future<void> _fetchLeaves() async {
    try {
      final response = await ApiClient.instance.get(
        '/leave/my',
        queryParameters: {'year': selectedYear.value},
      );
      leaves.assignAll(
        (response.data['data'] as List).map(
          (e) => LeaveModel.fromJson(e as Map<String, dynamic>),
        ),
      );
    } catch (_) {}
  }

  Future<void> _fetchBalance() async {
    try {
      final response = await ApiClient.instance.get('/leave/balance');
      balance(
        LeaveBalance.fromJson(response.data['data'] as Map<String, dynamic>),
      );
    } catch (_) {}
  }

  Future<void> cancelLeave(String id) async {
    try {
      isCancelling(true);
      await ApiClient.instance.post('/leave/$id/cancel');
      // Optimistically update status locally
      final idx = leaves.indexWhere((l) => l.id == id);
      if (idx != -1) {
        final old = leaves[idx];
        leaves[idx] = LeaveModel(
          id: old.id,
          type: old.type,
          status: LeaveStatus.cancelled,
          startDate: old.startDate,
          endDate: old.endDate,
          totalDays: old.totalDays,
          reason: old.reason,
          appliedAt: old.appliedAt,
        );
        leaves.refresh();
      }
      Get.back(); // close detail sheet
    } catch (_) {
      AppToast.failed('Error', 'Failed to cancel. Try again.');
    } finally {
      isCancelling(false);
    }
  }

  void setStatusFilter(LeaveStatus? s) {
    selectedStatus.value = selectedStatus.value == s ? null : s;
  }

  void setTypeFilter(LeaveType? t) {
    selectedType.value = selectedType.value == t ? null : t;
  }

  void setYear(int y) {
    selectedYear(y);
    _fetchLeaves();
  }
}
