import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staff_attendance/apps/models/attendance_history_model.dart';
import 'package:staff_attendance/apps/routes/routes.dart';
import 'package:staff_attendance/widgets/app_page_widgets.dart';

class AttendanceDetailScreen extends StatelessWidget {
  const AttendanceDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final item = Get.arguments as AttendanceRecordModel?;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

    if (item == null) {
      return Scaffold(
        backgroundColor: bg,
        appBar: AppBar(title: const Text('Attendance Detail')),
        body: const Center(child: Text('Record not found')),
      );
    }

    final statusColor = Color(item.statusColorValue);
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
                Expanded(
                  child: Text(
                    'Attendance Detail',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => Get.toNamed(Routes.correctionRequest),
                  icon: const Icon(Icons.edit_calendar_rounded, size: 18),
                  label: const Text('Correct'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${item.date.day}/${item.date.month}/${item.date.year}',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          item.statusLabel,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _DetailRow(
                    label: 'Check-in',
                    value: _time(item.checkInAt),
                    isDark: isDark,
                  ),
                  _DetailRow(
                    label: 'Check-out',
                    value: _time(item.checkOutAt),
                    isDark: isDark,
                  ),
                  _DetailRow(
                    label: 'Working hours',
                    value: item.workingHoursLabel,
                    isDark: isDark,
                  ),
                  _DetailRow(
                    label: 'Check-in location',
                    value: item.checkInLocation,
                    isDark: isDark,
                  ),
                  _DetailRow(
                    label: 'Check-out location',
                    value: item.checkOutLocation,
                    isDark: isDark,
                  ),
                  _DetailRow(
                    label: 'Distance from office',
                    value: '${item.distanceM.toStringAsFixed(0)}m',
                    isDark: isDark,
                  ),
                  _DetailRow(
                    label: 'Audit status',
                    value: item.auditStatus,
                    isDark: isDark,
                  ),
                  if (item.remarks.isNotEmpty)
                    _DetailRow(
                      label: 'Remarks',
                      value: item.remarks,
                      isDark: isDark,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on_rounded, color: statusColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'GPS and audit information are retained for HR verification.',
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFFCBD5E1)
                            : const Color(0xFF475569),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _time(DateTime? value) {
    if (value == null) return '--:--';
    final hour = value.hour > 12 ? value.hour - 12 : value.hour;
    final suffix = value.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${value.minute.toString().padLeft(2, '0')} $suffix';
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  const _DetailRow({
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
