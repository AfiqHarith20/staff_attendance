import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/locale_controller/locale_controller.dart';
import 'package:staff_attendance/core/services/storage_service.dart';
import 'package:staff_attendance/core/services/token_controller.dart';
import 'package:staff_attendance/apps/controllers/theme_controller/theme_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(StorageService(), permanent: true);
    Get.put(TokenController(), permanent: true);
    // Theme controller manages light/dark mode and persistence
    Get.put(ThemeController(), permanent: true);
    // Locale controller persists language selection
    Get.put(LocaleController(), permanent: true);
  }
}
