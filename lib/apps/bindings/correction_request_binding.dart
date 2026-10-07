import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/correction_request_controller/correction_request_controller.dart';

class CorrectionRequestBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut<CorrectionRequestController>(
        () => CorrectionRequestController(),
      );
}
