import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/performance_controller/performance_controller.dart';

class PerformanceBinding extends Bindings {
  @override
  void dependencies() =>
      Get.lazyPut<PerformanceController>(() => PerformanceController());
}
