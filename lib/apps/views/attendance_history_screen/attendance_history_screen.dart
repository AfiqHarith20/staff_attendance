import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/attendance_history_controller/attendance_history_controller.dart';
import 'package:staff_attendance/apps/models/attendance_history_model.dart';
import 'package:staff_attendance/apps/routes/routes.dart';
import 'package:staff_attendance/widgets/app_page_widgets.dart';

class AttendanceHistoryScreen extends GetView<AttendanceHistoryController> {
  const AttendanceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _Header(isDark: isDark),
            _Summary(isDark: isDark),
            _StatusFilters(isDark: isDark),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                final records = controller.filtered;
                if (records.isEmpty) {
                  return _EmptyState(isDark: isDark);
                }
                return RefreshIndicator(
                  onRefresh: controller.fetchRecords,
                  color: const Color(0xFF185FA5),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: records.length,
                    itemBuilder: (_, index) =>
                        _RecordCard(item: records[index], isDark: isDark),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(Routes.correctionRequest),
        backgroundColor: const Color(0xFF185FA5),
        icon: const Icon(Icons.edit_calendar_rounded, color: Colors.white),
        label: const Text(
          'Request correction',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _Header extends GetView<AttendanceHistoryController> {
  final bool isDark;
  const _Header({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
      child: Row(
        children: [
          _BackButton(isDark: isDark),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Attendance History',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            onPressed: controller.previousMonth,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Obx(
            () => Text(
              controller.monthLabel(controller.selectedMonth.value),
              style: TextStyle(
                color: isDark
                    ? const Color(0xFFCBD5E1)
                    : const Color(0xFF334155),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            onPressed: controller.nextMonth,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }
}

class _Summary extends GetView<AttendanceHistoryController> {
  final bool isDark;
  const _Summary({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Row(
          children: [
            _SummaryTile(
              label: 'Present',
              value: '${controller.presentDays}',
              color: const Color(0xFF16A34A),
              isDark: isDark,
            ),
            const SizedBox(width: 10),
            _SummaryTile(
              label: 'Issues',
              value: '${controller.issueDays}',
              color: const Color(0xFFF59E0B),
              isDark: isDark,
            ),
            const SizedBox(width: 10),
            _SummaryTile(
              label: 'Hours',
              value: controller.totalHoursLabel,
              color: const Color(0xFF185FA5),
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isDark;
  const _SummaryTile({
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusFilters extends GetView<AttendanceHistoryController> {
  final bool isDark;
  const _StatusFilters({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final options = <AttendanceRecordStatus?>[
      null,
      ...AttendanceRecordStatus.values,
    ];
    return Obx(
      () => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Row(
          children: options.map((status) {
            final active = controller.selectedStatus.value == status;
            final label = status == null
                ? 'All'
                : AttendanceRecordModel(
                    id: '',
                    date: DateTime.now(),
                    checkInAt: null,
                    checkOutAt: null,
                    checkInLocation: '',
                    checkOutLocation: '',
                    distanceM: 0,
                    status: status,
                    isLate: false,
                    isEarlyCheckout: false,
                    workingHoursLabel: '',
                    remarks: '',
                    auditStatus: '',
                  ).statusLabel;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                selected: active,
                label: Text(label),
                onSelected: (_) => controller.setStatus(status),
                selectedColor: const Color(0xFF185FA5),
                labelStyle: TextStyle(
                  color: active
                      ? Colors.white
                      : isDark
                      ? const Color(0xFFCBD5E1)
                      : const Color(0xFF475569),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _RecordCard extends GetView<AttendanceHistoryController> {
  final AttendanceRecordModel item;
  final bool isDark;
  const _RecordCard({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final statusColor = Color(item.statusColorValue);
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.attendanceDetail, arguments: item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.fact_check_rounded,
                color: statusColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.dayLabel(item.date),
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${controller.timeLabel(item.checkInAt)} - ${controller.timeLabel(item.checkOutAt)} · ${item.workingHoursLabel}',
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 12,
                    ),
                  ),
                  if (item.isLate || item.isEarlyCheckout) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      children: [
                        if (item.isLate) _Flag(label: 'Late'),
                        if (item.isEarlyCheckout)
                          _Flag(label: 'Early checkout'),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                item.statusLabel,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Flag extends StatelessWidget {
  final String label;
  const _Flag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFD97706),
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final bool isDark;
  const _BackButton({required this.isDark});

  @override
  Widget build(BuildContext context) => const AppBackButton();
}

class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No attendance records found',
        style: TextStyle(
          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        ),
      ),
    );
  }
}
