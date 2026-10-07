import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/help_support_controller/help_support_controller.dart';

class HelpSupportBinding extends Bindings {
  @override
  void dependencies() =>
      Get.lazyPut<HelpSupportController>(() => HelpSupportController());
}
