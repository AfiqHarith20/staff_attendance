import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/employee_directory_controller/employee_directory_controller.dart';

class EmployeeDirectoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmployeeDirectoryController>(() => EmployeeDirectoryController());
  }
}
