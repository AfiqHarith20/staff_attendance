import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/work_hours_summary_controller/work_hours_summary_controller.dart';

class WorkHoursSummaryBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut<WorkHoursSummaryController>(
        () => WorkHoursSummaryController(),
      );
}
