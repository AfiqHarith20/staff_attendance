import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/team_leave_controller/team_leave_controller.dart';

class TeamLeaveBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TeamLeaveController>(() => TeamLeaveController());
  }
}
