import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/apply_controller/apply_overtime_controller.dart';

class ApplyOvertimeBinding extends Bindings {
  @override
  void dependencies() =>
      Get.lazyPut<ApplyOvertimeController>(() => ApplyOvertimeController());
}
