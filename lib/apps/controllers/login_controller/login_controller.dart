import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../apps/routes/routes.dart';
import '../../../api/api_client.dart';
import '../../../apps/routes/api_routes.dart';
import '../../../core/services/device_service.dart';

class LoginController extends GetxController {
  final _emailController = ''.obs;
  final _passwordController = ''.obs;
  final _isLoading = false.obs;
  final _obscurePassword = true.obs;
  final _errorMessage = ''.obs;
  final rememberMe = false.obs;

  final _box = GetStorage();

  bool get isLoading => _isLoading.value;
  bool get obscurePassword => _obscurePassword.value;
  String get errorMessage => _errorMessage.value;

  String get savedEmail => _box.read<String>('saved_email') ?? '';
  String get savedPassword => _box.read<String>('saved_password') ?? '';

  @override
  void onInit() {
    super.onInit();
    final remembered = _box.read<bool>('remember_me') ?? false;
    rememberMe(remembered);
  }

  void setEmail(String v) => _emailController(v.trim());
  void setPassword(String v) => _passwordController(v);
  void toggleObscure() => _obscurePassword(!_obscurePassword.value);
  void toggleRememberMe() => rememberMe(!rememberMe.value);

  Future<void> login(String email, String password) async {
    // Persist remember-me preference immediately so it survives a failed login
    await _box.write('remember_me', rememberMe.value);
    if (!rememberMe.value) {
      await _box.remove('saved_email');
      await _box.remove('saved_password');
    }

    try {
      _isLoading(true);
      _errorMessage('');

      final response = await ApiClient.instance.post(
        ApiList.login,
        data: {
          'email': email.trim(),
          'password': password,
        },
      );

      final data = response.data['data'] as Map<String, dynamic>;
      final token = data['token'] as String;
      final role = data['role'] as String;
      final isAdmin = data['is_admin'] as bool? ?? false;
      final user = data['user'] as Map<String, dynamic>?;
      final emailAddress = user?['email'] as String? ?? 'ahmad@clokk.app';
      final displayName = _displayNameFromUser(user, emailAddress, role);

      final box = GetStorage();
      await box.write('auth_token', token);
      await box.write('user_role', role);
      await box.write('is_admin', isAdmin);
      await box.write('user_name', displayName);
      await box.write('user_email', emailAddress);
      await box.write('job_title', user?['job_title'] as String? ?? '');
      await box.write('department_name', user?['department'] as String? ?? '');
      await box.write('employee_no', user?['employee_no'] as String? ?? '');
      if (user?['phone'] != null) await box.write('user_phone', user!['phone']);
      if (user?['joined_on'] != null) await box.write('joined_on', user!['joined_on']);
      if (user?['avatar_url'] != null) {
        await box.write('avatar_url', ApiList.normalizeUrl(user!['avatar_url'] as String));
      }

      // Web-admin-configurable feature permissions for this user.
      // The API returns a list of string keys, e.g. ['team_attendance', 'approval_inbox'].
      // An absent or null field means no extra permissions.
      final rawPerms = data['permissions'];
      final permissions = rawPerms is List
          ? rawPerms.map((e) => e.toString()).toList()
          : <String>[];
      await box.write('user_permissions', permissions);

      // Persist credentials if remember me is on
      if (rememberMe.value) {
        await _box.write('saved_email', email.trim());
        await _box.write('saved_password', password);
      }

      // Navigate into the app shell (bottom navigation)
      Get.offAllNamed(Routes.app);

      // Register device token with backend (fire-and-forget).
      DeviceService.register();
    } on DioException catch (e) {
      debugPrint('LOGIN DioException: ${e.type} | ${e.message} | ${e.response?.statusCode} | ${e.response?.data}');
      _errorMessage(
        e.response?.data?['message'] as String? ?? 'Login failed. Try again.',
      );
    } catch (e, st) {
      debugPrint('LOGIN error: $e\n$st');
      _errorMessage('Error: $e');
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
