import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/other_controller/other_controller.dart';
import 'package:staff_attendance/apps/routes/routes.dart';
import '../../../../widgets/responsive_page.dart';
import '../../../../widgets/app_page_widgets.dart';

class OtherBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut<OtherController>(() => OtherController());
}

class OtherScreen extends GetView<OtherController> {
  const OtherScreen({super.key});

  static const _categories = [
    'All',
    'Attendance',
    'Requests',
    'Documents',
    'Manager',
    'Company',
  ];

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<OtherController>()) {
      Get.put(OtherController());
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

    final sections = _buildSections(isDark);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.fetchBadgeCounts,
          color: const Color(0xFF185FA5),
          child: ResponsivePage(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 32),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'More',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Notifications',
                        onPressed: () => Get.toNamed(Routes.notifications),
                        icon: const Icon(Icons.notifications_active_rounded),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: AppSearchField(
                    hintText: 'Search pages',
                    onChanged: controller.setSearchQuery,
                  ),
                ),
                const SizedBox(height: 12),
                Obx(
                  () => AppChoiceChips(
                    values: _categories,
                    selected: controller.selectedCategory.value,
                    onChanged: controller.setCategory,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
                const SizedBox(height: 14),
                Obx(() {
                  final visible = _filterSections(sections);
                  if (visible.isEmpty) {
                    return _EmptyState(isDark: isDark);
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final section in visible) ...[
                        _SectionLabel(label: section.title, isDark: isDark),
                        _MenuGroup(isDark: isDark, items: section.items),
                        const SizedBox(height: 12),
                      ],
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<_MenuSection> _filterSections(List<_MenuSection> sections) {
    final category = controller.selectedCategory.value;
    final query = controller.searchQuery.value;

    return sections
        .where((section) => category == 'All' || section.category == category)
        .map((section) {
          if (query.isEmpty) return section;
          final items = section.items.where((item) {
            final text = '${item.title} ${item.subtitle} ${section.title}'
                .toLowerCase();
            return text.contains(query);
          }).toList();
          return _MenuSection(
            title: section.title,
            category: section.category,
            items: items,
          );
        })
        .where((section) => section.items.isNotEmpty)
        .toList();
  }

  List<_MenuSection> _buildSections(bool isDark) {
    return [
      _MenuSection(
        title: 'Attendance',
        category: 'Attendance',
        items: [
          _MenuItem(
            icon: Icons.history_rounded,
            iconBg: _blueBg(isDark),
            iconColor: const Color(0xFF185FA5),
            title: 'Attendance History',
            subtitle: 'Monthly records, flags and hours',
            route: Routes.attendanceHistory,
          ),
          _MenuItem(
            icon: Icons.query_stats_rounded,
            iconBg: _blueBg(isDark),
            iconColor: const Color(0xFF378ADD),
            title: 'Work Hours Summary',
            subtitle: 'Weekly or monthly score and overtime',
            route: Routes.workHoursSummary,
          ),
          _MenuItem(
            icon: Icons.analytics_rounded,
            iconBg: _violetBg(isDark),
            iconColor: const Color(0xFF7F77DD),
            title: 'Attendance Analytics',
            subtitle: 'Late trends, score and average check-in',
            route: Routes.attendanceAnalytics,
          ),
          _MenuItem(
            icon: Icons.edit_calendar_rounded,
            iconBg: _amberBg(isDark),
            iconColor: const Color(0xFFF59E0B),
            title: 'Correction Request',
            subtitle: 'Fix missing or incorrect punch times',
            route: Routes.correctionRequest,
          ),
          _MenuItem(
            icon: Icons.view_week_rounded,
            iconBg: _violetBg(isDark),
            iconColor: const Color(0xFF7F77DD),
            title: 'Shift Schedule',
            subtitle: 'Shifts, rest days and holidays',
            route: Routes.shiftSchedule,
          ),
          _MenuItem(
            icon: Icons.calendar_month_rounded,
            iconBg: _blueBg(isDark),
            iconColor: const Color(0xFF378ADD),
            title: 'Calendar',
            subtitle: 'Leave, events and public holidays',
            route: Routes.calendar,
            badgeBuilder: (c) => Obx(
              () => c.nextHoliday.value.isNotEmpty
                  ? _Badge(
                      label: c.nextHoliday.value,
                      bg: const Color(0xFFFAEEDA),
                      text: const Color(0xFF854F0B),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
      _MenuSection(
        title: 'Requests',
        category: 'Requests',
        items: [
          _MenuItem(
            icon: Icons.track_changes_rounded,
            iconBg: _blueBg(isDark),
            iconColor: const Color(0xFF185FA5),
            title: 'Request Status Tracker',
            subtitle: 'Track leave, claim, OT and request progress',
            route: Routes.requestStatusTracker,
          ),
          _MenuItem(
            icon: Icons.schedule_rounded,
            iconBg: _greenBg(isDark),
            iconColor: const Color(0xFF16A34A),
            title: 'Time Off',
            subtitle: 'Approved and pending leave',
            route: Routes.timeOff,
            badgeBuilder: (c) => Obx(
              () => c.pendingLeave.value > 0
                  ? _Badge(
                      label: '${c.pendingLeave.value} pending',
                      bg: const Color(0xFFFAEEDA),
                      text: const Color(0xFF854F0B),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          _MenuItem(
            icon: Icons.add_box_rounded,
            iconBg: _blueBg(isDark),
            iconColor: const Color(0xFF185FA5),
            title: 'Apply Leave',
            subtitle: 'Annual, emergency or unpaid leave',
            route: Routes.applyLeave,
          ),
          _MenuItem(
            icon: Icons.balance_rounded,
            iconBg: _violetBg(isDark),
            iconColor: const Color(0xFF7F77DD),
            title: 'Leave Balance Detail',
            subtitle: 'Entitlement, pending leave and usage history',
            route: Routes.leaveBalanceDetail,
          ),
          _MenuItem(
            icon: Icons.more_time_rounded,
            iconBg: _amberBg(isDark),
            iconColor: const Color(0xFFF59E0B),
            title: 'Apply Overtime',
            subtitle: 'Request OT approval',
            route: Routes.applyOvertime,
          ),
          _MenuItem(
            icon: Icons.home_work_rounded,
            iconBg: _violetBg(isDark),
            iconColor: const Color(0xFF7F77DD),
            title: 'Remote Work Request',
            subtitle: 'Request WFH or hybrid work',
            route: Routes.remoteWorkRequest,
          ),
          _MenuItem(
            icon: Icons.receipt_long_rounded,
            iconBg: _greenBg(isDark),
            iconColor: const Color(0xFF16A34A),
            title: 'Submit Claim',
            subtitle: 'Medical, transport or other claims',
            route: Routes.submitClaim,
          ),
        ],
      ),
      _MenuSection(
        title: 'Documents & Pay',
        category: 'Documents',
        items: [
          _MenuItem(
            icon: Icons.folder_rounded,
            iconBg: _redBg(isDark),
            iconColor: const Color(0xFFF87171),
            title: 'My Documents',
            subtitle: 'Uploads, MCs, certs and file status',
            route: Routes.myDocuments,
            badgeBuilder: (c) => Obx(
              () => c.pendingDocuments.value > 0
                  ? _Badge(
                      label: '${c.pendingDocuments.value} pending',
                      bg: const Color(0xFFFAEEDA),
                      text: const Color(0xFF854F0B),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          _MenuItem(
            icon: Icons.event_repeat_rounded,
            iconBg: _amberBg(isDark),
            iconColor: const Color(0xFFF59E0B),
            title: 'Document Expiry & Renewal',
            subtitle: 'Track expiring documents and upload renewals',
            route: Routes.documentExpiryRenewal,
          ),
          _MenuItem(
            icon: Icons.upload_file_rounded,
            iconBg: _blueBg(isDark),
            iconColor: const Color(0xFF185FA5),
            title: 'Upload Document',
            subtitle: 'Add MCs or supporting files',
            route: Routes.documentUpload,
          ),
          _MenuItem(
            icon: Icons.download_rounded,
            iconBg: _blueBg(isDark),
            iconColor: const Color(0xFF378ADD),
            title: 'Pay Slip',
            subtitle: 'Download monthly payslip',
            route: Routes.paySlip,
            badgeBuilder: (c) => Obx(
              () => c.payslipReady.value
                  ? _Badge(
                      label: '${c.payslipMonth.value} ready',
                      bg: const Color(0xFFEAF3DE),
                      text: const Color(0xFF3B6D11),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
      _MenuSection(
        title: 'Manager',
        category: 'Manager',
        items: [
          _MenuItem(
            icon: Icons.groups_rounded,
            iconBg: _greenBg(isDark),
            iconColor: const Color(0xFF16A34A),
            title: 'Team Attendance',
            subtitle: 'Present, late, leave and absent today',
            route: Routes.teamAttendance,
          ),
          _MenuItem(
            icon: Icons.approval_rounded,
            iconBg: _amberBg(isDark),
            iconColor: const Color(0xFFF59E0B),
            title: 'Approval Inbox',
            subtitle: 'Approve requests and documents',
            route: Routes.approvalInbox,
          ),
        ],
      ),
      _MenuSection(
        title: 'Company & Support',
        category: 'Company',
        items: [
          _MenuItem(
            icon: Icons.notifications_active_rounded,
            iconBg: _greenBg(isDark),
            iconColor: const Color(0xFF16A34A),
            title: 'Notifications',
            subtitle: 'HR reminders and request updates',
            route: Routes.notifications,
          ),
          _MenuItem(
            icon: Icons.campaign_rounded,
            iconBg: _greenBg(isDark),
            iconColor: const Color(0xFF16A34A),
            title: 'Announcements',
            subtitle: 'All company announcements',
            route: Routes.announcements,
            badgeBuilder: (c) => Obx(
              () => c.unreadAnnouncements.value > 0
                  ? _Badge(
                      label: '${c.unreadAnnouncements.value} new',
                      bg: const Color(0xFFFAECE7),
                      text: const Color(0xFF993C1D),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          _MenuItem(
            icon: Icons.account_tree_rounded,
            iconBg: _violetBg(isDark),
            iconColor: const Color(0xFF7F77DD),
            title: 'Organisation',
            subtitle: 'Team structure and contacts',
            route: Routes.organisation,
          ),
          _MenuItem(
            icon: Icons.menu_book_rounded,
            iconBg: _blueBg(isDark),
            iconColor: const Color(0xFF185FA5),
            title: 'Company Policy',
            subtitle: 'HR policies and handbook',
            route: Routes.companyPolicy,
          ),
          _MenuItem(
            icon: Icons.support_agent_rounded,
            iconBg: _blueBg(isDark),
            iconColor: const Color(0xFF185FA5),
            title: 'Help / HR Support',
            subtitle: 'FAQ, rules and report issue',
            route: Routes.helpSupport,
          ),
        ],
      ),
    ];
  }

  Color _blueBg(bool isDark) =>
      isDark ? const Color(0xFF1A3556) : const Color(0xFFE6F1FB);
  Color _greenBg(bool isDark) =>
      isDark ? const Color(0xFF0D2A1A) : const Color(0xFFEAF3DE);
  Color _amberBg(bool isDark) =>
      isDark ? const Color(0xFF2A1F0A) : const Color(0xFFFAEEDA);
  Color _violetBg(bool isDark) =>
      isDark ? const Color(0xFF1E1A3A) : const Color(0xFFEEEDFE);
  Color _redBg(bool isDark) =>
      isDark ? const Color(0xFF2A0D0D) : const Color(0xFFFAECE7);
}

class _MenuSection {
  final String title;
  final String category;
  final List<_MenuItem> items;

  const _MenuSection({
    required this.title,
    required this.category,
    required this.items,
  });
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isDark;
  const _SectionLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.10,
        ),
      ),
    );
  }
}

class _MenuGroup extends StatelessWidget {
  final bool isDark;
  final List<_MenuItem> items;
  const _MenuGroup({required this.isDark, required this.items});

  @override
  Widget build(BuildContext context) {
    final resolved = [
      for (var i = 0; i < items.length; i++)
        items[i].copyWith(isLast: i == items.length - 1),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: resolved.map((item) => item.build(context, isDark)).toList(),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String route;
  final Widget Function(OtherController c)? badgeBuilder;
  final bool isLast;

  const _MenuItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.route,
    this.badgeBuilder,
    this.isLast = false,
  });

  _MenuItem copyWith({bool? isLast}) {
    return _MenuItem(
      icon: icon,
      iconBg: iconBg,
      iconColor: iconColor,
      title: title,
      subtitle: subtitle,
      route: route,
      badgeBuilder: badgeBuilder,
      isLast: isLast ?? this.isLast,
    );
  }

  Widget build(BuildContext context, bool isDark) {
    return _MenuRow(item: this, isDark: isDark);
  }
}

class _MenuRow extends GetView<OtherController> {
  final _MenuItem item;
  final bool isDark;
  const _MenuRow({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () => Get.toNamed(item.route),
          borderRadius: item.isLast
              ? const BorderRadius.vertical(bottom: Radius.circular(8))
              : BorderRadius.zero,
          splashColor: const Color(0xFF185FA5).withValues(alpha: 0.06),
          highlightColor: const Color(0xFF185FA5).withValues(alpha: 0.03),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: item.iconBg,
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
                          color: isDark
                              ? const Color(0xFFE2E8F0)
                              : const Color(0xFF1E293B),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle,
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                if (item.badgeBuilder != null) ...[
                  item.badgeBuilder!(controller),
                  const SizedBox(width: 6),
                ],
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
        if (!item.isLast)
          Divider(
            height: 1,
            indent: 62,
            endIndent: 14,
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : const Color(0xFFF1F5F9),
          ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color bg;
  final Color text;
  const _Badge({required this.label, required this.bg, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: text,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
      child: Text(
        'No pages match your search',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
