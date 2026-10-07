import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/apply_controller/apply_leave_controller.dart';

class ApplyLeaveBinding extends Bindings {
  @override
  void dependencies() =>
      Get.lazyPut<ApplyLeaveController>(() => ApplyLeaveController());
}
