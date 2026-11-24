import 'package:get/get.dart';
import 'package:staff_attendance/api/api_client.dart';
import 'package:staff_attendance/core/services/storage_service.dart';

class TokenController extends GetxController {
  final token = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final stored = StorageService.to.getAuthToken() ?? '';
    token.value = stored;
    // Restore the bearer token into ApiClient so requests work after cold start.
    ApiClient.instance.setAuthToken(stored.isEmpty ? null : stored);
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
