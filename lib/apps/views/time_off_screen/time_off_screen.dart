import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:staff_attendance/widgets/app_page_widgets.dart';

import '../../../../apps/controllers/time_off_controller/time_off_controller.dart';
import '../../../../apps/models/leave_model.dart';
import '../../../../apps/routes/routes.dart';

// ── Screen ───────────────────────────────────────────────────────────────────
class TimeOffScreen extends GetView<TimeOffController> {
  const TimeOffScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _AppBar(isDark: isDark),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                return RefreshIndicator(
                  onRefresh: controller.fetchAll,
                  color: const Color(0xFF185FA5),
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: _BalanceSection(isDark: isDark),
                      ),
                      SliverToBoxAdapter(child: _StatusSummary(isDark: isDark)),
                      SliverToBoxAdapter(child: _Filters(isDark: isDark)),
                      SliverToBoxAdapter(child: _ListHeader(isDark: isDark)),
                      _LeaveList(isDark: isDark),
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(Routes.applyLeave),
        backgroundColor: const Color(0xFF185FA5),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Apply Leave',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────
// APP BAR
// ─────────────────────────────────────
class _AppBar extends GetView<TimeOffController> {
  final bool isDark;
  const _AppBar({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          _BackBtn(isDark: isDark),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Time Off',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
              ),
            ),
          ),
          // Year picker
          Obx(
            () => GestureDetector(
              onTap: () => _showYearPicker(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${controller.selectedYear.value}',
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.expand_more_rounded,
                      size: 14,
                      color: isDark
                          ? const Color(0xFF64748B)
                          : const Color(0xFF94A3B8),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showYearPicker(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final years = [
      DateTime.now().year - 1,
      DateTime.now().year,
      DateTime.now().year + 1,
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ...years.map(
              (y) => Material(
                color: Colors.transparent,
                child: ListTile(
                  title: Text(
                    '$y',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: controller.selectedYear.value == y
                      ? const Icon(
                          Icons.check_rounded,
                          color: Color(0xFF185FA5),
                        )
                      : null,
                  onTap: () {
                    controller.setYear(y);
                    Get.back();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────
// BALANCE SECTION
// ─────────────────────────────────────
class _BalanceSection extends GetView<TimeOffController> {
  final bool isDark;
  const _BalanceSection({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final b = controller.balance.value;
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Leave balance',
              style: TextStyle(
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.04,
              ),
            ),
            const SizedBox(height: 14),
            _BalanceBar(
              label: 'Annual',
              used: b.annualUsed,
              total: b.annualTotal,
              color: const Color.fromARGB(255, 82, 149, 216),
              isDark: isDark,
            ),
            const SizedBox(height: 10),
            _BalanceBar(
              label: 'Medical',
              used: b.medicalUsed,
              total: b.medicalTotal,
              color: const Color(0xFFDC2626),
              isDark: isDark,
            ),
            const SizedBox(height: 10),
            _BalanceBar(
              label: 'Emergency',
              used: b.emergencyUsed,
              total: b.emergencyTotal,
              color: const Color(0xFFF59E0B),
              isDark: isDark,
            ),
          ],
        ),
      );
    });
  }
}

class _BalanceBar extends StatelessWidget {
  final String label;
  final int used;
  final int total;
  final Color color;
  final bool isDark;

  const _BalanceBar({
    required this.label,
    required this.used,
    required this.total,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final left = total - used;
    final progress = total == 0 ? 0.0 : used / total;

    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: TextStyle(
              color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 7,
              backgroundColor: isDark
                  ? Colors.white.withOpacity(0.06)
                  : const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 46,
          child: Text(
            '$left/$total',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────
// STATUS SUMMARY CHIPS
// ─────────────────────────────────────
class _StatusSummary extends GetView<TimeOffController> {
  final bool isDark;
  const _StatusSummary({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final statuses = [
        (LeaveStatus.pending, 'Pending', 0xFFF59E0B),
        (LeaveStatus.approved, 'Approved', 0xFF16A34A),
        (LeaveStatus.rejected, 'Rejected', 0xFFDC2626),
        (LeaveStatus.cancelled, 'Cancelled', 0xFF64748B),
      ];
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Row(
          children:
              statuses.map((s) {
                  final count = controller.countByStatus(s.$1);
                  final color = Color(s.$3);
                  final isActive = controller.selectedStatus.value == s.$1;
                  return Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => controller.setStatusFilter(s.$1),
                        borderRadius: BorderRadius.circular(10),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isActive
                                ? color.withOpacity(0.15)
                                : isDark
                                ? const Color(0xFF1E293B)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isActive
                                  ? color
                                  : isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '$count',
                                style: TextStyle(
                                  color: isActive
                                      ? color
                                      : isDark
                                      ? Colors.white
                                      : const Color(0xFF0F172A),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                s.$2,
                                style: TextStyle(
                                  color: isActive
                                      ? color
                                      : isDark
                                      ? const Color(0xFF475569)
                                      : const Color(0xFF94A3B8),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList()
                ..removeLast() // remove trailing margin from last
                ..add(
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () =>
                            controller.setStatusFilter(statuses.last.$1),
                        borderRadius: BorderRadius.circular(10),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color:
                                controller.selectedStatus.value ==
                                    statuses.last.$1
                                ? Color(statuses.last.$3).withOpacity(0.15)
                                : isDark
                                ? const Color(0xFF1E293B)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color:
                                  controller.selectedStatus.value ==
                                      statuses.last.$1
                                  ? Color(statuses.last.$3)
                                  : isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '${controller.countByStatus(statuses.last.$1)}',
                                style: TextStyle(
                                  color:
                                      controller.selectedStatus.value ==
                                          statuses.last.$1
                                      ? Color(statuses.last.$3)
                                      : isDark
                                      ? Colors.white
                                      : const Color(0xFF0F172A),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                statuses.last.$2,
                                style: TextStyle(
                                  color:
                                      controller.selectedStatus.value ==
                                          statuses.last.$1
                                      ? Color(statuses.last.$3)
                                      : isDark
                                      ? const Color(0xFF475569)
                                      : const Color(0xFF94A3B8),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      );
    });
  }
}

// ─────────────────────────────────────
// TYPE FILTER CHIPS
// ─────────────────────────────────────
class _Filters extends GetView<TimeOffController> {
  final bool isDark;
  const _Filters({required this.isDark});

  static const _types = [
    (LeaveType.annual, 'Annual'),
    (LeaveType.medical, 'Medical'),
    (LeaveType.emergency, 'Emergency'),
    (LeaveType.unpaid, 'Unpaid'),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Row(
          children: [
            // All chip
            _TypeChip(
              label: 'All types',
              isActive: controller.selectedType.value == null,
              color: const Color(0xFF185FA5),
              isDark: isDark,
              onTap: () => controller.setTypeFilter(null),
            ),
            ..._types.map(
              (t) => _TypeChip(
                label: t.$2,
                isActive: controller.selectedType.value == t.$1,
                color: Color(LeaveModel.typeColors[t.$1]!),
                isDark: isDark,
                onTap: () => controller.setTypeFilter(t.$1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.isActive,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isActive ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive
                  ? color
                  : isDark
                  ? const Color(0xFF334155)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isActive
                  ? Colors.white
                  : isDark
                  ? const Color(0xFF64748B)
                  : const Color(0xFF94A3B8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────
// LIST HEADER
// ─────────────────────────────────────
class _ListHeader extends GetView<TimeOffController> {
  final bool isDark;
  const _ListHeader({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final count = controller.filtered.length;
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Applications',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '$count result${count == 1 ? '' : 's'}',
              style: TextStyle(
                color: isDark
                    ? const Color(0xFF475569)
                    : const Color(0xFF94A3B8),
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ─────────────────────────────────────
// LEAVE LIST
// ─────────────────────────────────────
class _LeaveList extends GetView<TimeOffController> {
  final bool isDark;
  const _LeaveList({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list = controller.filtered;
      if (list.isEmpty) {
        return SliverToBoxAdapter(child: _EmptyState(isDark: isDark));
      }
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, i) => _LeaveCard(
            leave: list[i],
            isDark: isDark,
            onTap: () => _showDetail(context, list[i]),
          ),
          childCount: list.length,
        ),
      );
    });
  }

  void _showDetail(BuildContext context, LeaveModel leave) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _LeaveDetailSheet(leave: leave, isDark: isDark),
    );
  }
}

// ─────────────────────────────────────
// LEAVE CARD
// ─────────────────────────────────────
class _LeaveCard extends StatelessWidget {
  final LeaveModel leave;
  final bool isDark;
  final VoidCallback onTap;

  const _LeaveCard({
    required this.leave,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final typeColor = Color(leave.typeColor);
    final statusColor = Color(leave.statusColor);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            // Left accent bar
            Container(
              width: 4,
              height: 90,
              decoration: BoxDecoration(
                color: typeColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type + status badge row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: typeColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            leave.typeLabel,
                            style: TextStyle(
                              color: typeColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            leave.statusLabel,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Date range
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 13,
                          color: isDark
                              ? const Color(0xFF475569)
                              : const Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _formatDateRange(leave.startDate, leave.endDate),
                          style: TextStyle(
                            color: isDark
                                ? const Color(0xFFE2E8F0)
                                : const Color(0xFF1E293B),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Days count + applied date
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF0F172A)
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${leave.totalDays} day${leave.totalDays > 1 ? 's' : ''}',
                            style: TextStyle(
                              color: isDark
                                  ? const Color(0xFF64748B)
                                  : const Color(0xFF94A3B8),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Applied ${DateFormat('d MMM').format(leave.appliedAt)}',
                          style: TextStyle(
                            color: isDark
                                ? const Color(0xFF475569)
                                : const Color(0xFF94A3B8),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateRange(DateTime start, DateTime end) {
    if (isSameDay(start, end)) {
      return DateFormat('d MMM yyyy').format(start);
    }
    if (start.year == end.year && start.month == end.month) {
      return '${DateFormat('d').format(start)}–${DateFormat('d MMM yyyy').format(end)}';
    }
    return '${DateFormat('d MMM').format(start)} – ${DateFormat('d MMM yyyy').format(end)}';
  }

  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ─────────────────────────────────────
// DETAIL BOTTOM SHEET
// ─────────────────────────────────────
class _LeaveDetailSheet extends GetView<TimeOffController> {
  final LeaveModel leave;
  final bool isDark;

  const _LeaveDetailSheet({required this.leave, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final typeColor = Color(leave.typeColor);
    final statusColor = Color(leave.statusColor);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Type + status
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  leave.typeLabel,
                  style: TextStyle(
                    color: typeColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  leave.statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Detail rows
          _DetailRow(
            icon: Icons.calendar_today_rounded,
            label: 'Date',
            value: leave.totalDays == 1
                ? DateFormat('EEEE, d MMM yyyy').format(leave.startDate)
                : '${DateFormat('d MMM yyyy').format(leave.startDate)} – '
                      '${DateFormat('d MMM yyyy').format(leave.endDate)}',
            isDark: isDark,
          ),
          _DetailRow(
            icon: Icons.today_rounded,
            label: 'Duration',
            value: '${leave.totalDays} day${leave.totalDays > 1 ? 's' : ''}',
            isDark: isDark,
          ),
          _DetailRow(
            icon: Icons.send_rounded,
            label: 'Applied',
            value: DateFormat('d MMM yyyy, h:mm a').format(leave.appliedAt),
            isDark: isDark,
          ),
          if (leave.approvedBy != null)
            _DetailRow(
              icon: Icons.verified_rounded,
              label: 'Approved by',
              value: leave.approvedBy!,
              isDark: isDark,
            ),
          _DetailRow(
            icon: Icons.notes_rounded,
            label: 'Reason',
            value: leave.reason,
            isDark: isDark,
            multiLine: true,
          ),
          if (leave.rejectionNote != null)
            _DetailRow(
              icon: Icons.info_outline_rounded,
              label: 'Rejection note',
              value: leave.rejectionNote!,
              isDark: isDark,
              valueColor: const Color(0xFFDC2626),
              multiLine: true,
            ),

          // Cancel button — only for pending future leave
          if (leave.canCancel) ...[
            const SizedBox(height: 20),
            Obx(
              () => SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: controller.isCancelling.value
                      ? null
                      : () => _confirmCancel(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFDC2626),
                    side: const BorderSide(color: Color(0xFFDC2626)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: controller.isCancelling.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFDC2626),
                          ),
                        )
                      : const Text(
                          'Cancel Application',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _confirmCancel(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Cancel leave?',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'This will cancel your ${leave.typeLabel} application. This action cannot be undone.',
          style: TextStyle(
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            fontSize: 13,
          ),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text(
              'Keep',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // close dialog
              controller.cancelLeave(leave.id);
            },
            child: const Text(
              'Cancel leave',
              style: TextStyle(
                color: Color(0xFFDC2626),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  final bool multiLine;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
    this.multiLine = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: multiLine
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 16,
            color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: isDark
                    ? const Color(0xFF475569)
                    : const Color(0xFF94A3B8),
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color:
                    valueColor ??
                    (isDark
                        ? const Color(0xFFE2E8F0)
                        : const Color(0xFF1E293B)),
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

// ─────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        children: [
          Icon(
            Icons.beach_access_rounded,
            size: 52,
            color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
          ),
          const SizedBox(height: 14),
          Text(
            'No leave applications',
            style: TextStyle(
              color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap "Apply Leave" below to submit one',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _BackBtn extends StatelessWidget {
  final bool isDark;
  const _BackBtn({required this.isDark});

  @override
  Widget build(BuildContext context) => const AppBackButton();
}
