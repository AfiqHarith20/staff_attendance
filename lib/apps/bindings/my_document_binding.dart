import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/my_document_controller/my_document_controller.dart';

class MyDocumentsBinding extends Bindings {
  @override
  void dependencies() =>
      Get.lazyPut<MyDocumentsController>(() => MyDocumentsController());
}
