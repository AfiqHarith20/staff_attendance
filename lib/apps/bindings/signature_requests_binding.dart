import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/signature_requests_controller/signature_requests_controller.dart';

class SignatureRequestsBinding extends Bindings {
  @override
  void dependencies() =>
      Get.lazyPut<SignatureRequestsController>(() => SignatureRequestsController());
}
