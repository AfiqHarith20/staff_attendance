import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/apply_controller/apply_overtime_controller.dart';
import 'package:staff_attendance/apps/models/overtime_model.dart';
import 'package:staff_attendance/widgets/form_widget.dart';

class ApplyOvertimeScreen extends GetView<ApplyOvertimeController> {
  const ApplyOvertimeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            appBar(isDark: isDark, title: 'apply_ot'.tr),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _OvertimeHero(isDark: isDark),
                      const SizedBox(height: 16),
                      formSectionCard(
                        isDark: isDark,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sectionLabel(label: 'overtime_type'.tr, isDark: isDark),
                            const SizedBox(height: 10),
                            _OtTypeSelector(isDark: isDark),
                            const SizedBox(height: 14),
                            _RateCard(isDark: isDark),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      formSectionCard(
                        isDark: isDark,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sectionLabel(label: 'ot_date'.tr, isDark: isDark),
                            const SizedBox(height: 10),
                            datePickerTile(
                              label: 'select_date'.tr,
                              isDark: isDark,
                              dateObs: controller.selectedDate,
                              onTap: () => controller.pickDate(context),
                              icon: Icons.calendar_today_rounded,
                            ),
                            const SizedBox(height: 16),
                            sectionLabel(label: 'time_range'.tr, isDark: isDark),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _TimePickerTile(
                                    label: 'start_time'.tr,
                                    isDark: isDark,
                                    timeObs: controller.startTime,
                                    onTap: () => controller.pickStartTime(context),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 16,
                                    color: isDark
                                        ? const Color(0xFF475569)
                                        : const Color(0xFF94A3B8),
                                  ),
                                ),
                                Expanded(
                                  child: _TimePickerTile(
                                    label: 'end_time'.tr,
                                    isDark: isDark,
                                    timeObs: controller.endTime,
                                    onTap: () => controller.pickEndTime(context),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Obx(() {
                              final dur = controller.durationLabel;
                              if (dur == '—') return const SizedBox.shrink();
                              final valid = dur != 'invalid_time'.tr;
                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: valid
                                      ? const Color(0xFFF59E0B).withValues(alpha: 0.08)
                                      : const Color(0xFFDC2626).withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: valid
                                        ? const Color(0xFFF59E0B).withValues(alpha: 0.3)
                                        : const Color(0xFFDC2626).withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      valid
                                          ? Icons.timer_outlined
                                          : Icons.warning_amber_rounded,
                                      size: 18,
                                      color: valid
                                          ? const Color(0xFFF59E0B)
                                          : const Color(0xFFDC2626),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        valid
                                            ? 'ot_total_duration'.trParams({
                                                'dur': dur,
                                                'hours': controller.estimatedHours
                                                    .toStringAsFixed(1),
                                              })
                                            : 'end_after_start'.tr,
                                        style: TextStyle(
                                          color: valid
                                              ? const Color(0xFFF59E0B)
                                              : const Color(0xFFDC2626),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      formSectionCard(
                        isDark: isDark,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sectionLabel(label: 'reason_task_desc'.tr, isDark: isDark),
                            const SizedBox(height: 10),
                            reasonField(
                              ctrl: controller.reasonCtrl,
                              isDark: isDark,
                              hint: 'ot_reason_hint'.tr,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      noteCard(
                        isDark: isDark,
                        lines: [
                          'ot_approval_note'.tr,
                          'ot_advance_note'.tr,
                          'ot_rate_note'.tr,
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: submitBar(
        isDark: isDark,
        label: 'submit_ot_request'.tr,
        color: const Color(0xFFD97706),
        onTap: controller.submit,
        isSubmitting: controller.isSubmitting,
      ),
    );
  }
}

class _OvertimeHero extends StatelessWidget {
  final bool isDark;
  const _OvertimeHero({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF5B3411), Color(0xFF0F172A)]
              : const [Color(0xFFD97706), Color(0xFFF59E0B)],
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.more_time_rounded, color: Colors.white, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'log_ot_title'.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'log_ot_subtitle'.tr,
                  style: const TextStyle(color: Color(0xFFFFF1D6), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── OT Type Selector ──────────────────────────────────────────────────────────
class _OtTypeSelector extends GetView<ApplyOvertimeController> {
  final bool isDark;
  const _OtTypeSelector({required this.isDark});

  static const _types = [
    (OvertimeType.weekday, 'ot_weekday', 0xFFD97706, '1.5×'),
    (OvertimeType.weekend, 'ot_weekend', 0xFF185FA5, '2.0×'),
    (OvertimeType.publicHoliday, 'ot_public_holiday', 0xFF7F77DD, '3.0×'),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        children: _types.asMap().entries.map((entry) {
          final t = entry.value;
          final isLast = entry.key == _types.length - 1;
          final isActive = controller.selectedType.value == t.$1;
          final color = Color(t.$3);

          return Expanded(
            child: GestureDetector(
              onTap: () => controller.selectedType(t.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: isLast ? EdgeInsets.zero : const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isActive ? color.withValues(alpha: 0.12) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isActive
                        ? color
                        : isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                    width: isActive ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      t.$4,
                      style: TextStyle(
                        color: isActive
                            ? color
                            : isDark
                            ? Colors.white
                            : const Color(0xFF0F172A),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      t.$2.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isActive
                            ? color
                            : isDark
                            ? const Color(0xFF64748B)
                            : const Color(0xFF94A3B8),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Rate card ─────────────────────────────────────────────────────────────────
class _RateCard extends GetView<ApplyOvertimeController> {
  final bool isDark;
  const _RateCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFFF59E0B)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'ot_rate_label'.trParams({
                  'type': controller.typeLabel.tr,
                  'rate': controller.rateLabel,
                }),
                style: const TextStyle(
                  color: Color(0xFFF59E0B),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Time picker tile ──────────────────────────────────────────────────────────
class _TimePickerTile extends StatelessWidget {
  final String label;
  final bool isDark;
  final Rxn<TimeOfDay> timeObs;
  final VoidCallback onTap;

  const _TimePickerTile({
    required this.label,
    required this.isDark,
    required this.timeObs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final time = timeObs.value;
      final hasTime = time != null;
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasTime
                  ? const Color(0xFFD97706)
                  : isDark
                  ? const Color(0xFF334155)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.04,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 16,
                    color: hasTime
                        ? const Color(0xFFD97706)
                        : isDark
                        ? const Color(0xFF475569)
                        : const Color(0xFFCBD5E1),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    hasTime ? time.format(context) : '—:——',
                    style: TextStyle(
                      color: hasTime
                          ? isDark
                                ? Colors.white
                                : const Color(0xFF0F172A)
                          : isDark
                          ? const Color(0xFF475569)
                          : const Color(0xFFCBD5E1),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
