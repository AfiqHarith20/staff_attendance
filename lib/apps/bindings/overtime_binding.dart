import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/apply_controller/apply_overtime_controller.dart';
import 'package:staff_attendance/apps/controllers/overtime_controller/overtime_controller.dart';

class OvertimeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OvertimeController>(() => OvertimeController());
    Get.lazyPut<ApplyOvertimeController>(() => ApplyOvertimeController());
  }
}
