import 'package:flutter/material.dart';
import 'package:staff_attendance/widgets/app_page_widgets.dart';
import 'package:staff_attendance/widgets/app_toast.dart';

class EmployeeManagementScreen extends StatelessWidget {
  const EmployeeManagementScreen({super.key});

  static const _employees = [
    ('Ahmad Nizam', 'Operations', 'Morning Shift', 'Nur Aisyah', true),
    ('Siti Rahmah', 'Finance', 'Morning Shift', 'Nur Aisyah', true),
    ('Daniel Tan', 'Engineering', 'Remote Eligible', 'Maya Lim', true),
    ('Farid Hakim', 'Sales', 'Flexible', 'Nur Aisyah', false),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF8FAFC),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            AppToast.pending('Add employee', 'Employee form coming next.'),
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add staff'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            const AppPageHeader(title: 'Employee Management'),
            const SizedBox(height: 12),
            AppSearchField(
              hintText: 'Search staff, department or manager',
              onChanged: (_) {},
            ),
            const SizedBox(height: 14),
            for (final employee in _employees)
              _EmployeeCard(
                name: employee.$1,
                department: employee.$2,
                shift: employee.$3,
                manager: employee.$4,
                active: employee.$5,
                isDark: isDark,
              ),
          ],
        ),
      ),
    );
  }
}

class _EmployeeCard extends StatelessWidget {
  final String name;
  final String department;
  final String shift;
  final String manager;
  final bool active;
  final bool isDark;

  const _EmployeeCard({
    required this.name,
    required this.department,
    required this.shift,
    required this.manager,
    required this.active,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          CircleAvatar(
            child: Text(name.split(' ').map((part) => part[0]).take(2).join()),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$department · $shift',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
                Text(
                  'Manager: $manager',
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) =>
                AppToast.success('Employee updated', '$value for $name'),
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'Edit profile',
                child: Text('Edit profile'),
              ),
              const PopupMenuItem(
                value: 'Assign shift',
                child: Text('Assign shift'),
              ),
              PopupMenuItem(
                value: active ? 'Deactivate account' : 'Activate account',
                child: Text(active ? 'Deactivate account' : 'Activate account'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
