import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../apps/routes/routes.dart';
import '../../../api/api_client.dart';

enum UserRole { admin, staff }

class LoginController extends GetxController {
  final _emailController = ''.obs;
  final _passwordController = ''.obs;
  final _isLoading = false.obs;
  final _obscurePassword = true.obs;
  final _selectedRole = UserRole.staff.obs;
  final _errorMessage = ''.obs;

  bool get isLoading => _isLoading.value;
  bool get obscurePassword => _obscurePassword.value;
  UserRole get selectedRole => _selectedRole.value;
  String get errorMessage => _errorMessage.value;

  void setEmail(String v) => _emailController(v.trim());
  void setPassword(String v) => _passwordController(v);
  void toggleObscure() => _obscurePassword(!_obscurePassword.value);
  void setRole(UserRole role) => _selectedRole(role);

  Future<void> login(String email, String password) async {
    try {
      _isLoading(true);
      _errorMessage('');

      final response = await ApiClient.instance.post(
        '/auth/login',
        data: {
          'email': email.trim(),
          'password': password,
          'role': selectedRole.name, // 'admin' or 'staff'
        },
      );

      final token = response.data['data']['token'] as String;
      final role = response.data['data']['role'] as String;

      await GetStorage().write('auth_token', token);
      await GetStorage().write('user_role', role);

      // Navigate into the app shell (bottom navigation)
      Get.offAllNamed(Routes.app);
    } on DioException catch (e) {
      _errorMessage(
        e.response?.data['message'] as String? ?? 'Login failed. Try again.',
      );
    } catch (_) {
      _errorMessage('Unexpected error. Please try again.');
    } finally {
      _isLoading(false);
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}
