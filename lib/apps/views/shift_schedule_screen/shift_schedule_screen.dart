import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/shift_schedule_controller/shift_schedule_controller.dart';
import 'package:staff_attendance/apps/models/shift_schedule_model.dart';
import 'package:staff_attendance/widgets/app_page_widgets.dart';

class ShiftScheduleScreen extends GetView<ShiftScheduleController> {
  const ShiftScheduleScreen({super.key});

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
            _WeekNav(isDark: isDark),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.errorMessage.isNotEmpty) {
                  return _ErrorState(
                    isDark: isDark,
                    message: controller.errorMessage.value,
                    onRetry: controller.fetchShifts,
                  );
                }
                final shifts = controller.weekShifts;
                if (shifts.isEmpty) {
                  return _EmptyState(isDark: isDark);
                }
                return RefreshIndicator(
                  onRefresh: controller.fetchShifts,
                  color: const Color(0xFF185FA5),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: shifts.length,
                    itemBuilder: (_, index) =>
                        _ShiftCard(item: shifts[index], isDark: isDark),
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

// ── Header ─────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final bool isDark;
  const _Header({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        children: [
          const AppBackButton(),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'shift_schedule'.tr,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Week navigator ─────────────────────────────────────────────────────────

class _WeekNav extends GetView<ShiftScheduleController> {
  final bool isDark;
  const _WeekNav({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Obx(() {
        final onCurrentWeek = controller.isCurrentWeek;
        return Row(
          children: [
            IconButton(
              onPressed: controller.previousWeek,
              icon: const Icon(Icons.chevron_left_rounded),
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
            ),
            Expanded(
              child: Text(
                controller.weekLabel(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
            IconButton(
              onPressed: controller.nextWeek,
              icon: const Icon(Icons.chevron_right_rounded),
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: onCurrentWeek
                  ? const SizedBox(width: 48)
                  : SizedBox(
                      width: 48,
                      child: IconButton(
                        tooltip: 'Jump to today',
                        onPressed: controller.goToCurrentWeek,
                        icon: const Icon(
                          Icons.today_rounded,
                          size: 20,
                        ),
                        color: const Color(0xFF185FA5),
                      ),
                    ),
            ),
          ],
        );
      }),
    );
  }
}

// ── Shift card ─────────────────────────────────────────────────────────────

class _ShiftCard extends GetView<ShiftScheduleController> {
  final ShiftScheduleModel item;
  final bool isDark;
  const _ShiftCard({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final shiftColor = Color(item.colorValue);
    final today = controller.isToday(item.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: today
              ? const Color(0xFF185FA5).withValues(alpha: 0.5)
              : isDark
              ? const Color(0xFF334155)
              : const Color(0xFFE2E8F0),
          width: today ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          // Date badge — solid fill for today, tinted for other days
          Container(
            width: 48,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: today ? const Color(0xFF185FA5) : shiftColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  controller.dayName(item.date),
                  style: TextStyle(
                    color: today ? Colors.white.withValues(alpha: 0.8) : shiftColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  controller.dayNumber(item.date),
                  style: TextStyle(
                    color: today ? Colors.white : shiftColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (today)
                  Text(
                    'TODAY',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
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
                Text(
                  item.title,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.timeLabel} · ${item.location}',
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                  ),
                ),
                if (item.note.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    item.note,
                    style: TextStyle(
                      color: isDark
                          ? const Color(0xFFCBD5E1)
                          : const Color(0xFF475569),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error state ─────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final bool isDark;
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({
    required this.isDark,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 42,
              color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              child: Text(
                'retry'.tr,
                style: const TextStyle(
                  color: Color(0xFF185FA5),
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

// ── Empty state ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.view_week_outlined,
              size: 42,
              color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
            ),
            const SizedBox(height: 12),
            Text(
              'no_shifts'.tr,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'no_shifts_desc'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
