import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/team_attendance_controller/team_attendance_controller.dart';

class TeamAttendanceBinding extends Bindings {
  @override
  void dependencies() =>
      Get.lazyPut<TeamAttendanceController>(() => TeamAttendanceController());
}
