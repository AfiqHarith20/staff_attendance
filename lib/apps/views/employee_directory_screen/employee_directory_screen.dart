import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/employee_directory_controller/employee_directory_controller.dart';
import 'package:staff_attendance/apps/models/employee_summary_model.dart';
import 'package:staff_attendance/apps/themes/app_colors.dart';
import 'package:staff_attendance/widgets/app_page_widgets.dart';

class EmployeeDirectoryScreen extends GetView<EmployeeDirectoryController> {
  const EmployeeDirectoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final text = isDark ? Colors.white : const Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppPageHeader(title: 'Employee Directory'),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller.searchController,
                    onChanged: controller.onSearch,
                    decoration: InputDecoration(
                      hintText: 'Search by name, email or employee no.',
                      hintStyle: TextStyle(
                        color: text.withOpacity(0.4),
                        fontSize: 13,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: text.withOpacity(0.4),
                      ),
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFEFF2F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary, strokeWidth: 2.5),
                  );
                }
                if (controller.hasError.value) {
                  return _ErrorRetry(
                    isDark: isDark,
                    onRetry: () => controller.fetchEmployees(reset: true),
                  );
                }
                final list = controller.filtered;
                if (list.isEmpty) {
                  return Center(
                    child: Text(
                      'No employees found.',
                      style: TextStyle(color: text.withOpacity(0.4)),
                    ),
                  );
                }
                return NotificationListener<ScrollNotification>(
                  onNotification: (n) {
                    if (n is ScrollEndNotification &&
                        n.metrics.extentAfter < 80 &&
                        !controller.isLoadingMore.value) {
                      controller.fetchEmployees();
                    }
                    return false;
                  },
                  child: RefreshIndicator(
                    onRefresh: () => controller.fetchEmployees(reset: true),
                    color: AppColors.primary,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      itemCount: list.length + 1,
                      separatorBuilder: (_, __) => const SizedBox(height: 6),
                      itemBuilder: (_, i) {
                        if (i == list.length) {
                          return Obx(() => controller.isLoadingMore.value
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                        color: AppColors.primary,
                                        strokeWidth: 2),
                                  ),
                                )
                              : const SizedBox.shrink());
                        }
                        return _EmployeeCard(
                            employee: list[i], isDark: isDark);
                      },
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmployeeCard extends StatelessWidget {
  const _EmployeeCard({required this.employee, required this.isDark});

  final EmployeeSummaryModel employee;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final text = isDark ? Colors.white : const Color(0xFF0F172A);
    final sub = text.withOpacity(0.5);

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primary.withOpacity(0.15),
            backgroundImage: employee.avatarUrl != null
                ? NetworkImage(employee.avatarUrl!)
                : null,
            child: employee.avatarUrl == null
                ? Text(
                    employee.name.isNotEmpty
                        ? employee.name[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee.name,
                  style: TextStyle(
                    color: text,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  employee.jobTitle ?? employee.email,
                  style: TextStyle(color: sub, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (employee.department != null)
                  Text(
                    employee.department!,
                    style: TextStyle(color: sub, fontSize: 11),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: employee.isActive
                      ? const Color(0xFF16A34A).withOpacity(0.12)
                      : Colors.grey.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  employee.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    color: employee.isActive
                        ? const Color(0xFF16A34A)
                        : Colors.grey,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (employee.employeeNo != null) ...[
                const SizedBox(height: 4),
                Text(
                  employee.employeeNo!,
                  style: TextStyle(color: sub, fontSize: 11),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  const _ErrorRetry({required this.isDark, required this.onRetry});

  final bool isDark;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded,
              size: 48, color: Colors.red.withOpacity(0.6)),
          const SizedBox(height: 12),
          Text(
            'Failed to load employees',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
