import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/login_controller/login_controller.dart';
import 'package:staff_attendance/apps/controllers/theme_controller/theme_controller.dart';
import 'package:staff_attendance/apps/themes/app_colors.dart';
import 'package:staff_attendance/apps/routes/routes.dart';
import 'package:staff_attendance/apps/views/auth/login_screen/login_screen.dart';
import 'package:staff_attendance/core/bindings/login_binding/login_binding.dart';
import 'package:staff_attendance/widgets/auth_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  UserRole _role = UserRole.staff;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    // Demo placeholder
    Get.snackbar(
      'Success',
      'Account created (demo)',
      snackPosition: SnackPosition.BOTTOM,
    );
    // Redirect to login using named route if available so bindings run.
    final exists = Routes.list.any((p) => p.name == Routes.login);
    if (exists) {
      Get.offAllNamed(Routes.login);
    } else {
      Get.offAll(() => const LoginScreen(), binding: LoginBinding());
    }
  }

  void _handleBack() {
    final canPop = Get.key.currentState?.canPop() ?? false;
    if (canPop) {
      Get.back();
    } else {
      final exists = Routes.list.any((p) => p.name == Routes.login);
      if (exists) {
        Get.offAllNamed(Routes.login);
      } else {
        Get.offAll(() => const LoginScreen(), binding: LoginBinding());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeCtrl = Get.find<ThemeController>();

    final Color scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final Color inputBg =
        Theme.of(context).inputDecorationTheme.fillColor ?? AppColors.surface;
    final Color inputBorder = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);
    final Color hintColor =
        Theme.of(context).inputDecorationTheme.hintStyle?.color ??
        AppColors.textMuted;
    final Color labelColor = AppColors.textMuted;
    final Color textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.textPrimary;
    final Color primary = AppColors.primary;
    final Color accent = AppColors.accent;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            height:
                MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                MediaQuery.of(context).padding.bottom,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 36),

                // Header with back button and centered title
                Row(
                  children: [
                    IconButton(
                      onPressed: _handleBack,
                      icon: Icon(Icons.arrow_back_ios_new, color: textColor),
                      splashRadius: 20,
                      visualDensity: VisualDensity.compact,
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'create_account'.tr,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 20),

                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FieldLabel(label: 'role'.tr, color: labelColor),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: RolePill(
                              label: 'admin_owner'.tr,
                              active: _role == UserRole.admin,
                              isDark: isDark,
                              onTap: () =>
                                  setState(() => _role = UserRole.admin),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: RolePill(
                              label: 'staff'.tr,
                              active: _role == UserRole.staff,
                              isDark: isDark,
                              onTap: () =>
                                  setState(() => _role = UserRole.staff),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      FieldLabel(label: 'full_name'.tr, color: labelColor),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameCtrl,
                        style: TextStyle(color: textColor, fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'Your full name',
                          hintStyle: TextStyle(color: hintColor, fontSize: 15),
                          fillColor: inputBg,
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color: hintColor,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: inputBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: accent, width: 1.5),
                          ),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Name is required'
                            : null,
                      ),

                      const SizedBox(height: 12),
                      FieldLabel(label: 'email_address'.tr, color: labelColor),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(color: textColor, fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'your@email.com',
                          hintStyle: TextStyle(color: hintColor, fontSize: 15),
                          fillColor: inputBg,
                          prefixIcon: Icon(
                            Icons.mail_outline_rounded,
                            color: hintColor,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: inputBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: accent, width: 1.5),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty)
                            return 'Email is required';
                          if (!GetUtils.isEmail(v.trim()))
                            return 'Enter a valid email';
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),
                      FieldLabel(label: 'password'.tr, color: labelColor),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: true,
                        style: TextStyle(color: textColor, fontSize: 15),
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          hintStyle: TextStyle(color: hintColor, fontSize: 15),
                          fillColor: inputBg,
                          prefixIcon: Icon(
                            Icons.lock_outline_rounded,
                            color: hintColor,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: inputBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: accent, width: 1.5),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return 'Password is required';
                          if (v.length < 6) return 'Minimum 6 characters';
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),
                      FieldLabel(
                        label: 'confirm_password'.tr,
                        color: labelColor,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _confirmCtrl,
                        obscureText: true,
                        style: TextStyle(color: textColor, fontSize: 15),
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          hintStyle: TextStyle(color: hintColor, fontSize: 15),
                          fillColor: inputBg,
                          prefixIcon: Icon(
                            Icons.lock_outline_rounded,
                            color: hintColor,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: inputBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: accent, width: 1.5),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return 'Confirm your password';
                          if (v != _passwordCtrl.text)
                            return 'Passwords do not match';
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'create_account_btn'.tr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'already_have_account'.tr + ' ',
                        style: TextStyle(color: labelColor, fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: () => Get.offAllNamed(Routes.login),
                        child: Text(
                          'sign_in'.tr,
                          style: TextStyle(
                            color: primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
