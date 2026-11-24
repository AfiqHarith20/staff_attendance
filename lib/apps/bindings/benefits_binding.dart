import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/benefits_controller/benefits_controller.dart';

class BenefitsBinding extends Bindings {
  @override
  void dependencies() =>
      Get.lazyPut<BenefitsController>(() => BenefitsController());
}
