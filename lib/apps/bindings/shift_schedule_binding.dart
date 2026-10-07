import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/shift_schedule_controller/shift_schedule_controller.dart';

class ShiftScheduleBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut<ShiftScheduleController>(
        () => ShiftScheduleController(),
      );
}
