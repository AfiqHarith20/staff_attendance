import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/job_board_controller/job_board_controller.dart';

class JobBoardBinding extends Bindings {
  @override
  void dependencies() =>
      Get.lazyPut<JobBoardController>(() => JobBoardController());
}
