import 'package:flutter/material.dart';
import 'package:staff_attendance/widgets/app_page_widgets.dart';

class RoleAccessManagementScreen extends StatelessWidget {
  const RoleAccessManagementScreen({super.key});

  static const _roles = [
    (
      'Staff',
      'View personal attendance, requests, documents',
      Color(0xFF185FA5),
    ),
    (
      'Manager',
      'Approve team leave, OT, corrections, and view team attendance',
      Color(0xFF16A34A),
    ),
    (
      'HR',
      'Manage documents, attendance adjustments, and payroll prep',
      Color(0xFFF59E0B),
    ),
    (
      'Admin',
      'Full access to settings, employees, reports, and role controls',
      Color(0xFF7F77DD),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final text = isDark ? Colors.white : const Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            const AppPageHeader(title: 'Role & Access Management'),
            const SizedBox(height: 12),
            AppCard(
              child: const Text(
                'Configure what staff, manager, HR, and admin users can view, approve, export, and manage across the attendance app.',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(height: 14),
            for (final role in _roles)
              AppCard(
                margin: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: role.$3.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.admin_panel_settings_rounded,
                        color: role.$3,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  role.$1,
                                  style: TextStyle(
                                    color: text,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              Switch(value: true, onChanged: (_) {}),
                            ],
                          ),
                          Text(
                            role.$2,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
