import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/admin_announcement_controller/admin_announcement_controller.dart';

class AdminAnnouncementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminAnnouncementController>(() => AdminAnnouncementController());
  }
}
