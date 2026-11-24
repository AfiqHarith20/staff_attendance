import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../controllers/scan_controller/scan_controller.dart';
import '../../../models/attendance_history_model.dart';
import '../../../routes/routes.dart';
import '../../../../widgets/responsive_page.dart';

class MyAttendanceScreen extends GetView<ScanController> {
  const MyAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ScanController>()) Get.put(ScanController());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: ResponsivePage(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(isDark: isDark),
                const SizedBox(height: 16),
                _TodaySummaryCard(isDark: isDark),
                const SizedBox(height: 12),
                _AttendanceActions(isDark: isDark),
                const SizedBox(height: 16),
                _DocumentShortcutCard(isDark: isDark),
                const SizedBox(height: 24),
                _WeeklyLog(isDark: isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final bool isDark;
  const _Header({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Attendance',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          DateFormat('EEEE, d MMM yyyy').format(DateTime.now()),
          style: TextStyle(
            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

// ── Today's summary card ──────────────────────────────────────────────────────
class _TodaySummaryCard extends GetView<ScanController> {
  final bool isDark;
  const _TodaySummaryCard({required this.isDark});

  static const _blue = Color(0xFF185FA5);

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final muted =
        isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
    final primary =
        isDark ? Colors.white : const Color(0xFF0F172A);
    final timeFmt = DateFormat('h:mm a');

    return Obx(() {
      final logs = controller.todayLogs;
      final checkInLog =
          logs.where((l) => l.type == 'checkin').lastOrNull;
      final checkOutLog =
          logs.where((l) => l.type == 'checkout').lastOrNull;
      final checkedIn = controller.checkedInToday.value;
      final isLoading = controller.isLoadingLogs.value;

      // Derive status label + colour
      final (Color statusColor, String statusLabel) = switch (true) {
        _ when isLoading => (muted, 'Loading…'),
        _ when checkInLog == null => (muted, 'Not checked in'),
        _ when checkOutLog != null => (
            const Color(0xFF16A34A),
            'Completed',
          ),
        _ when checkedIn => (
            const Color(0xFF185FA5),
            'In progress',
          ),
        _ => (muted, 'No record'),
      };

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row + status badge
            Row(
              children: [
                Text(
                  "Today's Attendance",
                  style: TextStyle(
                    color: primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // IN / OUT / HRS row
            if (isLoading)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _blue,
                    ),
                  ),
                ),
              )
            else
              Row(
                children: [
                  _SummaryCell(
                    label: 'CHECK IN',
                    value: checkInLog != null
                        ? timeFmt.format(checkInLog.time)
                        : '—',
                    valueColor: checkInLog != null
                        ? const Color(0xFF16A34A)
                        : muted,
                    isDark: isDark,
                  ),
                  _SummaryDivider(isDark: isDark),
                  _SummaryCell(
                    label: 'CHECK OUT',
                    value: checkOutLog != null
                        ? timeFmt.format(checkOutLog.time)
                        : '—',
                    valueColor: checkOutLog != null
                        ? const Color(0xFFDC2626)
                        : muted,
                    isDark: isDark,
                  ),
                  _SummaryDivider(isDark: isDark),
                  _SummaryCell(
                    label: 'LOCATION',
                    value: checkInLog != null
                        ? (checkInLog.inRange ? 'In range' : 'Out of range')
                        : '—',
                    valueColor: checkInLog != null
                        ? (checkInLog.inRange
                            ? const Color(0xFF16A34A)
                            : const Color(0xFFF59E0B))
                        : muted,
                    isDark: isDark,
                  ),
                ],
              ),
            // Location name hint
            if (checkInLog != null &&
                controller.locationName.value != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.location_on_rounded, size: 12, color: muted),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      controller.locationName.value!,
                      style: TextStyle(fontSize: 11, color: muted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
    });
  }
}

class _SummaryCell extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final bool isDark;

  const _SummaryCell({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final muted =
        isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: muted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryDivider extends StatelessWidget {
  final bool isDark;
  const _SummaryDivider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
    );
  }
}

// ── History + Correct action buttons ─────────────────────────────────────────
class _AttendanceActions extends StatelessWidget {
  final bool isDark;
  const _AttendanceActions({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final borderColor =
        isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Row(
      children: [
        Expanded(
          child: _ActionChip(
            icon: Icons.history_rounded,
            label: 'History',
            color: const Color(0xFF185FA5),
            borderColor: borderColor,
            onTap: () => Get.toNamed(Routes.attendanceHistory),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionChip(
            icon: Icons.edit_calendar_rounded,
            label: 'Correct',
            color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
            borderColor: borderColor,
            onTap: () => Get.toNamed(Routes.correctionRequest),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionChip(
            icon: Icons.access_time_rounded,
            label: 'Work Hrs',
            color: isDark ? const Color(0xFF818CF8) : const Color(0xFF4F46E5),
            borderColor: borderColor,
            onTap: () => Get.toNamed(Routes.workHoursSummary),
          ),
        ),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color borderColor;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Document shortcut ─────────────────────────────────────────────────────────
class _DocumentShortcutCard extends StatelessWidget {
  final bool isDark;
  const _DocumentShortcutCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.myDocuments),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF185FA5).withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.folder_open_rounded,
                  color: Color(0xFF185FA5), size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Need to upload MC or proof?',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Use My Documents for uploads, filters, and file history.',
                    style: TextStyle(
                      color:
                          isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Open',
              style: TextStyle(
                color: Color(0xFF185FA5),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Weekly log ────────────────────────────────────────────────────────────────
class _WeeklyLog extends GetView<ScanController> {
  final bool isDark;
  const _WeeklyLog({required this.isDark});

  static const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _blue = Color(0xFF185FA5);

  Color _statusColor(AttendanceRecordStatus? s) => switch (s) {
        AttendanceRecordStatus.present => const Color(0xFF16A34A),
        AttendanceRecordStatus.late => const Color(0xFFF59E0B),
        AttendanceRecordStatus.absent => const Color(0xFFDC2626),
        AttendanceRecordStatus.leave => const Color(0xFF185FA5),
        AttendanceRecordStatus.issue => const Color(0xFF7F77DD),
        null => const Color(0xFF94A3B8),
      };

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : const Color(0xFFF1F5F9);
    final muted = isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8);
    final primary = isDark ? const Color(0xFFE2E8F0) : const Color(0xFF0F172A);
    final timeFmt = DateFormat('h:mm a');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This week',
                    style: TextStyle(
                      color: primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  Obx(() {
                    if (controller.weeklyLog.isEmpty) return const SizedBox.shrink();
                    final start = controller.weekStart;
                    final end = start.add(const Duration(days: 6));
                    final fmt = DateFormat('d MMM');
                    return Text(
                      '${fmt.format(start)} – ${fmt.format(end)}',
                      style: TextStyle(fontSize: 11, color: muted),
                    );
                  }),
                ],
              ),
            ),
            Obx(() {
              final loading = controller.isWeeklyLogLoading.value;
              return GestureDetector(
                onTap: loading ? null : controller.fetchWeeklyLog,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _blue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: loading
                      ? const SizedBox(
                          width: 11,
                          height: 11,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: _blue,
                          ),
                        )
                      : const Text(
                          'Refresh',
                          style: TextStyle(
                            color: _blue,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              );
            }),
          ],
        ),
        const SizedBox(height: 10),

        // Table card
        Obx(() {
          // Show full-card spinner only on first load (no data yet).
          // On refresh the button itself shows the loading state.
          if (controller.isWeeklyLogLoading.value &&
              controller.weeklyLog.isEmpty) {
            return Container(
              height: 120,
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor),
              ),
              child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }

          final days = controller.weeklyLog;

          return Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: days.length,
                separatorBuilder: (_, _) =>
                    Divider(height: 1, thickness: 1, color: dividerColor),
                itemBuilder: (_, i) {
                  final entry = days[i];
                  final rec = entry.record;
                  final isToday = entry.isToday;
                  final isFuture = entry.isFuture;
                  final statusColor = _statusColor(rec?.status);

                  final checkIn = rec?.checkInAt != null
                      ? timeFmt.format(rec!.checkInAt!)
                      : '—';
                  final checkOut = rec?.checkOutAt != null
                      ? timeFmt.format(rec!.checkOutAt!)
                      : '—';
                  final hours = rec?.workingHoursLabel;
                  final statusLabel = rec != null
                      ? AttendanceRecordModel.labelFor(rec.status).tr
                      : null;

                  return Container(
                    decoration: BoxDecoration(
                      border: isToday
                          ? Border(left: BorderSide(color: _blue, width: 3))
                          : null,
                      color: isToday
                          ? _blue.withValues(alpha: isDark ? 0.06 : 0.03)
                          : null,
                    ),
                    padding: EdgeInsets.only(
                      left: isToday ? 11 : 14,
                      right: 14,
                      top: 10,
                      bottom: 10,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Day — single line "MON 23"
                        SizedBox(
                          width: 54,
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '${_dayLabels[i]}  ',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.4,
                                    color: isToday ? _blue : muted,
                                  ),
                                ),
                                TextSpan(
                                  text: DateFormat('d').format(entry.date),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: isToday
                                        ? _blue
                                        : isFuture
                                            ? muted
                                            : primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Status dot + label
                        if (!isFuture && statusLabel != null) ...[
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            statusLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ] else
                          Text(
                            isFuture ? '' : 'No record',
                            style: TextStyle(fontSize: 11, color: muted),
                          ),

                        const Spacer(),

                        // Times — 2 lines: "IN → OUT" then "HRS"
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'IN  ',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF16A34A),
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  TextSpan(
                                    text: checkIn,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isFuture ? muted : primary,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '   OUT  ',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFFDC2626),
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  TextSpan(
                                    text: checkOut,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isFuture ? muted : primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (hours != null && hours != '0h 00m') ...[
                              const SizedBox(height: 2),
                              Text(
                                hours,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _blue,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        }),
      ],
    );
  }
}

