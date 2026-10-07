import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/routes.dart';
import '../../../widgets/app_page_widgets.dart';

class AdminSettingsScreen extends StatelessWidget {
  final bool showBackButton;
  const AdminSettingsScreen({super.key, this.showBackButton = true});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            AppPageHeader(
              title: 'Admin Settings',
              showBackButton: showBackButton,
            ),
            const SizedBox(height: 12),
            _SettingTile(title: 'Office GPS Radius', subtitle: 'Clokk HQ · 150m geofence', icon: Icons.my_location_rounded, isDark: isDark),
            _SettingTile(title: 'Working Hours', subtitle: '9:00 AM - 6:00 PM · 1h break', icon: Icons.schedule_rounded, isDark: isDark),
            _SettingTile(title: 'Shift Rules', subtitle: 'Morning, remote, rest day and flexible shift templates', icon: Icons.view_week_rounded, isDark: isDark),
            _SettingTile(title: 'Public Holidays', subtitle: 'Malaysia holidays and company replacement days', icon: Icons.event_rounded, isDark: isDark),
            _SettingTile(title: 'Departments', subtitle: 'Operations, Finance, HR, Engineering, Sales', icon: Icons.account_tree_rounded, isDark: isDark),
            _SettingTile(title: 'Roles & Permissions', subtitle: 'Admin, manager, HR verifier and staff access', icon: Icons.admin_panel_settings_rounded, isDark: isDark),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () => Get.toNamed(Routes.employeeManagement),
              icon: const Icon(Icons.people_alt_rounded),
              label: const Text('Manage employees'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isDark;

  const _SettingTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF185FA5).withValues(alpha: 0.12),
            child: Icon(icon, color: const Color(0xFF185FA5)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text(subtitle, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
              ],
            ),
          ),
          Switch(value: true, onChanged: (_) {}),
        ],
      ),
    );
  }
}
