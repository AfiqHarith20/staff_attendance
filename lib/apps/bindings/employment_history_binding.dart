import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/employment_history_controller/employment_history_controller.dart';

class EmploymentHistoryBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut<EmploymentHistoryController>(
        () => EmploymentHistoryController(),
      );
}
