import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staff_attendance/apps/bindings/login_binding.dart';
import 'package:staff_attendance/apps/routes/routes.dart';
import 'package:staff_attendance/apps/themes/app_colors.dart';
import 'package:staff_attendance/apps/views/auth/login_screen/login_screen.dart';
import 'package:staff_attendance/widgets/app_page_widgets.dart';
import 'package:staff_attendance/widgets/app_toast.dart';
import 'package:staff_attendance/widgets/auth_widgets.dart';

enum RegisterRole { admin, staff }

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
  RegisterRole _role = RegisterRole.staff;

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
    AppToast.success('Success', 'Account created (demo)');
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
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final inputBg =
        Theme.of(context).inputDecorationTheme.fillColor ?? AppColors.surface;
    final inputBorder = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);
    final hintColor =
        Theme.of(context).inputDecorationTheme.hintStyle?.color ??
        AppColors.textMuted;
    final labelColor = AppColors.textMuted;
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.textPrimary;
    final subColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textMuted;
    final primary = AppColors.primary;
    final accent = AppColors.accent;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : const Color(0xFFE2E8F0);
    final heroBg = isDark ? const Color(0xFF10243A) : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final keyboardBottom = MediaQuery.of(context).viewInsets.bottom;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24, 16, 24, keyboardBottom + 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          AppBackButton(onPressed: _handleBack),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'create_account'.tr,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: heroBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.person_add_alt_1_rounded,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Set up a new account',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Create a staff or admin profile with a work email, secure password, and the right role for the app experience.',
                              style: TextStyle(
                                color: subColor,
                                fontSize: 13,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      AppCard(
                        padding: const EdgeInsets.all(18),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Account type',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Choose the role first so the new account matches the right dashboard and permissions.',
                                style: TextStyle(
                                  color: subColor,
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _RoleOption(
                                label: 'admin_owner'.tr,
                                subtitle:
                                    'Admin dashboard, approvals, reports and team management',
                                icon: Icons.admin_panel_settings_rounded,
                                active: _role == RegisterRole.admin,
                                isDark: isDark,
                                onTap: () =>
                                    setState(() => _role = RegisterRole.admin),
                              ),
                              const SizedBox(height: 10),
                              _RoleOption(
                                label: 'staff'.tr,
                                subtitle:
                                    'Attendance, leave, claims, documents and personal profile',
                                icon: Icons.badge_rounded,
                                active: _role == RegisterRole.staff,
                                isDark: isDark,
                                onTap: () =>
                                    setState(() => _role = RegisterRole.staff),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                'Profile details',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 12),
                              FieldLabel(
                                label: 'full_name'.tr,
                                color: labelColor,
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _nameCtrl,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 15,
                                ),
                                decoration: _inputDecoration(
                                  hintText: 'Your full name',
                                  hintColor: hintColor,
                                  inputBg: inputBg,
                                  inputBorder: inputBorder,
                                  focusColor: accent,
                                  icon: Icons.person_outline_rounded,
                                ),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? 'Name is required'
                                    : null,
                              ),
                              const SizedBox(height: 14),
                              FieldLabel(
                                label: 'email_address'.tr,
                                color: labelColor,
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 15,
                                ),
                                decoration: _inputDecoration(
                                  hintText: 'your@email.com',
                                  hintColor: hintColor,
                                  inputBg: inputBg,
                                  inputBorder: inputBorder,
                                  focusColor: accent,
                                  icon: Icons.mail_outline_rounded,
                                ),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Email is required';
                                  }
                                  if (!GetUtils.isEmail(v.trim())) {
                                    return 'Enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 18),
                              Text(
                                'Security',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Use at least 6 characters and confirm the password before creating the demo account.',
                                style: TextStyle(
                                  color: subColor,
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 12),
                              FieldLabel(
                                label: 'password'.tr,
                                color: labelColor,
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _passwordCtrl,
                                obscureText: true,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 15,
                                ),
                                decoration: _inputDecoration(
                                  hintText: '••••••••',
                                  hintColor: hintColor,
                                  inputBg: inputBg,
                                  inputBorder: inputBorder,
                                  focusColor: accent,
                                  icon: Icons.lock_outline_rounded,
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Password is required';
                                  }
                                  if (v.length < 6) {
                                    return 'Minimum 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              FieldLabel(
                                label: 'confirm_password'.tr,
                                color: labelColor,
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _confirmCtrl,
                                obscureText: true,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 15,
                                ),
                                decoration: _inputDecoration(
                                  hintText: '••••••••',
                                  hintColor: hintColor,
                                  inputBg: inputBg,
                                  inputBorder: inputBorder,
                                  focusColor: accent,
                                  icon: Icons.verified_user_outlined,
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Confirm your password';
                                  }
                                  if (v != _passwordCtrl.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 18),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: primary.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: primary.withValues(alpha: 0.14),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.info_outline_rounded,
                                        size: 17,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'This currently creates a demo account flow and returns to login after submission.',
                                        style: TextStyle(
                                          color: isDark
                                              ? Colors.white.withValues(
                                                  alpha: 0.84,
                                                )
                                              : const Color(0xFF334155),
                                          fontSize: 11,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
                      ),
                      const Spacer(),
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${'already_have_account'.tr} ',
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
            );
          },
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required Color hintColor,
    required Color inputBg,
    required Color inputBorder,
    required Color focusColor,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: hintColor, fontSize: 15),
      fillColor: inputBg,
      prefixIcon: Icon(icon, color: hintColor, size: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: inputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: focusColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDC2626)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
      ),
    );
  }
}

class _RoleOption extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final bool active;
  final bool isDark;
  final VoidCallback onTap;

  const _RoleOption({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.active,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = active
        ? const Color(0xFF185FA5).withValues(alpha: isDark ? 0.18 : 0.08)
        : isDark
        ? const Color(0xFF0F1C2E)
        : const Color(0xFFF8FAFC);
    final border = active
        ? const Color(0xFF185FA5)
        : isDark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);
    final titleColor = active
        ? const Color(0xFF185FA5)
        : isDark
        ? Colors.white
        : const Color(0xFF0F172A);
    final subtitleColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border, width: active ? 1.4 : 1),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: active
                      ? const Color(0xFF185FA5).withValues(alpha: 0.14)
                      : border.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: active ? const Color(0xFF185FA5) : subtitleColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: subtitleColor,
                        fontSize: 11,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                active
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: active ? const Color(0xFF185FA5) : subtitleColor,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
