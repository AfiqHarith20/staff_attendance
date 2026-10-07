import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/remote_work_request_controller/remote_work_request_controller.dart';

class RemoteWorkRequestBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut<RemoteWorkRequestController>(
        () => RemoteWorkRequestController(),
      );
}
