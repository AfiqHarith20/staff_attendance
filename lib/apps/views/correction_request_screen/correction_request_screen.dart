import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:staff_attendance/apps/controllers/correction_request_controller/correction_request_controller.dart';
import 'package:staff_attendance/apps/themes/app_colors.dart';
import 'package:staff_attendance/widgets/app_page_widgets.dart';

class CorrectionRequestScreen extends GetView<CorrectionRequestController> {
  const CorrectionRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0B1324) : const Color(0xFFF8FAFC);
    final card = isDark ? const Color(0xFF182338) : Colors.white;
    final border = isDark ? const Color(0xFF23314F) : const Color(0xFFE2E8F0);
    final muted = isDark ? const Color(0xFF8FA3BF) : const Color(0xFF94A3B8);
    final label = isDark ? Colors.white : const Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Form(
          key: controller.formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            children: [
              // ── Header ──────────────────────────────────────────────────────
              Row(
                children: [
                  const AppBackButton(),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'correction_request'.tr,
                      style: TextStyle(
                        color: label,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 42),
                child: Text(
                  'Submit to HR to fix a missing or incorrect punch record.',
                  style: TextStyle(color: muted, fontSize: 13, height: 1.4),
                ),
              ),
              const SizedBox(height: 20),

              // ── Section 1: Date & Type ───────────────────────────────────
              _SectionLabel(label: 'Date & Type', isDark: isDark),
              const SizedBox(height: 8),
              _Card(isDark: isDark, card: card, border: border, child: Column(
                children: [
                  // Date picker row
                  Obx(() => _PickerTile(
                    icon: Icons.event_rounded,
                    iconBg: isDark ? const Color(0xFF1A3556) : const Color(0xFFE6F1FB),
                    iconColor: AppColors.primary,
                    label: 'Attendance date',
                    value: DateFormat('EEEE, d MMM yyyy')
                        .format(controller.selectedDate.value),
                    isDark: isDark,
                    onTap: () => controller.pickDate(context),
                  )),
                  _Divider(isDark: isDark),
                  // Correction type dropdown
                  Obx(() => _TypeDropdown(
                    value: controller.requestType.value,
                    items: controller.requestTypes,
                    isDark: isDark,
                    label: label,
                    muted: muted,
                    onChanged: (v) {
                      if (v != null) controller.requestType(v);
                    },
                  )),
                ],
              )),
              const SizedBox(height: 16),

              // ── Section 2: Time Correction ──────────────────────────────
              _SectionLabel(label: 'Correct time', isDark: isDark),
              const SizedBox(height: 8),
              _Card(isDark: isDark, card: card, border: border, child: Column(
                children: [
                  // Check-in time picker
                  Obx(() => _TimeTile(
                    icon: Icons.login_rounded,
                    iconBg: isDark ? const Color(0xFF0D2A1A) : const Color(0xFFEAF3DE),
                    iconColor: const Color(0xFF16A34A),
                    label: 'correct_checkin'.tr,
                    time: controller.selectedCheckIn.value,
                    placeholder: 'Tap to select check-in time',
                    isDark: isDark,
                    muted: muted,
                    onTap: () => controller.pickCheckInTime(context),
                    onClear: controller.selectedCheckIn.value != null
                        ? () => controller.selectedCheckIn(null)
                        : null,
                  )),
                  _Divider(isDark: isDark),
                  // Check-out time picker
                  Obx(() => _TimeTile(
                    icon: Icons.logout_rounded,
                    iconBg: isDark ? const Color(0xFF2A1F0A) : const Color(0xFFFAEEDA),
                    iconColor: const Color(0xFFF59E0B),
                    label: 'correct_checkout'.tr,
                    time: controller.selectedCheckOut.value,
                    placeholder: 'Tap to select check-out time',
                    isDark: isDark,
                    muted: muted,
                    onTap: () => controller.pickCheckOutTime(context),
                    onClear: controller.selectedCheckOut.value != null
                        ? () => controller.selectedCheckOut(null)
                        : null,
                  )),
                ],
              )),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  'Leave a field empty if it does not need correction.',
                  style: TextStyle(color: muted, fontSize: 11),
                ),
              ),
              const SizedBox(height: 16),

              // ── Section 3: Reason ────────────────────────────────────────
              _SectionLabel(label: 'Reason', isDark: isDark),
              const SizedBox(height: 8),
              _Card(isDark: isDark, card: card, border: border, child: TextFormField(
                controller: controller.reasonController,
                minLines: 4,
                maxLines: 6,
                style: TextStyle(
                  color: label,
                  fontSize: 14,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'reason_required'.tr;
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'correction_reason_hint'.tr,
                  hintStyle: TextStyle(color: muted, fontSize: 13),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(bottom: 60),
                    child: Icon(Icons.notes_rounded, color: muted, size: 20),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
                ),
              )),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Obx(
            () => FilledButton.icon(
              onPressed:
                  controller.isSubmitting.value ? null : controller.submit,
              icon: controller.isSubmitting.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send_rounded, size: 18),
              label: Text('submit_request'.tr),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Shared widgets ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isDark;
  const _SectionLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final bool isDark;
  final Color card;
  final Color border;
  final Widget child;
  const _Card({
    required this.isDark,
    required this.card,
    required this.border,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: child,
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final bool isDark;
  const _Divider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 56,
      color: isDark
          ? Colors.white.withValues(alpha: 0.07)
          : const Color(0xFFE2E8F0),
    );
  }
}

// Tappable row for date and other single-value pickers.
class _PickerTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String value;
  final bool isDark;
  final VoidCallback onTap;

  const _PickerTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final labelColor = isDark ? const Color(0xFF8FA3BF) : const Color(0xFF64748B);
    final valueColor = isDark ? Colors.white : const Color(0xFF1E293B);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          color: labelColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(value,
                      style: TextStyle(
                          color: valueColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 18,
                color: isDark
                    ? const Color(0xFF4A6080)
                    : const Color(0xFFCBD5E1)),
          ],
        ),
      ),
    );
  }
}

// Time picker tile — shows selected time or placeholder; has a clear button.
class _TimeTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final TimeOfDay? time;
  final String placeholder;
  final bool isDark;
  final Color muted;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _TimeTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.time,
    required this.placeholder,
    required this.isDark,
    required this.muted,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final hasTime = time != null;
    final labelColor = isDark ? const Color(0xFF8FA3BF) : const Color(0xFF64748B);
    final valueColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final timeStr = hasTime
        ? MaterialLocalizations.of(context).formatTimeOfDay(time!)
        : null;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          color: labelColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  hasTime
                      ? Row(
                          children: [
                            Text(timeStr!,
                                style: TextStyle(
                                    color: valueColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: iconBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text('SET',
                                  style: TextStyle(
                                      color: iconColor,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5)),
                            ),
                          ],
                        )
                      : Text(placeholder,
                          style:
                              TextStyle(color: muted, fontSize: 13)),
                ],
              ),
            ),
            if (hasTime)
              GestureDetector(
                onTap: onClear,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.close_rounded,
                      size: 16, color: muted),
                ),
              )
            else
              Icon(Icons.access_time_rounded,
                  size: 18,
                  color: isDark
                      ? const Color(0xFF4A6080)
                      : const Color(0xFFCBD5E1)),
          ],
        ),
      ),
    );
  }
}

// Inline correction type selector — segmented-style rows instead of a dropdown.
class _TypeDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final bool isDark;
  final Color label;
  final Color muted;
  final ValueChanged<String?> onChanged;

  const _TypeDropdown({
    required this.value,
    required this.items,
    required this.isDark,
    required this.label,
    required this.muted,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Correction type',
              style: TextStyle(
                  color: muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((type) {
              final selected = type == value;
              return GestureDetector(
                onTap: () => onChanged(type),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary.withValues(alpha: isDark ? 0.25 : 0.10)
                        : (isDark
                            ? const Color(0xFF0F172A)
                            : const Color(0xFFF8FAFC)),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected
                          ? AppColors.primary
                          : (isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFE2E8F0)),
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    type,
                    style: TextStyle(
                      color: selected
                          ? AppColors.primary
                          : (isDark ? const Color(0xFF8FA3BF) : const Color(0xFF64748B)),
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
