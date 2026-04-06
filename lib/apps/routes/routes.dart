import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staff_attendance/apps/views/auth/login_screen/login_screen.dart';
import 'package:staff_attendance/apps/views/auth/registration_screen/register_screen.dart';
import 'package:staff_attendance/apps/views/home/dashboard_screen/dashboard_screen.dart';
import 'package:staff_attendance/apps/views/home/bottom_nav/bottom_nav.dart';
import 'package:staff_attendance/apps/views/home/my_attendance_screen/my_attendance_screen.dart';
import 'package:staff_attendance/apps/views/splash_screen/splash_screen.dart';
import 'package:staff_attendance/core/bindings/login_binding/login_binding.dart';
import 'package:staff_attendance/core/bindings/register_binding.dart/register_binding.dart';
import 'package:staff_attendance/core/bindings/scan_binding/scan_binding.dart';

abstract class Routes {
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const dashboard = '/dashboard';
  static const app = '/app';
  static const scan = '/scan';

  // ── New routes from Other screen ──
  static const calendar = '/calendar';
  static const timeOff = '/time-off';
  static const applyLeave = '/apply-leave';
  static const applyOvertime = '/apply-overtime';
  static const submitClaim = '/submit-claim';
  static const myDocuments = '/my-documents';
  static const paySlip = '/pay-slip';
  static const organisation = '/organisation';
  static const companyPolicy = '/company-policy';
  static const announcements = '/announcements';

  static final list = [
    GetPage(name: splash, page: () => const SplashScreen()),
    // lib/apps/routes/routes.dart
    GetPage(
      name: Routes.login,
      page: () => const LoginScreen(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.register,
      page: () => const RegisterScreen(),
      binding: RegisterBinding(),
    ),
    GetPage(name: dashboard, page: () => const DashboardScreen()),
    GetPage(name: app, page: () => const BottomNavScreen()),
    GetPage(name: scan, page: () => const MyAttendanceScreen()),
    GetPage(
      name: Routes.scan,
      page: () => const MyAttendanceScreen(),
      binding: ScanBinding(),
    ),

    // Placeholder pages — replace with real screens later
    GetPage(
      name: calendar,
      page: () => const _PlaceholderScreen(title: 'Calendar'),
    ),
    GetPage(
      name: timeOff,
      page: () => const _PlaceholderScreen(title: 'Time Off'),
    ),
    GetPage(
      name: applyLeave,
      page: () => const _PlaceholderScreen(title: 'Apply Leave'),
    ),
    GetPage(
      name: applyOvertime,
      page: () => const _PlaceholderScreen(title: 'Apply Overtime'),
    ),
    GetPage(
      name: submitClaim,
      page: () => const _PlaceholderScreen(title: 'Submit Claim'),
    ),
    GetPage(
      name: myDocuments,
      page: () => const _PlaceholderScreen(title: 'My Documents'),
    ),
    GetPage(
      name: paySlip,
      page: () => const _PlaceholderScreen(title: 'Pay Slip'),
    ),
    GetPage(
      name: organisation,
      page: () => const _PlaceholderScreen(title: 'Organisation'),
    ),
    GetPage(
      name: companyPolicy,
      page: () => const _PlaceholderScreen(title: 'Company Policy'),
    ),
    GetPage(
      name: announcements,
      page: () => const _PlaceholderScreen(title: 'Announcements'),
    ),
  ];
}

// Temporary placeholder — replace each one bila screen dah siap
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark
            ? const Color(0xFF0F172A)
            : const Color(0xFFF8FAFC),
        foregroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.construction_rounded,
              size: 48,
              color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
            ),
            const SizedBox(height: 12),
            Text(
              'Coming soon',
              style: TextStyle(
                color: isDark
                    ? const Color(0xFF475569)
                    : const Color(0xFF94A3B8),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFCBD5E1),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
