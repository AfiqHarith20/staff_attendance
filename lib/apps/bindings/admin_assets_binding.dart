import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/admin_assets_controller/admin_assets_controller.dart';

class AdminAssetsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminAssetsController>(() => AdminAssetsController());
  }
}
