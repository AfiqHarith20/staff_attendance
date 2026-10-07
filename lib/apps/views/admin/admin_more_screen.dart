import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/profile_controller/profile_controller.dart';
import 'package:staff_attendance/apps/routes/routes.dart';
import 'package:staff_attendance/apps/themes/app_colors.dart';
import 'package:staff_attendance/apps/views/home/profile_screen/profile_screen.dart';
import 'package:staff_attendance/widgets/app_page_widgets.dart';
import 'package:staff_attendance/widgets/app_version_text.dart';
import 'package:staff_attendance/widgets/responsive_page.dart';

class AdminMoreScreen extends StatelessWidget {
  final bool showBackButton;
  const AdminMoreScreen({super.key, this.showBackButton = false});

  @override
  Widget build(BuildContext context) {
    final profile = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final text = isDark ? Colors.white : const Color(0xFF0F172A);
    final muted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: ResponsivePage(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            children: [
              AppPageHeader(
                title: 'More',
                showBackButton: showBackButton,
                actions: [
                  IconButton(
                    tooltip: 'Notifications',
                    onPressed: () => Get.toNamed(Routes.notifications),
                    icon: const Icon(Icons.notifications_active_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Obx(
                  () => Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.primary,
                        backgroundImage: profile.profileImageBytes != null
                            ? MemoryImage(profile.profileImageBytes!)
                            : null,
                        child: profile.profileImageBytes == null
                            ? Text(
                                profile.initials,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.fullName,
                              style: TextStyle(
                                color: text,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${profile.roleLabel} · ${profile.department}',
                              style: TextStyle(
                                color: muted,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => Get.to(() => const ProfileScreen()),
                        child: const Text('Profile'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              _SectionLabel(label: 'Admin workspace', isDark: isDark),
              _AdminMenuGroup(
                items: [
                  _AdminMenuItem(
                    icon: Icons.settings_rounded,
                    iconColor: const Color(0xFF185FA5),
                    title: 'Admin Settings',
                    subtitle: 'GPS radius, shifts, departments and permissions',
                    onTap: () => Get.toNamed(Routes.adminSettings),
                  ),
                  _AdminMenuItem(
                    icon: Icons.people_alt_rounded,
                    iconColor: const Color(0xFF16A34A),
                    title: 'Employee Management',
                    subtitle:
                        'Staff list, departments, shifts and account status',
                    onTap: () => Get.toNamed(Routes.employeeManagement),
                  ),
                  _AdminMenuItem(
                    icon: Icons.warning_amber_rounded,
                    iconColor: const Color(0xFFD85A30),
                    title: 'Live Exceptions Board',
                    subtitle: 'Late, absent, missing checkout and GPS issues',
                    onTap: () => Get.toNamed(Routes.liveExceptionsBoard),
                  ),
                  _AdminMenuItem(
                    icon: Icons.apartment_rounded,
                    iconColor: const Color(0xFF185FA5),
                    title: 'Department Dashboard',
                    subtitle: 'Attendance, leave and exceptions by department',
                    onTap: () => Get.toNamed(Routes.departmentDashboard),
                  ),
                  _AdminMenuItem(
                    icon: Icons.fact_check_rounded,
                    iconColor: const Color(0xFFF59E0B),
                    title: 'Attendance Regularization Review',
                    subtitle:
                        'Review correction requests and manual adjustments',
                    onTap: () =>
                        Get.toNamed(Routes.attendanceRegularizationReview),
                  ),
                  _AdminMenuItem(
                    icon: Icons.event_note_rounded,
                    iconColor: const Color(0xFF7F77DD),
                    title: 'Shift Assignment Planner',
                    subtitle: 'Plan weekly shift coverage and assignments',
                    onTap: () => Get.toNamed(Routes.shiftAssignmentPlanner),
                  ),
                  _AdminMenuItem(
                    icon: Icons.event_available_rounded,
                    iconColor: const Color(0xFF185FA5),
                    title: 'Holiday / Calendar Management',
                    subtitle: 'Manage public, replacement and company holidays',
                    onTap: () => Get.toNamed(Routes.holidayCalendarManagement),
                  ),
                  _AdminMenuItem(
                    icon: Icons.payments_rounded,
                    iconColor: const Color(0xFF16A34A),
                    title: 'Payroll Prep Page',
                    subtitle: 'Prepare attendance totals and payroll exports',
                    onTap: () => Get.toNamed(Routes.payrollPrep),
                  ),
                  _AdminMenuItem(
                    icon: Icons.lock_open_rounded,
                    iconColor: const Color(0xFF7F77DD),
                    title: 'Role & Access Management',
                    subtitle:
                        'Control what staff, manager, HR and admin can do',
                    onTap: () => Get.toNamed(Routes.roleAccessManagement),
                  ),
                  _AdminMenuItem(
                    icon: Icons.support_agent_rounded,
                    iconColor: const Color(0xFF7F77DD),
                    title: 'Help / HR Support',
                    subtitle: 'FAQ, HR contacts, rules and report issue form',
                    onTap: () => Get.toNamed(Routes.helpSupport),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _SectionLabel(label: 'Account', isDark: isDark),
              _AdminMenuGroup(
                items: [
                  _AdminMenuItem(
                    icon: Icons.person_rounded,
                    iconColor: const Color(0xFF185FA5),
                    title: 'My Profile',
                    subtitle: 'Employment info, payroll summary and security',
                    onTap: () => Get.to(() => const ProfileScreen()),
                  ),
                  _AdminMenuItem(
                    icon: Icons.logout_rounded,
                    iconColor: const Color(0xFFDC2626),
                    title: 'Logout',
                    subtitle: 'Sign out from this admin account',
                    onTap: profile.confirmLogout,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AppVersionText(
                style: TextStyle(
                  color: muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isDark;
  const _SectionLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _AdminMenuGroup extends StatelessWidget {
  final List<_AdminMenuItem> items;
  const _AdminMenuGroup({required this.items});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            _AdminMenuRow(item: items[i]),
            if (i != items.length - 1)
              Divider(
                height: 1,
                indent: 62,
                endIndent: 14,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : const Color(0xFFF1F5F9),
              ),
          ],
        ],
      ),
    );
  }
}

class _AdminMenuItem {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AdminMenuItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}

class _AdminMenuRow extends StatelessWidget {
  final _AdminMenuItem item;
  const _AdminMenuRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark
        ? const Color(0xFFE2E8F0)
        : const Color(0xFF1E293B);
    final subtitleColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: item.iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(item.icon, color: item.iconColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      style: TextStyle(color: subtitleColor, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: isDark
                    ? const Color(0xFF64748B)
                    : const Color(0xFFCBD5E1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
