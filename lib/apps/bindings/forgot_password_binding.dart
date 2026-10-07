import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/forgot_password_controller/forgot_password_controller.dart';

class ForgotPasswordBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut<ForgotPasswordController>(
    () => ForgotPasswordController(),
  );
}
