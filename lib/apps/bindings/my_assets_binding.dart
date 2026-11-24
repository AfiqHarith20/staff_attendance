import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/my_assets_controller/my_assets_controller.dart';

class MyAssetsBinding extends Bindings {
  @override
  void dependencies() =>
      Get.lazyPut<MyAssetsController>(() => MyAssetsController());
}
