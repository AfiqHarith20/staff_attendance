import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:staff_attendance/api/api_client.dart';
import 'package:staff_attendance/apps/models/admin_dashboard_model.dart';
import 'package:staff_attendance/apps/routes/api_routes.dart';
import 'package:staff_attendance/widgets/app_toast.dart';

class AdminDashboardController extends GetxController {
  final stats = Rxn<AdminDashboardModel>();
  final isLoading = false.obs;
  final hasError = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStats();
  }

  Future<void> fetchStats() async {
    try {
      isLoading(true);
      hasError(false);
      final res = await ApiClient.instance.get(ApiList.adminDashboardStats);
      stats.value = AdminDashboardModel.fromJson(
        res.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      hasError(true);
      AppToast.failed('Failed', ApiClient.extractError(e, fallback: 'Could not load dashboard.'));
    } catch (_) {
      hasError(true);
    } finally {
      isLoading(false);
    }
  }
}
