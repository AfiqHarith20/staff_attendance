import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/login_controller/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(() => LoginController());
  }
}
