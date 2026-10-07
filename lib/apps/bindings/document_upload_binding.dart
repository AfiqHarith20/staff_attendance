import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/document_upload_controller/document_upload_controller.dart';

class DocumentUploadBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut<DocumentUploadController>(
    () => DocumentUploadController(),
  );
}
