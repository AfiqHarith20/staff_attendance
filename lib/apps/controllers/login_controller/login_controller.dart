import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../apps/routes/routes.dart';
import '../../../api/api_client.dart';

class LoginController extends GetxController {
  final _emailController = ''.obs;
  final _passwordController = ''.obs;
  final _isLoading = false.obs;
  final _obscurePassword = true.obs;
  final _errorMessage = ''.obs;

  bool get isLoading => _isLoading.value;
  bool get obscurePassword => _obscurePassword.value;
  String get errorMessage => _errorMessage.value;

  void setEmail(String v) => _emailController(v.trim());
  void setPassword(String v) => _passwordController(v);
  void toggleObscure() => _obscurePassword(!_obscurePassword.value);

  Future<void> login(String email, String password) async {
    try {
      _isLoading(true);
      _errorMessage('');

      final response = await ApiClient.instance.post(
        '/auth/login',
        data: {
          'email': email.trim(),
          'password': password,
        },
      );

      final data = response.data['data'] as Map<String, dynamic>;
      final token = data['token'] as String;
      final role = data['role'] as String;
      final user = data['user'] as Map<String, dynamic>?;
      final emailAddress = user?['email'] as String? ?? 'ahmad@clokk.app';
      final displayName = _displayNameFromUser(user, emailAddress, role);

      await GetStorage().write('auth_token', token);
      await GetStorage().write('user_role', role);
      await GetStorage().write('user_name', displayName);
      await GetStorage().write('user_email', emailAddress);
      await GetStorage().write(
        'job_title',
        user?['job_title'] as String? ?? 'Operations Executive',
      );
      await GetStorage().write(
        'department_name',
        user?['department'] as String? ?? 'Operations',
      );

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

  String _displayNameFromUser(
    Map<String, dynamic>? user,
    String email,
    String role,
  ) {
    final name = (user?['name'] as String?)?.trim();
    if (name != null && name.isNotEmpty) return name;

    final local = email.split('@').first.trim();
    if (local.isNotEmpty) {
      final words = local
          .split(RegExp(r'[._-]+'))
          .where((word) => word.trim().isNotEmpty)
          .map((word) {
            final clean = word.trim();
            return clean[0].toUpperCase() + clean.substring(1).toLowerCase();
          })
          .toList();
      if (words.isNotEmpty) return words.join(' ');
    }

    return 'Ahmad Nizam';
  }
}
