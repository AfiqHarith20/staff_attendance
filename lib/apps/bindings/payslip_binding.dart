import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/payslip_controller/payslip_controller.dart';

class PayslipBinding extends Bindings {
  @override
  void dependencies() =>
      Get.lazyPut<PayslipController>(() => PayslipController());
}
