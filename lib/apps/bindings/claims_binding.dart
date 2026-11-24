import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/claims_controller/claims_controller.dart';
import 'package:staff_attendance/apps/controllers/submit_claim_controller/submit_claim_controller.dart';

class ClaimsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ClaimsController>(() => ClaimsController());
    Get.lazyPut<SubmitClaimController>(() => SubmitClaimController());
  }
}
