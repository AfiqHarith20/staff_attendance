import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/approval_inbox_controller/approval_inbox_controller.dart';

class ApprovalInboxBinding extends Bindings {
  @override
  void dependencies() =>
      Get.lazyPut<ApprovalInboxController>(() => ApprovalInboxController());
}
