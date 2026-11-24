import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:staff_attendance/apps/controllers/overtime_controller/overtime_controller.dart';
import 'package:staff_attendance/apps/models/overtime_model.dart';
import 'package:staff_attendance/apps/routes/routes.dart';
import 'package:staff_attendance/widgets/app_page_widgets.dart';

class OvertimeScreen extends GetView<OvertimeController> {
  const OvertimeScreen({super.key});

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
                      'overtime_label'.tr,
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
                  color: const Color(0xFFD97706),
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
                            (_, i) => _OvertimeCard(
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
        onPressed: () => Get.toNamed(Routes.applyOvertime),
        backgroundColor: const Color(0xFFD97706),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'apply_ot'.tr,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// ── Summary Row ───────────────────────────────────────────────────────────────
class _SummaryRow extends GetView<OvertimeController> {
  final bool isDark;
  const _SummaryRow({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final statuses = [
        (OvertimeStatus.pending, 'pending', 0xFFF59E0B),
        (OvertimeStatus.approved, 'approved', 0xFF16A34A),
        (OvertimeStatus.rejected, 'rejected', 0xFFDC2626),
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

// ── Status + Type filters ────────────────────────────────────────────────────
class _StatusFilters extends GetView<OvertimeController> {
  final bool isDark;
  const _StatusFilters({required this.isDark});

  static const _statuses = [
    (OvertimeStatus.pending, 'pending', 0xFFF59E0B),
    (OvertimeStatus.approved, 'approved', 0xFF16A34A),
    (OvertimeStatus.rejected, 'rejected', 0xFFDC2626),
  ];

  static const _types = [
    (OvertimeType.weekday, 'ot_weekday', 0xFFD97706),
    (OvertimeType.weekend, 'ot_weekend', 0xFF185FA5),
    (OvertimeType.publicHoliday, 'ot_public_holiday', 0xFF7F77DD),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selStatus = controller.selectedStatus.value;
      final selType = controller.selectedType.value;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Row(
          children: [
            ..._statuses.map((s) {
              final active = selStatus == s.$1;
              final color = Color(s.$3);
              return _FilterChip(
                label: s.$2.tr,
                active: active,
                color: color,
                isDark: isDark,
                onTap: () => controller.setStatusFilter(s.$1),
              );
            }),
            const SizedBox(width: 8),
            ..._types.map((t) {
              final active = selType == t.$1;
              final color = Color(t.$3);
              return _FilterChip(
                label: t.$2.tr,
                active: active,
                color: color,
                isDark: isDark,
                onTap: () => controller.setTypeFilter(t.$1),
              );
            }),
          ],
        ),
      );
    });
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;
  const _FilterChip({
    required this.label,
    required this.active,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
          label,
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
  }
}

// ── Overtime Card ─────────────────────────────────────────────────────────────
class _OvertimeCard extends StatelessWidget {
  final OvertimeModel item;
  final bool isDark;
  const _OvertimeCard({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final typeColor = Color(item.typeColor);
    final statusColor = Color(item.statusColor);

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
                color: typeColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    DateFormat('d').format(item.date),
                    style: TextStyle(
                      color: typeColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    DateFormat('MMM').format(item.date),
                    style: TextStyle(
                      color: typeColor,
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
                      _TypeBadge(label: item.typeLabel.tr, color: typeColor),
                      const SizedBox(width: 6),
                      _StatusBadge(label: item.statusLabel.tr, color: statusColor),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${item.startTime} → ${item.endTime}  ·  ${item.hours.toStringAsFixed(1)} hrs',
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
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 12,
                    ),
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
    final typeColor = Color(item.typeColor);
    final statusColor = Color(item.statusColor);

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
                _TypeBadge(label: item.typeLabel.tr, color: typeColor),
                const SizedBox(width: 8),
                _StatusBadge(label: item.statusLabel.tr, color: statusColor),
              ],
            ),
            const SizedBox(height: 16),
            _DetailRow(
              isDark: isDark,
              label: 'date'.tr,
              value: DateFormat('d MMM yyyy (EEEE)').format(item.date),
            ),
            _DetailRow(
              isDark: isDark,
              label: 'time_range'.tr,
              value: '${item.startTime} → ${item.endTime}',
            ),
            _DetailRow(
              isDark: isDark,
              label: 'hours'.tr,
              value: '${item.hours.toStringAsFixed(1)} hrs',
            ),
            _DetailRow(isDark: isDark, label: 'reason'.tr, value: item.reason),
            if (item.approvedBy != null)
              _DetailRow(
                isDark: isDark,
                label: 'approved_by'.tr,
                value: item.approvedBy!,
              ),
            if (item.rejectionNote != null)
              _DetailRow(
                isDark: isDark,
                label: 'rejection_note'.tr,
                value: item.rejectionNote!,
                valueColor: const Color(0xFFDC2626),
              ),
            _DetailRow(
              isDark: isDark,
              label: 'submitted'.tr,
              value: DateFormat('d MMM yyyy, HH:mm').format(item.submittedAt),
            ),
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

class _TypeBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _TypeBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final bool isDark;
  final String label;
  final String value;
  final Color? valueColor;
  const _DetailRow({
    required this.isDark,
    required this.label,
    required this.value,
    this.valueColor,
  });

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
                color: valueColor ??
                    (isDark ? Colors.white : const Color(0xFF0F172A)),
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
            Icons.more_time_rounded,
            size: 48,
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
          const SizedBox(height: 12),
          Text(
            'no_ot_requests'.tr,
            style: TextStyle(
              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'no_ot_hint'.tr,
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
