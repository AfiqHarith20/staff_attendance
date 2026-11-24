import 'package:get/get.dart';
import 'package:staff_attendance/api/api_client.dart';
import 'package:staff_attendance/apps/models/remote_work_model.dart';
import 'package:staff_attendance/apps/routes/api_routes.dart';

class RemoteWorkController extends GetxController {
  final requests = <RemoteWorkModel>[].obs;
  final isLoading = false.obs;
  final errorMsg = ''.obs;

  final selectedStatus = Rxn<RemoteWorkStatus>();

  List<RemoteWorkModel> get filtered {
    var list = requests.toList();
    if (selectedStatus.value != null) {
      list = list.where((r) => r.status == selectedStatus.value).toList();
    }
    list.sort((a, b) => b.startDate.compareTo(a.startDate));
    return list;
  }

  int countByStatus(RemoteWorkStatus s) =>
      requests.where((r) => r.status == s).length;

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  Future<void> fetchAll() async {
    try {
      isLoading(true);
      errorMsg('');
      final response = await ApiClient.instance.get(ApiList.remoteWorkRequests);
      requests.assignAll(
        (response.data['data'] as List)
            .map((e) => RemoteWorkModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      errorMsg(ApiClient.extractError(e, fallback: 'fetch_failed'.tr));
    } finally {
      isLoading(false);
    }
  }

  void setStatusFilter(RemoteWorkStatus? s) {
    selectedStatus.value = selectedStatus.value == s ? null : s;
  }
}
