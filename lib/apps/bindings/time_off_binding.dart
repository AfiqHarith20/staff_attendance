import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/time_off_controller/time_off_controller.dart';

class TimeOffBinding extends Bindings {
  @override
  void dependencies() =>
      Get.lazyPut<TimeOffController>(() => TimeOffController());
}
