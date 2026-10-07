import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/apply_controller/apply_leave_controller.dart';
import 'package:staff_attendance/widgets/form_widget.dart';

import '../../../../apps/models/leave_model.dart';

class ApplyLeaveScreen extends GetView<ApplyLeaveController> {
  const ApplyLeaveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            appBar(isDark: isDark, title: 'Apply Leave'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _LeaveHero(isDark: isDark),
                      const SizedBox(height: 16),
                      // ── Balance card ──
                      _BalanceCard(isDark: isDark),
                      const SizedBox(height: 16),

                      formSectionCard(
                        isDark: isDark,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sectionLabel(label: 'Leave type', isDark: isDark),
                            const SizedBox(height: 10),
                            _LeaveTypeSelector(isDark: isDark),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      formSectionCard(
                        isDark: isDark,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sectionLabel(label: 'Date range', isDark: isDark),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: datePickerTile(
                                    label: 'Start date',
                                    isDark: isDark,
                                    dateObs: controller.startDate,
                                    onTap: () =>
                                        controller.pickStartDate(context),
                                    icon: Icons.calendar_today_rounded,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: datePickerTile(
                                    label: 'End date',
                                    isDark: isDark,
                                    dateObs: controller.endDate,
                                    onTap: () =>
                                        controller.pickEndDate(context),
                                    icon: Icons.event_rounded,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Obx(() {
                              final days = controller.totalDays;
                              final enough = controller.hasEnoughBalance;
                              if (days == 0) return const SizedBox.shrink();
                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: enough
                                      ? const Color(
                                          0xFF16A34A,
                                        ).withValues(alpha: 0.08)
                                      : const Color(
                                          0xFFDC2626,
                                        ).withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: enough
                                        ? const Color(
                                            0xFF16A34A,
                                          ).withValues(alpha: 0.25)
                                        : const Color(
                                            0xFFDC2626,
                                          ).withValues(alpha: 0.25),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      enough
                                          ? Icons.check_circle_outline_rounded
                                          : Icons.warning_amber_rounded,
                                      size: 18,
                                      color: enough
                                          ? const Color(0xFF16A34A)
                                          : const Color(0xFFDC2626),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        enough
                                            ? '$days day${days > 1 ? 's' : ''} selected · ${controller.remainingForType - days} day(s) left after approval'
                                            : '$days days requested but only ${controller.remainingForType} available',
                                        style: TextStyle(
                                          color: enough
                                              ? const Color(0xFF16A34A)
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
                            sectionLabel(label: 'Reason', isDark: isDark),
                            const SizedBox(height: 10),
                            reasonField(
                              ctrl: controller.reasonCtrl,
                              isDark: isDark,
                              hint:
                                  'Briefly describe why you are applying for leave and any handover notes.',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      noteCard(
                        isDark: isDark,
                        lines: const [
                          'Leave applications require manager approval.',
                          'Medical leave requires an MC from a certified clinic.',
                          'Emergency leave must be applied within 3 working days.',
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

      // ── Submit button ──
      bottomNavigationBar: submitBar(
        isDark: isDark,
        label: 'Submit application',
        color: const Color(0xFF185FA5),
        onTap: controller.submit,
        isSubmitting: controller.isSubmitting,
      ),
    );
  }
}

class _LeaveHero extends StatelessWidget {
  final bool isDark;
  const _LeaveHero({required this.isDark});

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
              ? const [Color(0xFF123F6B), Color(0xFF0F172A)]
              : const [Color(0xFF185FA5), Color(0xFF4DA3E8)],
        ),
      ),
      child: const Row(
        children: [
          Icon(Icons.event_available_rounded, color: Colors.white, size: 26),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plan your leave clearly',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Choose leave type, set dates, and submit with enough detail for fast approval.',
                  style: TextStyle(color: Color(0xFFDCEEFF), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────
// BALANCE CARD (leave screen)
// ─────────────────────────────────────
class _BalanceCard extends GetView<ApplyLeaveController> {
  final bool isDark;
  const _BalanceCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final b = controller.balance.value;
      return Container(
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
            _BalancePill(
              label: 'Annual',
              left: b.annualLeft,
              total: b.annualTotal,
              color: const Color(0xFF185FA5),
              isDark: isDark,
            ),
            _vDivider(isDark),
            _BalancePill(
              label: 'Medical',
              left: b.medicalLeft,
              total: b.medicalTotal,
              color: const Color(0xFFDC2626),
              isDark: isDark,
            ),
            _vDivider(isDark),
            _BalancePill(
              label: 'Emergency',
              left: b.emergencyLeft,
              total: b.emergencyTotal,
              color: const Color(0xFFF59E0B),
              isDark: isDark,
            ),
          ],
        ),
      );
    });
  }

  Widget _vDivider(bool isDark) => Container(
    width: 1,
    height: 36,
    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
    margin: const EdgeInsets.symmetric(horizontal: 12),
  );
}

class _BalancePill extends StatelessWidget {
  final String label;
  final int left;
  final int total;
  final Color color;
  final bool isDark;
  const _BalancePill({
    required this.label,
    required this.left,
    required this.total,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$left',
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '/ $total $label',
            style: TextStyle(
              color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────
// LEAVE TYPE SELECTOR
// ─────────────────────────────────────
class _LeaveTypeSelector extends GetView<ApplyLeaveController> {
  final bool isDark;
  const _LeaveTypeSelector({required this.isDark});

  static const _types = [
    (LeaveType.annual, 'Annual', 0xFF185FA5, Icons.beach_access_rounded),
    (LeaveType.medical, 'Medical', 0xFFDC2626, Icons.local_hospital_rounded),
    (LeaveType.emergency, 'Emergency', 0xFFF59E0B, Icons.warning_amber_rounded),
    (LeaveType.unpaid, 'Unpaid', 0xFF7F77DD, Icons.money_off_rounded),
    (LeaveType.other, 'Other', 0xFF64748B, Icons.more_horiz_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _types.map((t) {
          final isActive = controller.selectedType.value == t.$1;
          final color = Color(t.$3);
          return GestureDetector(
            onTap: () => controller.selectedType(t.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isActive ? color : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isActive
                      ? color
                      : isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    t.$4,
                    size: 15,
                    color: isActive
                        ? Colors.white
                        : isDark
                        ? const Color(0xFF64748B)
                        : const Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    t.$2,
                    style: TextStyle(
                      color: isActive
                          ? Colors.white
                          : isDark
                          ? const Color(0xFF64748B)
                          : const Color(0xFF94A3B8),
                      fontSize: 13,
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
  }
}
