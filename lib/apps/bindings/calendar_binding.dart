// ── Binding ──────────────────────────────────────────────────────────────────
import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/calendar_controller/calendar_controller.dart';

class CalendarBinding extends Bindings {
  @override
  void dependencies() =>
      Get.lazyPut<CalendarController>(() => CalendarController());
}
