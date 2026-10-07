import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/notifications_controller/notifications_controller.dart';

class NotificationsBinding extends Bindings {
  @override
  void dependencies() =>
      Get.lazyPut<NotificationsController>(() => NotificationsController());
}
