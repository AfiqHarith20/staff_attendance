import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/shift_swap_controller/shift_swap_controller.dart';

class ShiftSwapBinding extends Bindings {
  @override
  void dependencies() =>
      Get.lazyPut<ShiftSwapController>(() => ShiftSwapController());
}
