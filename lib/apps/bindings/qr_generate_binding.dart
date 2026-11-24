import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/qr_generate_controller/qr_generate_controller.dart';

class QRGenerateBinding extends Bindings {
  @override
  void dependencies() =>
      Get.lazyPut<QRGenerateController>(() => QRGenerateController());
}
