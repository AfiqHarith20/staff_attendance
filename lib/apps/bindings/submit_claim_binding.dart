import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/submit_claim_controller/submit_claim_controller.dart';

class SubmitClaimBinding extends Bindings {
  @override
  void dependencies() =>
      Get.lazyPut<SubmitClaimController>(() => SubmitClaimController());
}
