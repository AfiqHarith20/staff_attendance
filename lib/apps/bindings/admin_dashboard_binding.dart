import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/admin_dashboard_controller/admin_dashboard_controller.dart';

class AdminDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminDashboardController>(() => AdminDashboardController());
  }
}
