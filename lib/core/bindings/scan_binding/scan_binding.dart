import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/scan_controller/scan_controller.dart';

class ScanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ScanController>(() => ScanController());
  }
}
