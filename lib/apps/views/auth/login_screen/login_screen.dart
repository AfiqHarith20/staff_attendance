import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/locale_controller/locale_controller.dart';
import 'package:staff_attendance/apps/controllers/login_controller/login_controller.dart';
import 'package:staff_attendance/apps/controllers/theme_controller/theme_controller.dart';
import 'package:staff_attendance/apps/routes/routes.dart';
import 'package:staff_attendance/apps/views/auth/registration_screen/register_screen.dart';
import 'package:staff_attendance/core/bindings/register_binding.dart/register_binding.dart';
import 'package:staff_attendance/apps/themes/app_colors.dart';
import 'package:staff_attendance/widgets/auth_widgets.dart';
import '../../../widgets/responsive_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  LoginController get controller => Get.find<LoginController>();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeCtrl = Get.find<ThemeController>();

    // time-based greeting (use localized strings)
    final hour = DateTime.now().hour;
    final greetingKey = hour < 12
        ? 'good_morning'
        : (hour < 18 ? 'good_afternoon' : 'good_evening');

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
    final Color subColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textMuted;
    final Color dotColor = Theme.of(context).colorScheme.secondary;
    final Color primary = AppColors.primary;
    final Color accent = AppColors.accent;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: ResponsivePage(
          wrapWithCard: true,
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
                  const SizedBox(height: 48),

                  // ── Brand row + theme toggle ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: dotColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'CLOKK',
                            style: TextStyle(
                              color: dotColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.08,
                            ),
                          ),
                        ],
                      ),
                      Obx(
                        () => Row(
                          children: [
                            GestureDetector(
                              onTap: themeCtrl.toggle,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 360),
                                width: 44,
                                height: 24,
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: themeCtrl.isDark
                                      ? primary
                                      : const Color(0xFFE2E8F0),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: AnimatedAlign(
                                  duration: const Duration(milliseconds: 360),
                                  alignment: themeCtrl.isDark
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      themeCtrl.isDark
                                          ? Icons.dark_mode_rounded
                                          : Icons.light_mode_rounded,
                                      size: 12,
                                      color: themeCtrl.isDark
                                          ? primary
                                          : const Color(0xFFF59E0B),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Language selector (cleaner menu)
                            PopupMenuButton<String>(
                              tooltip: 'Language',
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              offset: const Offset(0, 40),
                              onSelected: (val) {
                                final loc = val == 'my'
                                    ? const Locale('my', 'MY')
                                    : const Locale('en', 'US');
                                if (Get.isRegistered<LocaleController>()) {
                                  Get.find<LocaleController>().setLocale(loc);
                                } else {
                                  Get.updateLocale(loc);
                                }
                              },
                              itemBuilder: (ctx) {
                                final isMy = Get.locale?.languageCode == 'my';
                                return [
                                  PopupMenuItem(
                                    value: 'en',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Get.locale?.languageCode == 'en'
                                              ? Icons.check_circle_rounded
                                              : Icons.circle_outlined,
                                          size: 16,
                                          color:
                                              Get.locale?.languageCode == 'en'
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.primary
                                              : Colors.grey.shade400,
                                        ),
                                        const SizedBox(width: 10),
                                        const Text('English'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'my',
                                    child: Row(
                                      children: [
                                        Icon(
                                          isMy
                                              ? Icons.check_circle_rounded
                                              : Icons.circle_outlined,
                                          size: 16,
                                          color: isMy
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.primary
                                              : Colors.grey.shade400,
                                        ),
                                        const SizedBox(width: 10),
                                        const Text('Bahasa Melayu'),
                                      ],
                                    ),
                                  ),
                                ];
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      (Get.locale?.languageCode == 'my')
                                          ? 'MY'
                                          : 'EN',
                                      style: TextStyle(
                                        color: dotColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(
                                      Icons.keyboard_arrow_down,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 36),

                  // ── Greeting + headline ──
                  Text(
                    greetingKey.tr,
                    style: TextStyle(
                      color: subColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'sign_in_to_your_account'.tr,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 32),

                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Role selector ──
                        FieldLabel(label: 'role'.tr, color: labelColor),
                        const SizedBox(height: 8),
                        Obx(
                          () => Row(
                            children: [
                              Expanded(
                                child: RolePill(
                                  label: 'admin_owner'.tr,
                                  active:
                                      controller.selectedRole == UserRole.admin,
                                  isDark: isDark,
                                  onTap: () =>
                                      controller.setRole(UserRole.admin),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: RolePill(
                                  label: 'staff'.tr,
                                  active:
                                      controller.selectedRole == UserRole.staff,
                                  isDark: isDark,
                                  onTap: () =>
                                      controller.setRole(UserRole.staff),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ── Email ──
                        FieldLabel(
                          label: 'email_address'.tr,
                          color: labelColor,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(color: textColor, fontSize: 15),
                          decoration: InputDecoration(
                            hintText: 'your@email.com',
                            hintStyle: TextStyle(
                              color: hintColor,
                              fontSize: 15,
                            ),
                            fillColor: inputBg,
                            prefixIcon: Icon(
                              Icons.mail_outline_rounded,
                              size: 18,
                              color: hintColor,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: inputBorder),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isDark ? accent : primary,
                                width: 1.5,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFDC2626),
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFDC2626),
                                width: 1.5,
                              ),
                            ),
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

                        const SizedBox(height: 16),

                        // ── Password ──
                        FieldLabel(label: 'password'.tr, color: labelColor),
                        const SizedBox(height: 8),
                        Obx(
                          () => TextFormField(
                            controller: _passwordCtrl,
                            obscureText: controller.obscurePassword,
                            style: TextStyle(color: textColor, fontSize: 15),
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              hintStyle: TextStyle(
                                color: hintColor,
                                fontSize: 15,
                              ),
                              fillColor: inputBg,
                              prefixIcon: Icon(
                                Icons.lock_outline_rounded,
                                size: 18,
                                color: hintColor,
                              ),
                              suffixIcon: GestureDetector(
                                onTap: controller.toggleObscure,
                                child: Icon(
                                  controller.obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 18,
                                  color: hintColor,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: inputBorder),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDark ? accent : primary,
                                  width: 1.5,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFDC2626),
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFDC2626),
                                  width: 1.5,
                                ),
                              ),
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
                        ),

                        const SizedBox(height: 8),

                        // ── Forgot password ──
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              foregroundColor: isDark ? accent : primary,
                              padding: EdgeInsets.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'forgot_password'.tr,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // ── Error message ──
                        Obx(
                          () => controller.errorMessage.isNotEmpty
                              ? Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFDC2626,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: const Color(
                                        0xFFDC2626,
                                      ).withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    controller.errorMessage,
                                    style: const TextStyle(
                                      color: Color(0xFFDC2626),
                                      fontSize: 14,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),

                        // ── Sign in button ──
                        Obx(
                          () => SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: controller.isLoading
                                  ? null
                                  : () {
                                      if (_formKey.currentState?.validate() ??
                                          false) {
                                        controller.login(
                                          _emailCtrl.text,
                                          _passwordCtrl.text,
                                        );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primary,
                                disabledBackgroundColor: primary.withOpacity(
                                  0.6,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: controller.isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      'sign_in'.tr,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // ── Sign up ──
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'dont_have_account'.tr + ' ',
                          style: TextStyle(color: subColor, fontSize: 14),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Prefer named routes (bindings + middlewares run).
                            // If the route is not registered for any reason,
                            // fall back to direct navigation and apply binding.
                            final exists = Routes.list.any(
                              (p) => p.name == Routes.register,
                            );
                            if (exists) {
                              Get.toNamed(Routes.register);
                            } else {
                              Get.to(
                                () => const RegisterScreen(),
                                binding: RegisterBinding(),
                              );
                            }
                          },
                          child: Text(
                            'sign_up'.tr,
                            style: TextStyle(
                              color: isDark ? accent : primary,
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
      ),
    );
  }
}

// helper widgets moved to lib/apps/views/auth/auth_widgets.dart
