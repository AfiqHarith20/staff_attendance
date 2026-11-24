import 'package:get/get.dart';
import 'package:staff_attendance/api/api_client.dart';
import 'package:staff_attendance/apps/models/overtime_model.dart';
import 'package:staff_attendance/apps/routes/api_routes.dart';

class OvertimeController extends GetxController {
  final requests = <OvertimeModel>[].obs;
  final isLoading = false.obs;
  final errorMsg = ''.obs;

  final selectedStatus = Rxn<OvertimeStatus>();
  final selectedType = Rxn<OvertimeType>();

  List<OvertimeModel> get filtered {
    var list = requests.toList();
    if (selectedStatus.value != null) {
      list = list.where((r) => r.status == selectedStatus.value).toList();
    }
    if (selectedType.value != null) {
      list = list.where((r) => r.type == selectedType.value).toList();
    }
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  int countByStatus(OvertimeStatus s) =>
      requests.where((r) => r.status == s).length;

  double get totalApprovedHours => requests
      .where((r) => r.status == OvertimeStatus.approved)
      .fold(0.0, (sum, r) => sum + r.hours);

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  Future<void> fetchAll() async {
    try {
      isLoading(true);
      errorMsg('');
      final response = await ApiClient.instance.get(ApiList.overtimeList);
      requests.assignAll(
        (response.data['data'] as List)
            .map((e) => OvertimeModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      errorMsg(ApiClient.extractError(e, fallback: 'fetch_failed'.tr));
    } finally {
      isLoading(false);
    }
  }

  void setStatusFilter(OvertimeStatus? s) {
    selectedStatus.value = selectedStatus.value == s ? null : s;
  }

  void setTypeFilter(OvertimeType? t) {
    selectedType.value = selectedType.value == t ? null : t;
  }
}
