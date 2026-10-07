import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/help_support_controller/help_support_controller.dart';
import 'package:staff_attendance/widgets/app_page_widgets.dart';

class HelpSupportScreen extends GetView<HelpSupportController> {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Row(
              children: [
                const AppBackButton(),
                const SizedBox(width: 10),
                Text(
                  'Help / HR Support',
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _ContactCard(isDark: isDark),
            const SizedBox(height: 14),
            _ShortcutGrid(isDark: isDark),
            const SizedBox(height: 14),
            Text(
              'FAQ',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            ...controller.faqs.map(
              (item) => _FaqTile(
                title: item['title']!,
                body: item['body']!,
                isDark: isDark,
              ),
            ),
            const SizedBox(height: 14),
            _ReportIssue(isDark: isDark),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final bool isDark;
  const _ContactCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _helpCardDecoration(isDark),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF185FA5).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: Color(0xFF185FA5),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HR Support Desk',
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'hr@clokk.app · +60 3-5555 0101',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShortcutGrid extends GetView<HelpSupportController> {
  final bool isDark;
  const _ShortcutGrid({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        Icons.fact_check_rounded,
        'Attendance rules',
        controller.openAttendanceRules,
      ),
      (Icons.receipt_long_rounded, 'Claim rules', controller.openClaimRules),
      (Icons.menu_book_rounded, 'Leave policy', controller.openLeavePolicy),
    ];
    return Row(
      children: items.map((item) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: item.$3,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: _helpCardDecoration(isDark),
                child: Column(
                  children: [
                    Icon(item.$1, color: const Color(0xFF185FA5)),
                    const SizedBox(height: 8),
                    Text(
                      item.$2,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final String title;
  final String body;
  final bool isDark;
  const _FaqTile({
    required this.title,
    required this.body,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: _helpCardDecoration(isDark),
      child: ExpansionTile(
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        children: [
          Text(
            body,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _ReportIssue extends GetView<HelpSupportController> {
  final bool isDark;
  const _ReportIssue({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _helpCardDecoration(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Report issue',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller.issueController,
            minLines: 3,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Describe the attendance or app issue',
              filled: true,
              fillColor: isDark
                  ? const Color(0xFF111827)
                  : const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Obx(
            () => SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: controller.isSubmitting.value
                    ? null
                    : controller.reportIssue,
                icon: const Icon(Icons.send_rounded),
                label: const Text('Send to HR'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF185FA5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _helpCardDecoration(bool isDark) => BoxDecoration(
  color: isDark ? const Color(0xFF1E293B) : Colors.white,
  borderRadius: BorderRadius.circular(8),
  border: Border.all(
    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
  ),
);
