import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/leave_balance_controller/leave_balance_controller.dart';

class LeaveBalanceBinding extends Bindings {
  @override
  void dependencies() =>
      Get.lazyPut<LeaveBalanceController>(() => LeaveBalanceController());
}
