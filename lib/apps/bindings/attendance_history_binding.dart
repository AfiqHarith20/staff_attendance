import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/attendance_history_controller/attendance_history_controller.dart';

class AttendanceHistoryBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut<AttendanceHistoryController>(
        () => AttendanceHistoryController(),
      );
}
