import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/approval_inbox_controller/approval_inbox_controller.dart';
import 'package:staff_attendance/apps/routes/routes.dart';
import 'package:staff_attendance/widgets/app_page_widgets.dart';

class ApprovalInboxScreen extends GetView<ApprovalInboxController> {
  final bool showBackButton;
  const ApprovalInboxScreen({super.key, this.showBackButton = true});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ApprovalInboxController>()) {
      Get.put(ApprovalInboxController());
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: AppPageHeader(
                title: 'Approval Inbox',
                showBackButton: showBackButton,
              ),
            ),
            _BulkBar(isDark: isDark),
            const _ApprovalFilters(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                final items = controller.filtered;
                if (items.isEmpty) {
                  return const Center(child: Text('No pending approvals'));
                }
                return NotificationListener<ScrollUpdateNotification>(
                  onNotification: (notification) {
                    if ((notification.scrollDelta ?? 0) > 4) {
                      controller.collapseFilters();
                    }
                    return false;
                  },
                  child: RefreshIndicator(
                    onRefresh: controller.fetchApprovals,
                    color: const Color(0xFF185FA5),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: items.length,
                      itemBuilder: (_, index) =>
                          _ApprovalCard(item: items[index], isDark: isDark),
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

class _BulkBar extends GetView<ApprovalInboxController> {
  final bool isDark;
  const _BulkBar({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final count = controller.selectedIds.length;
      if (count == 0) return const SizedBox.shrink();
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF185FA5).withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '$count selected',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            TextButton(
              onPressed: controller.clearSelection,
              child: const Text('Clear'),
            ),
            FilledButton(
              onPressed: controller.bulkApprove,
              child: const Text('Approve all'),
            ),
          ],
        ),
      );
    });
  }
}

class _ApprovalFilters extends GetView<ApprovalInboxController> {
  const _ApprovalFilters();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    return AppCard(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      child: Obx(() {
        final expanded = controller.filtersExpanded.value;
        final activeCount = controller.activeFilterCount;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: controller.toggleFilters,
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF185FA5).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        color: Color(0xFF185FA5),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activeCount == 0
                                ? 'Filters'
                                : 'Filters · $activeCount changed',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (!expanded) ...[
                            const SizedBox(height: 2),
                            Text(
                              controller.filterSummary,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: muted,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Text(
                      '${controller.filtered.length} shown',
                      style: TextStyle(
                        color: muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (expanded)
                      TextButton(
                        onPressed: controller.resetFilters,
                        child: const Text('Reset'),
                      ),
                    AnimatedRotation(
                      turns: expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 180),
                      child: const Icon(Icons.keyboard_arrow_down_rounded),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  _FilterGroup(
                    label: 'Type',
                    values: controller.types,
                    selected: controller.selectedType,
                    onChanged: controller.setType,
                  ),
                  _FilterGroup(
                    label: 'Status',
                    values: controller.statuses,
                    selected: controller.selectedStatus,
                    onChanged: controller.setStatus,
                  ),
                  _FilterGroup(
                    label: 'Date',
                    values: controller.dates,
                    selected: controller.selectedDate,
                    onChanged: controller.setDate,
                  ),
                ],
              ),
              secondChild: const SizedBox(width: double.infinity),
              crossFadeState: expanded
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 180),
              firstCurve: Curves.easeOutCubic,
              secondCurve: Curves.easeOutCubic,
              sizeCurve: Curves.easeOutCubic,
            ),
          ],
        );
      }),
    );
  }
}

class _FilterGroup extends StatelessWidget {
  final String label;
  final List<String> values;
  final RxString selected;
  final ValueChanged<String> onChanged;

  const _FilterGroup({
    required this.label,
    required this.values,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark
        ? const Color(0xFFCBD5E1)
        : const Color(0xFF475569);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: labelColor,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
          Obx(
            () => AppChoiceChips(
              values: values,
              selected: selected.value,
              onChanged: onChanged,
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}

class _ApprovalCard extends GetView<ApprovalInboxController> {
  final Map<String, dynamic> item;
  final bool isDark;
  const _ApprovalCard({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = _typeColor('${item['type']}');
    final statusColor = _statusColor('${item['status']}');
    final id = '${item['id']}';
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: Row(
              children: [
                Obx(
                  () => Transform.scale(
                    scale: 0.9,
                    child: Checkbox(
                      value: controller.selectedIds.contains(id),
                      visualDensity: VisualDensity.compact,
                      onChanged: (_) => controller.toggleSelection(id),
                    ),
                  ),
                ),
                AppStatusBadge(label: '${item['type']}', color: color),
                const SizedBox(width: 8),
                _SoftStatusPill(label: '${item['status']}', color: statusColor),
                const Spacer(),
                Icon(
                  Icons.schedule_rounded,
                  size: 14,
                  color: isDark
                      ? const Color(0xFF64748B)
                      : const Color(0xFF94A3B8),
                ),
                const SizedBox(width: 4),
                Text(
                  '${item['submitted']}',
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => _showDetail(context),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item['title']}',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${item['subtitle']}',
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.open_in_new_rounded, size: 14, color: color),
                      const SizedBox(width: 4),
                      Text(
                        'Tap to view details and audit history',
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF0F172A).withValues(alpha: 0.44)
                  : const Color(0xFFF8FAFC),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(8),
              ),
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFE2E8F0),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _DecisionButton(
                    label: 'Reject',
                    icon: Icons.close_rounded,
                    color: const Color(0xFFDC2626),
                    filled: false,
                    onPressed: () => _showRejectDialog(context),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DecisionButton(
                    label: 'Approve',
                    icon: Icons.check_rounded,
                    color: const Color(0xFF16A34A),
                    filled: true,
                    onPressed: () =>
                        controller.decide('${item['id']}', 'Approved'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDetail(BuildContext context) {
    Get.toNamed(Routes.approvalDetail, arguments: item);
  }

  void _showRejectDialog(BuildContext context) {
    final remarks = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text('Reject request'),
        content: TextField(
          controller: remarks,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Add rejection remarks for audit history',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Get.back();
              controller.decide(
                '${item['id']}',
                'Rejected',
                remarks: remarks.text.trim(),
              );
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'Claim':
        return const Color(0xFF16A34A);
      case 'Correction':
        return const Color(0xFFF59E0B);
      case 'Document':
        return const Color(0xFF7F77DD);
      case 'Overtime':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF185FA5);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Approved':
        return const Color(0xFF16A34A);
      case 'Rejected':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFFF59E0B);
    }
  }
}

class _SoftStatusPill extends StatelessWidget {
  final String label;
  final Color color;
  const _SoftStatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _DecisionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool filled;
  final VoidCallback onPressed;

  const _DecisionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.filled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );
    if (filled) {
      return FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 17),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(42),
          shape: shape,
        ),
      );
    }
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 17),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        minimumSize: const Size.fromHeight(42),
        side: BorderSide(color: color.withValues(alpha: 0.42)),
        shape: shape,
      ),
    );
  }
}
