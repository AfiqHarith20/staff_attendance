import 'package:get/get.dart';
import 'package:staff_attendance/core/services/storage_service.dart';

class TokenController extends GetxController {
  final token = ''.obs;

  @override
  void onInit() {
    super.onInit();
    token.value = StorageService.to.getAuthToken() ?? '';
  }

  bool get isLoggedIn => token.value.isNotEmpty;

  void setToken(String t) {
    token.value = t;
    StorageService.to.saveAuthToken(t);
  }

  void clearToken() {
    token.value = '';
    StorageService.to.clearAuthToken();
  }
}
