import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/remote_work_controller/remote_work_controller.dart';
import 'package:staff_attendance/apps/controllers/remote_work_request_controller/remote_work_request_controller.dart';

class RemoteWorkBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RemoteWorkController>(() => RemoteWorkController());
    Get.lazyPut<RemoteWorkRequestController>(() => RemoteWorkRequestController());
  }
}
