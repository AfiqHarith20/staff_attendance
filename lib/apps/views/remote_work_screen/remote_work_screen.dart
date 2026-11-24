import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:staff_attendance/apps/controllers/remote_work_controller/remote_work_controller.dart';
import 'package:staff_attendance/apps/models/remote_work_model.dart';
import 'package:staff_attendance/apps/routes/routes.dart';
import 'package:staff_attendance/widgets/app_page_widgets.dart';

class RemoteWorkScreen extends GetView<RemoteWorkController> {
  const RemoteWorkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  const AppBackButton(),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'remote_work'.tr,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                return RefreshIndicator(
                  onRefresh: controller.fetchAll,
                  color: const Color(0xFF7F77DD),
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: _SummaryRow(isDark: isDark),
                      ),
                      SliverToBoxAdapter(
                        child: _StatusFilters(isDark: isDark),
                      ),
                      Obx(() {
                        final list = controller.filtered;
                        if (list.isEmpty) {
                          return SliverFillRemaining(
                            child: _EmptyState(isDark: isDark),
                          );
                        }
                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, i) => _RemoteWorkCard(
                              item: list[i],
                              isDark: isDark,
                            ),
                            childCount: list.length,
                          ),
                        );
                      }),
                      const SliverToBoxAdapter(child: SizedBox(height: 96)),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(Routes.applyRemoteWork),
        backgroundColor: const Color(0xFF7F77DD),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'apply_remote'.tr,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// ── Summary Row ───────────────────────────────────────────────────────────────
class _SummaryRow extends GetView<RemoteWorkController> {
  final bool isDark;
  const _SummaryRow({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final statuses = [
        (RemoteWorkStatus.pending, 'pending', 0xFFF59E0B),
        (RemoteWorkStatus.approved, 'approved', 0xFF16A34A),
        (RemoteWorkStatus.rejected, 'rejected', 0xFFDC2626),
      ];
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Row(
          children: statuses.map((s) {
            final count = controller.countByStatus(s.$1);
            final color = Color(s.$3);
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '$count',
                      style: TextStyle(
                        color: color,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      s.$2.tr,
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFF64748B)
                            : const Color(0xFF94A3B8),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }
}

// ── Status filters ────────────────────────────────────────────────────────────
class _StatusFilters extends GetView<RemoteWorkController> {
  final bool isDark;
  const _StatusFilters({required this.isDark});

  static const _statuses = [
    (RemoteWorkStatus.pending, 'pending', 0xFFF59E0B),
    (RemoteWorkStatus.approved, 'approved', 0xFF16A34A),
    (RemoteWorkStatus.rejected, 'rejected', 0xFFDC2626),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final sel = controller.selectedStatus.value;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Row(
          children: _statuses.map((s) {
            final active = sel == s.$1;
            final color = Color(s.$3);
            return GestureDetector(
              onTap: () => controller.setStatusFilter(s.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: active ? color.withValues(alpha: 0.12) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: active
                        ? color
                        : isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Text(
                  s.$2.tr,
                  style: TextStyle(
                    color: active
                        ? color
                        : isDark
                        ? const Color(0xFF64748B)
                        : const Color(0xFF94A3B8),
                    fontSize: 12,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }
}

// ── Remote Work Card ──────────────────────────────────────────────────────────
class _RemoteWorkCard extends StatelessWidget {
  final RemoteWorkModel item;
  final bool isDark;
  const _RemoteWorkCard({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final statusColor = Color(item.statusColor);
    const violet = Color(0xFF7F77DD);

    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: violet.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    DateFormat('d').format(item.startDate),
                    style: const TextStyle(
                      color: violet,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    DateFormat('MMM').format(item.startDate),
                    style: const TextStyle(
                      color: violet,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: violet.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.location,
                          style: const TextStyle(
                            color: violet,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          item.statusLabel.tr,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.startDate == item.endDate
                        ? DateFormat('d MMM yyyy').format(item.startDate)
                        : '${DateFormat('d MMM').format(item.startDate)} → ${DateFormat('d MMM yyyy').format(item.endDate)}  ·  ${item.totalDays} days',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.reason,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 18),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = Color(item.statusColor);
    const violet = Color(0xFF7F77DD);

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: violet.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.location,
                    style: const TextStyle(
                      color: violet,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    item.statusLabel.tr,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _Row(isDark: isDark, label: 'start_date'.tr, value: DateFormat('d MMM yyyy').format(item.startDate)),
            _Row(isDark: isDark, label: 'end_date'.tr, value: DateFormat('d MMM yyyy').format(item.endDate)),
            _Row(isDark: isDark, label: 'duration'.tr, value: '${item.totalDays} day(s)'),
            _Row(isDark: isDark, label: 'work_location'.tr, value: item.location),
            _Row(isDark: isDark, label: 'reason'.tr, value: item.reason),
            if (item.approvedBy != null)
              _Row(isDark: isDark, label: 'approved_by'.tr, value: item.approvedBy!),
            if (item.rejectionNote != null)
              _Row(
                isDark: isDark,
                label: 'rejection_note'.tr,
                value: item.rejectionNote!,
                valueColor: const Color(0xFFDC2626),
              ),
            _Row(isDark: isDark, label: 'submitted'.tr, value: DateFormat('d MMM yyyy, HH:mm').format(item.submittedAt)),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Get.back(),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text('close'.tr),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final bool isDark;
  final String label;
  final String value;
  final Color? valueColor;
  const _Row({required this.isDark, required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? (isDark ? Colors.white : const Color(0xFF0F172A)),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.home_work_rounded,
            size: 48,
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
          const SizedBox(height: 12),
          Text(
            'no_remote_requests'.tr,
            style: TextStyle(
              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'no_remote_hint'.tr,
            style: TextStyle(
              color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
