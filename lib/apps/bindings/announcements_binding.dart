import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/announcements_controller/announcements_controller.dart';

class AnnouncementsBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut<AnnouncementsController>(
    () => AnnouncementsController(),
  );
}
