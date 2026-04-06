import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/other_controller/other_controller.dart';
import 'package:staff_attendance/apps/routes/routes.dart';
import '../../../widgets/responsive_page.dart';

// ── Binding ──────────────────────────────────────────────────────────────────
class OtherBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut<OtherController>(() => OtherController());
}

// ── Screen ───────────────────────────────────────────────────────────────────
class OtherScreen extends GetView<OtherController> {
  const OtherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<OtherController>()) {
      Get.put(OtherController());
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

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
                // ── Header ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                  child: Text(
                    'More',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                    ),
                  ),
                ),

                // ── Section 1: Time & Schedule ──
                _SectionLabel(label: 'Time & Schedule', isDark: isDark),
                _MenuGroup(
                  isDark: isDark,
                  items: [
                    _MenuItem(
                      icon: Icons.calendar_month_rounded,
                      iconBg: isDark
                          ? const Color(0xFF1A3556)
                          : const Color(0xFFE6F1FB),
                      iconColor: const Color(0xFF378ADD),
                      title: 'Calendar',
                      subtitle: 'Leave, events & public holidays',
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
                    _MenuItem(
                      icon: Icons.schedule_rounded,
                      iconBg: isDark
                          ? const Color(0xFF0D2A1A)
                          : const Color(0xFFEAF3DE),
                      iconColor: const Color(0xFF4ADE80),
                      title: 'Time Off',
                      subtitle: 'View approved & pending leave',
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
                      iconBg: isDark
                          ? const Color(0xFF1A3556)
                          : const Color(0xFFE6F1FB),
                      iconColor: const Color(0xFF185FA5),
                      title: 'Apply Leave',
                      subtitle: 'Annual, emergency, unpaid',
                      route: Routes.applyLeave,
                    ),
                    _MenuItem(
                      icon: Icons.more_time_rounded,
                      iconBg: isDark
                          ? const Color(0xFF2A1F0A)
                          : const Color(0xFFFAEEDA),
                      iconColor: const Color(0xFFFBBF24),
                      title: 'Apply Overtime',
                      subtitle: 'Request OT approval',
                      route: Routes.applyOvertime,
                      isLast: true,
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // ── Section 2: Claims & Documents ──
                _SectionLabel(label: 'Claims & Documents', isDark: isDark),
                _MenuGroup(
                  isDark: isDark,
                  items: [
                    _MenuItem(
                      icon: Icons.receipt_long_rounded,
                      iconBg: isDark
                          ? const Color(0xFF0D2A1A)
                          : const Color(0xFFEAF3DE),
                      iconColor: const Color(0xFF4ADE80),
                      title: 'Submit Claim',
                      subtitle: 'Medical, transport, others',
                      route: Routes.submitClaim,
                    ),
                    _MenuItem(
                      icon: Icons.folder_rounded,
                      iconBg: isDark
                          ? const Color(0xFF2A0D0D)
                          : const Color(0xFFFAECE7),
                      iconColor: const Color(0xFFF87171),
                      title: 'My Documents',
                      subtitle: 'MC, certs, uploaded files',
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
                      icon: Icons.download_rounded,
                      iconBg: isDark
                          ? const Color(0xFF1A3556)
                          : const Color(0xFFE6F1FB),
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
                      isLast: true,
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // ── Section 3: Company ──
                _SectionLabel(label: 'Company', isDark: isDark),
                _MenuGroup(
                  isDark: isDark,
                  items: [
                    _MenuItem(
                      icon: Icons.account_tree_rounded,
                      iconBg: isDark
                          ? const Color(0xFF1E1A3A)
                          : const Color(0xFFEEEDFE),
                      iconColor: const Color(0xFF7F77DD),
                      title: 'Organisation',
                      subtitle: 'Team structure & contacts',
                      route: Routes.organisation,
                    ),
                    _MenuItem(
                      icon: Icons.menu_book_rounded,
                      iconBg: isDark
                          ? const Color(0xFF1A3556)
                          : const Color(0xFFE6F1FB),
                      iconColor: const Color(0xFF185FA5),
                      title: 'Company Policy',
                      subtitle: 'HR policies & handbook',
                      route: Routes.companyPolicy,
                    ),
                    _MenuItem(
                      icon: Icons.campaign_rounded,
                      iconBg: isDark
                          ? const Color(0xFF0D2A1A)
                          : const Color(0xFFEAF3DE),
                      iconColor: const Color(0xFF4ADE80),
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
                      isLast: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────
// SECTION LABEL
// ─────────────────────────────────────
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
          color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.10,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────
// MENU GROUP (card container)
// ─────────────────────────────────────
class _MenuGroup extends StatelessWidget {
  final bool isDark;
  final List<_MenuItem> items;
  const _MenuGroup({required this.isDark, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? null : Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: items.map((item) => item.build(context, isDark)).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────
// MENU ITEM MODEL
// ─────────────────────────────────────
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

  Widget build(BuildContext context, bool isDark) {
    return _MenuRow(item: this, isDark: isDark);
  }
}

// ─────────────────────────────────────
// MENU ROW WIDGET
// ─────────────────────────────────────
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
              ? const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                )
              : BorderRadius.zero,
          splashColor: const Color(0xFF185FA5).withOpacity(0.06),
          highlightColor: const Color(0xFF185FA5).withOpacity(0.03),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: item.iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon, color: item.iconColor, size: 18),
                ),
                const SizedBox(width: 12),

                // Title + subtitle
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
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle,
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFF475569)
                              : const Color(0xFF94A3B8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                // Badge (reactive)
                if (item.badgeBuilder != null) ...[
                  item.badgeBuilder!(controller),
                  const SizedBox(width: 6),
                ],

                // Chevron
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFCBD5E1),
                ),
              ],
            ),
          ),
        ),

        // Divider (skip for last item)
        if (!item.isLast)
          Divider(
            height: 1,
            indent: 14 + 36 + 12, // align with text
            endIndent: 14,
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : const Color(0xFFF1F5F9),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────
// BADGE WIDGET
// ─────────────────────────────────────
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
