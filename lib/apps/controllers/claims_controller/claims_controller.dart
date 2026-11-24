import 'package:get/get.dart';
import 'package:staff_attendance/api/api_client.dart';
import 'package:staff_attendance/apps/models/claim_model.dart';
import 'package:staff_attendance/apps/routes/api_routes.dart';

class ClaimsController extends GetxController {
  final requests = <ClaimModel>[].obs;
  final isLoading = false.obs;
  final errorMsg = Rxn<String>();
  final selectedStatus = 'all'.obs;
  final selectedCategory = 'all'.obs;
  final mileageRates = Rxn<MileageRates>();

  List<ClaimModel> get filtered {
    var list = [...requests];
    if (selectedStatus.value != 'all') {
      list = list.where((c) => c.statusKey == selectedStatus.value).toList();
    }
    if (selectedCategory.value == 'general') {
      list = list.where((c) => c.category == ClaimCategory.general).toList();
    } else if (selectedCategory.value == 'travel') {
      list = list.where((c) => c.category == ClaimCategory.travel).toList();
    }
    list.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    return list;
  }

  int countByStatus(String status) {
    if (status == 'all') return requests.length;
    return requests.where((c) => c.statusKey == status).length;
  }

  double get totalApprovedAmount => requests
      .where((c) => c.status == ClaimStatus.approved)
      .fold(0.0, (sum, c) => sum + c.amount);

  double get totalPendingAmount => requests
      .where((c) => c.status == ClaimStatus.pending)
      .fold(0.0, (sum, c) => sum + c.amount);

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  Future<void> fetchAll() async {
    isLoading(true);
    errorMsg(null);
    try {
      final res = await ApiClient.instance.get(ApiList.claimsList);
      final data = res.data['data'] as List;
      requests.value = data.map((j) => ClaimModel.fromJson(j as Map<String, dynamic>)).toList();
    } catch (e) {
      errorMsg(ApiClient.extractError(e, fallback: 'fetch_failed'.tr));
    } finally {
      isLoading(false);
    }
    _fetchMileageRates();
  }

  Future<void> _fetchMileageRates() async {
    try {
      final res = await ApiClient.instance.get(ApiList.claimsMileageRates);
      mileageRates(MileageRates.fromJson(res.data['data'] as Map<String, dynamic>));
    } catch (_) {}
  }
}
