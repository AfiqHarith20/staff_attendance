import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/profile_controller/profile_controller.dart';
import 'package:staff_attendance/apps/controllers/theme_controller/theme_controller.dart';
import 'package:staff_attendance/apps/themes/app_colors.dart';
import '../../../widgets/responsive_page.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileCtrl = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());
    final themeCtrl = Get.find<ThemeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark
        ? const Color(0xFF0B1324)
        : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF182338) : Colors.white;
    final borderColor = isDark
        ? const Color(0xFF23314F)
        : const Color(0xFFD9E2EC);
    final muted = isDark ? const Color(0xFF8FA3BF) : const Color(0xFF94A3B8);
    final primaryText = isDark ? Colors.white : const Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text('profile'.tr),
        backgroundColor: background,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        top: false,
        child: ResponsivePage(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              Center(
                child: Obx(() {
                  final imageBytes = profileCtrl.profileImageBytes;
                  return Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: AppColors.primary,
                            backgroundImage: imageBytes != null
                                ? MemoryImage(imageBytes)
                                : null,
                            child: imageBytes == null
                                ? Text(
                                    profileCtrl.initials,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  )
                                : null,
                          ),
                          Material(
                            color: Colors.white,
                            elevation: 2,
                            shape: const CircleBorder(),
                            child: InkWell(
                              onTap: profileCtrl.openEditProfileSheet,
                              customBorder: const CircleBorder(),
                              child: const Padding(
                                padding: EdgeInsets.all(6),
                                child: Icon(
                                  Icons.edit_rounded,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        profileCtrl.fullName,
                        style: TextStyle(
                          color: primaryText,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          profileCtrl.roleLabel,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        profileCtrl.office,
                        style: TextStyle(
                          color: muted,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      // const SizedBox(height: 10),
                      // OutlinedButton.icon(
                      //   onPressed: profileCtrl.openEditProfileSheet,
                      //   icon: const Icon(Icons.edit_outlined, size: 18),
                      //   label: Text('edit_profile'.tr),
                      //   style: OutlinedButton.styleFrom(
                      //     foregroundColor: AppColors.primary,
                      //     side: BorderSide(color: borderColor),
                      //     shape: RoundedRectangleBorder(
                      //       borderRadius: BorderRadius.circular(12),
                      //     ),
                      //   ),
                      // ),
                    ],
                  );
                }),
              ),
              const SizedBox(height: 20),
              _StatsCard(
                isDark: isDark,
                cardColor: cardColor,
                borderColor: borderColor,
                presentCount: profileCtrl.presentCount,
                absentCount: profileCtrl.absentCount,
                lateCount: profileCtrl.lateCount,
                mcCount: profileCtrl.mcCount,
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'personal_info'.tr,
                isDark: isDark,
                cardColor: cardColor,
                borderColor: borderColor,
                trailing: TextButton.icon(
                  onPressed: profileCtrl.openEditProfileSheet,
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: Text('edit_profile'.tr),
                ),
                children: [
                  _InfoRow(
                    icon: Icons.email_outlined,
                    title: 'email_address'.tr,
                    value: profileCtrl.email,
                    isDark: isDark,
                  ),
                  _SectionDivider(isDark: isDark),
                  _InfoRow(
                    icon: Icons.phone_iphone_rounded,
                    title: 'phone'.tr,
                    value: profileCtrl.phone,
                    isDark: isDark,
                  ),
                  _SectionDivider(isDark: isDark),
                  _InfoRow(
                    icon: Icons.badge_outlined,
                    title: 'employee_id'.tr,
                    value: profileCtrl.employeeId,
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'preferences'.tr,
                isDark: isDark,
                cardColor: cardColor,
                borderColor: borderColor,
                children: [
                  Obx(
                    () => _SettingRow(
                      icon: Icons.dark_mode_outlined,
                      title: 'dark_mode'.tr,
                      isDark: isDark,
                      trailing: Switch.adaptive(
                        value: themeCtrl.isDark,
                        onChanged: (_) => themeCtrl.toggle(),
                        activeThumbColor: AppColors.primary,
                        activeTrackColor: AppColors.primary.withValues(
                          alpha: 0.35,
                        ),
                      ),
                    ),
                  ),
                  _SectionDivider(isDark: isDark),
                  Obx(
                    () => _SettingRow(
                      icon: Icons.notifications_none_rounded,
                      title: 'notifications'.tr,
                      isDark: isDark,
                      trailing: Switch.adaptive(
                        value: profileCtrl.notificationsEnabled.value,
                        onChanged: profileCtrl.toggleNotifications,
                        activeThumbColor: AppColors.primary,
                        activeTrackColor: AppColors.primary.withValues(
                          alpha: 0.35,
                        ),
                      ),
                    ),
                  ),
                  _SectionDivider(isDark: isDark),
                  Obx(
                    () => _SettingRow(
                      icon: Icons.language_rounded,
                      title: 'change_language'.tr,
                      subtitle: profileCtrl.currentLanguageLabel,
                      isDark: isDark,
                      onTap: profileCtrl.openLanguageSheet,
                      trailing: Icon(Icons.chevron_right_rounded, color: muted),
                    ),
                  ),
                  _SectionDivider(isDark: isDark),
                  _SettingRow(
                    icon: Icons.lock_outline_rounded,
                    title: 'change_password'.tr,
                    isDark: isDark,
                    onTap: profileCtrl.openChangePasswordSheet,
                    trailing: Icon(Icons.chevron_right_rounded, color: muted),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: profileCtrl.confirmLogout,
                icon: const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFF87171),
                ),
                label: Text(
                  'sign_out'.tr,
                  style: const TextStyle(
                    color: Color(0xFFF87171),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  side: BorderSide(
                    color: isDark
                        ? const Color(0xFF4C2230)
                        : const Color(0xFFF3D1D6),
                  ),
                  backgroundColor: isDark
                      ? const Color(0xFF2A1520)
                      : const Color(0xFFFFF5F5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final bool isDark;
  final Color cardColor;
  final Color borderColor;
  final int presentCount;
  final int absentCount;
  final int lateCount;
  final int mcCount;

  const _StatsCard({
    required this.isDark,
    required this.cardColor,
    required this.borderColor,
    required this.presentCount,
    required this.absentCount,
    required this.lateCount,
    required this.mcCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _StatItem(
                value: presentCount.toString(),
                label: 'present'.tr,
                color: const Color(0xFF22C55E),
              ),
            ),
            _VerticalDivider(isDark: isDark),
            Expanded(
              child: _StatItem(
                value: absentCount.toString(),
                label: 'absent'.tr,
                color: const Color(0xFFEF4444),
              ),
            ),
            _VerticalDivider(isDark: isDark),
            Expanded(
              child: _StatItem(
                value: lateCount.toString(),
                label: 'late'.tr,
                color: const Color(0xFFF59E0B),
              ),
            ),
            _VerticalDivider(isDark: isDark),
            Expanded(
              child: _StatItem(
                value: mcCount.toString(),
                label: 'mc'.tr,
                color: const Color(0xFF60A5FA),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Color(0xFF94A3B8),
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final bool isDark;
  final Color cardColor;
  final Color borderColor;
  final Widget? trailing;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.isDark,
    required this.cardColor,
    required this.borderColor,
    required this.children,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool isDark;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F3B62) : const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF334155),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isDark ? const Color(0xFF8FA3BF) : const Color(0xFF94A3B8),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool isDark;
  final VoidCallback? onTap;
  final Widget trailing;

  const _SettingRow({
    required this.icon,
    required this.title,
    required this.isDark,
    required this.trailing,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF2A3348)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF334155),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFF8FA3BF)
                            : const Color(0xFF94A3B8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  final bool isDark;
  const _SectionDivider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 20,
      color: isDark
          ? Colors.white.withValues(alpha: 0.08)
          : const Color(0xFFE2E8F0),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  final bool isDark;
  const _VerticalDivider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: isDark
          ? Colors.white.withValues(alpha: 0.08)
          : const Color(0xFFE2E8F0),
    );
  }
}
