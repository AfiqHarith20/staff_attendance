import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:staff_attendance/widgets/form_widget.dart';

import '../../../../apps/controllers/submit_claim_controller/submit_claim_controller.dart';
import '../../../../apps/models/claim_model.dart';

class SubmitClaimScreen extends GetView<SubmitClaimController> {
  const SubmitClaimScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            appBar(isDark: isDark, title: 'claims'.tr),
            Expanded(
              child: Obx(() {
                final isMileage = controller.isMileage;
                final isGeneral = controller.selectedCategory.value == ClaimCategory.general;
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ClaimHero(isDark: isDark),
                        const SizedBox(height: 16),
                        _CategoryToggle(isDark: isDark),
                        const SizedBox(height: 16),
                        if (isGeneral) ...[
                          _GeneralTypeSelector(isDark: isDark),
                          const SizedBox(height: 16),
                          _GeneralDetailsForm(isDark: isDark),
                        ] else ...[
                          _TravelTypeSelector(isDark: isDark),
                          const SizedBox(height: 16),
                          if (isMileage)
                            _MileageForm(isDark: isDark)
                          else
                            _TravelForm(isDark: isDark),
                        ],
                        const SizedBox(height: 16),
                        if (!isMileage) _ReceiptSection(isDark: isDark),
                        if (!isMileage) const SizedBox(height: 16),
                        noteCard(
                          isDark: isDark,
                          lines: [
                            'claim_approval_note'.tr,
                            'claim_receipt_note'.tr,
                            if (isMileage) 'claim_mileage_note'.tr,
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: submitBar(
        isDark: isDark,
        label: 'apply_claim'.tr,
        color: const Color(0xFF16A34A),
        onTap: controller.submit,
        isSubmitting: controller.isSubmitting,
      ),
    );
  }
}

// ── Hero ──────────────────────────────────────────────────────────────────────
class _ClaimHero extends StatelessWidget {
  final bool isDark;
  const _ClaimHero({required this.isDark});

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
              ? const [Color(0xFF14532D), Color(0xFF0F172A)]
              : const [Color(0xFF16A34A), Color(0xFF4ADE80)],
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'submit_claim_title'.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'submit_claim_subtitle'.tr,
                  style: const TextStyle(color: Color(0xFFE8FFF0), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Category toggle (General | Travel) ────────────────────────────────────────
class _CategoryToggle extends GetView<SubmitClaimController> {
  final bool isDark;
  const _CategoryToggle({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isGeneral = controller.selectedCategory.value == ClaimCategory.general;
      return formSectionCard(
        isDark: isDark,
        child: Row(
          children: [
            _CatTab(
              isDark: isDark,
              label: 'claim_category_general'.tr,
              subtitle: 'general_claim_subtitle'.tr,
              icon: Icons.receipt_rounded,
              active: isGeneral,
              color: const Color(0xFF16A34A),
              onTap: () => controller.switchCategory(ClaimCategory.general),
            ),
            const SizedBox(width: 10),
            _CatTab(
              isDark: isDark,
              label: 'claim_category_travel'.tr,
              subtitle: 'travel_claim_subtitle'.tr,
              icon: Icons.flight_rounded,
              active: !isGeneral,
              color: const Color(0xFF185FA5),
              onTap: () => controller.switchCategory(ClaimCategory.travel),
            ),
          ],
        ),
      );
    });
  }
}

class _CatTab extends StatelessWidget {
  final bool isDark;
  final String label;
  final String subtitle;
  final IconData icon;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  const _CatTab({
    required this.isDark,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.active,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: active ? color.withValues(alpha: 0.10) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: active
                  ? color
                  : isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              width: active ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 18,
                color: active
                    ? color
                    : isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: active
                      ? color
                      : isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── General type selector ─────────────────────────────────────────────────────
class _GeneralTypeSelector extends GetView<SubmitClaimController> {
  final bool isDark;
  const _GeneralTypeSelector({required this.isDark});

  static const _types = [
    (ClaimType.medical, 'claim_medical', 0xFF185FA5, Icons.local_hospital_rounded),
    (ClaimType.transport, 'claim_transport', 0xFF16A34A, Icons.directions_car_rounded),
    (ClaimType.meal, 'claim_meal', 0xFFF59E0B, Icons.restaurant_rounded),
    (ClaimType.accommodation, 'claim_accommodation', 0xFF7F77DD, Icons.hotel_rounded),
    (ClaimType.officeExpenses, 'claim_office_expenses', 0xFF64748B, Icons.business_center_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return formSectionCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sectionLabel(label: 'claim_type'.tr, isDark: isDark),
          const SizedBox(height: 10),
          Obx(() => Row(
            children: _types.asMap().entries.map((entry) {
              final i = entry.key;
              final t = entry.value;
              final isActive = controller.selectedGeneralType.value == t.$1;
              final color = Color(t.$3);
              return Expanded(
                child: GestureDetector(
                  onTap: () => controller.selectedGeneralType(t.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: i < _types.length - 1
                        ? const EdgeInsets.only(right: 6)
                        : EdgeInsets.zero,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isActive ? color.withValues(alpha: 0.12) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isActive
                            ? color
                            : isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        width: isActive ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          t.$4,
                          size: 18,
                          color: isActive
                              ? color
                              : isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          t.$2.tr,
                          style: TextStyle(
                            color: isActive
                                ? color
                                : isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          )),
        ],
      ),
    );
  }
}

// ── Travel type selector ──────────────────────────────────────────────────────
class _TravelTypeSelector extends GetView<SubmitClaimController> {
  final bool isDark;
  const _TravelTypeSelector({required this.isDark});

  static const _types = [
    (ClaimType.mileage, 'claim_mileage', 0xFF16A34A, Icons.directions_car_rounded),
    (ClaimType.fixedLimit, 'claim_fixed_limit', 0xFF185FA5, Icons.flight_rounded),
    (ClaimType.oneShot, 'claim_one_shot', 0xFFF59E0B, Icons.attach_money_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return formSectionCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sectionLabel(label: 'claim_type'.tr, isDark: isDark),
          const SizedBox(height: 10),
          Obx(() => Row(
            children: _types.asMap().entries.map((entry) {
              final i = entry.key;
              final t = entry.value;
              final isActive = controller.selectedTravelType.value == t.$1;
              final color = Color(t.$3);
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    controller.selectedTravelType(t.$1);
                    controller.previewedAmount(null);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: i < _types.length - 1
                        ? const EdgeInsets.only(right: 8)
                        : EdgeInsets.zero,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isActive ? color.withValues(alpha: 0.12) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isActive
                            ? color
                            : isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        width: isActive ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          t.$4,
                          size: 20,
                          color: isActive
                              ? color
                              : isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          t.$2.tr,
                          style: TextStyle(
                            color: isActive
                                ? color
                                : isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          )),
        ],
      ),
    );
  }
}

// ── General details form ──────────────────────────────────────────────────────
class _GeneralDetailsForm extends GetView<SubmitClaimController> {
  final bool isDark;
  const _GeneralDetailsForm({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return formSectionCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sectionLabel(label: 'claim_amount'.tr, isDark: isDark),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _AmountField(isDark: isDark)),
              const SizedBox(width: 10),
              Expanded(
                child: _DateTile(
                  isDark: isDark,
                  dateObs: controller.claimDate,
                  onTap: () => controller.pickDate(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          sectionLabel(label: 'claim_description'.tr, isDark: isDark),
          const SizedBox(height: 10),
          _DescriptionField(isDark: isDark, required: true),
        ],
      ),
    );
  }
}

// ── Mileage form ──────────────────────────────────────────────────────────────
class _MileageForm extends GetView<SubmitClaimController> {
  final bool isDark;
  const _MileageForm({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        formSectionCard(
          isDark: isDark,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              sectionLabel(label: 'vehicle_type'.tr, isDark: isDark),
              const SizedBox(height: 10),
              _VehicleSelector(isDark: isDark),
              const SizedBox(height: 14),
              sectionLabel(label: 'distance_km'.tr, isDark: isDark),
              const SizedBox(height: 10),
              _DistanceField(isDark: isDark),
              const SizedBox(height: 14),
              sectionLabel(label: 'claim_date'.tr, isDark: isDark),
              const SizedBox(height: 10),
              _DateTile(
                isDark: isDark,
                dateObs: controller.claimDate,
                onTap: () => controller.pickDate(context),
                fullWidth: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        formSectionCard(
          isDark: isDark,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              sectionLabel(label: 'additional_costs'.tr, isDark: isDark),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _OptionalAmountField(
                    isDark: isDark,
                    ctrl: controller.tollCtrl,
                    label: 'toll_amount'.tr,
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: _OptionalAmountField(
                    isDark: isDark,
                    ctrl: controller.parkingCtrl,
                    label: 'parking_amount'.tr,
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: _OptionalAmountField(
                    isDark: isDark,
                    ctrl: controller.miscCtrl,
                    label: 'misc_amount'.tr,
                  )),
                ],
              ),
              const SizedBox(height: 14),
              _MileagePreviewBar(isDark: isDark),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Travel (non-mileage) form ─────────────────────────────────────────────────
class _TravelForm extends GetView<SubmitClaimController> {
  final bool isDark;
  const _TravelForm({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return formSectionCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sectionLabel(label: 'claim_amount'.tr, isDark: isDark),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _AmountField(isDark: isDark)),
              const SizedBox(width: 10),
              Expanded(
                child: _DateTile(
                  isDark: isDark,
                  dateObs: controller.claimDate,
                  onTap: () => controller.pickDate(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          sectionLabel(label: 'travel_from'.tr, isDark: isDark),
          const SizedBox(height: 10),
          _TextFieldInput(
            isDark: isDark,
            ctrl: controller.travelFromCtrl,
            hint: 'e.g. Kuala Lumpur',
            required: true,
          ),
          const SizedBox(height: 12),
          sectionLabel(label: 'travel_to'.tr, isDark: isDark),
          const SizedBox(height: 10),
          _TextFieldInput(
            isDark: isDark,
            ctrl: controller.travelToCtrl,
            hint: 'e.g. Penang',
            required: true,
          ),
          const SizedBox(height: 12),
          sectionLabel(label: 'travel_purpose'.tr, isDark: isDark),
          const SizedBox(height: 10),
          _DescriptionField(isDark: isDark, required: false),
        ],
      ),
    );
  }
}

// ── Vehicle selector ──────────────────────────────────────────────────────────
class _VehicleSelector extends GetView<SubmitClaimController> {
  final bool isDark;
  const _VehicleSelector({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
      children: [
        _VehicleTab(
          isDark: isDark,
          label: 'vehicle_car'.tr,
          icon: Icons.directions_car_rounded,
          active: controller.selectedVehicle.value == 'car',
          onTap: () {
            controller.selectedVehicle('car');
            controller.previewedAmount(null);
          },
        ),
        const SizedBox(width: 10),
        _VehicleTab(
          isDark: isDark,
          label: 'vehicle_motorbike'.tr,
          icon: Icons.two_wheeler_rounded,
          active: controller.selectedVehicle.value == 'motorbike',
          onTap: () {
            controller.selectedVehicle('motorbike');
            controller.previewedAmount(null);
          },
        ),
      ],
    ));
  }
}

class _VehicleTab extends StatelessWidget {
  final bool isDark;
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _VehicleTab({
    required this.isDark,
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active
                ? const Color(0xFF16A34A).withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: active
                  ? const Color(0xFF16A34A)
                  : isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              width: active ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: active
                    ? const Color(0xFF16A34A)
                    : isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: active
                      ? const Color(0xFF16A34A)
                      : isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Mileage preview bar ───────────────────────────────────────────────────────
class _MileagePreviewBar extends GetView<SubmitClaimController> {
  final bool isDark;
  const _MileagePreviewBar({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final previewed = controller.previewedAmount.value;
      final isPreviewing = controller.isPreviewing.value;
      return Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: isPreviewing ? null : controller.previewMileage,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 44,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Center(
                  child: isPreviewing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF16A34A),
                          ),
                        )
                      : Text(
                          'preview_mileage'.tr,
                          style: TextStyle(
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
              ),
            ),
          ),
          if (previewed != null) ...[
            const SizedBox(width: 10),
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF16A34A).withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF16A34A).withValues(alpha: 0.3)),
              ),
              child: Center(
                child: Text(
                  'mileage_calculated'.trParams({'amount': previewed.toStringAsFixed(2)}),
                  style: const TextStyle(
                    color: Color(0xFF16A34A),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      );
    });
  }
}

// ── Distance field ────────────────────────────────────────────────────────────
class _DistanceField extends GetView<SubmitClaimController> {
  final bool isDark;
  const _DistanceField({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller.distanceCtrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
      ],
      onChanged: (_) => controller.previewedAmount(null),
      style: TextStyle(
        color: isDark ? Colors.white : const Color(0xFF0F172A),
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      decoration: _inputDec(
        isDark: isDark,
        hint: '0.0',
        suffix: 'km',
        focusColor: const Color(0xFF16A34A),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'reason_required'.tr;
        if ((double.tryParse(v) ?? 0) <= 0) return 'missing_distance_body'.tr;
        return null;
      },
    );
  }
}

// ── Amount field ──────────────────────────────────────────────────────────────
class _AmountField extends GetView<SubmitClaimController> {
  final bool isDark;
  const _AmountField({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller.amountCtrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      style: TextStyle(
        color: isDark ? Colors.white : const Color(0xFF0F172A),
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      decoration: _inputDec(
        isDark: isDark,
        hint: '0.00',
        prefix: 'RM  ',
        focusColor: const Color(0xFF16A34A),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'reason_required'.tr;
        final a = double.tryParse(v);
        if (a == null || a <= 0) return 'invalid_amount'.tr;
        return null;
      },
    );
  }
}

// ── Optional amount field (toll, parking, misc) ────────────────────────────────
class _OptionalAmountField extends StatelessWidget {
  final bool isDark;
  final TextEditingController ctrl;
  final String label;

  const _OptionalAmountField({
    required this.isDark,
    required this.ctrl,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          decoration: _inputDec(
            isDark: isDark,
            hint: '0.00',
            prefix: 'RM ',
            focusColor: const Color(0xFF16A34A),
            dense: true,
          ),
        ),
      ],
    );
  }
}

// ── Date tile ─────────────────────────────────────────────────────────────────
class _DateTile extends StatelessWidget {
  final bool isDark;
  final Rxn<DateTime> dateObs;
  final VoidCallback onTap;
  final bool fullWidth;

  const _DateTile({
    required this.isDark,
    required this.dateObs,
    required this.onTap,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!fullWidth)
          Text(
            'claim_date'.tr.toUpperCase(),
            style: TextStyle(
              color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
            ),
          ),
        if (!fullWidth) const SizedBox(height: 8),
        Obx(() {
          final d = dateObs.value;
          final hasDate = d != null;
          return GestureDetector(
            onTap: onTap,
            child: Container(
              height: 56,
              width: fullWidth ? double.infinity : null,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasDate
                      ? const Color(0xFF16A34A)
                      : isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 16,
                    color: hasDate
                        ? const Color(0xFF16A34A)
                        : isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    hasDate ? DateFormat('d MMM yy').format(d) : 'pick_date'.tr,
                    style: TextStyle(
                      color: hasDate
                          ? isDark ? Colors.white : const Color(0xFF0F172A)
                          : isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ── Description field ─────────────────────────────────────────────────────────
class _DescriptionField extends GetView<SubmitClaimController> {
  final bool isDark;
  final bool required;

  const _DescriptionField({required this.isDark, required this.required});

  TextEditingController get ctrl => required
      ? controller.descriptionCtrl
      : controller.travelPurposeCtrl;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      maxLines: 3,
      style: TextStyle(
        color: isDark ? Colors.white : const Color(0xFF0F172A),
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: required
            ? 'claim_desc_hint'.tr
            : 'travel_purpose_hint'.tr,
        hintStyle: TextStyle(
          color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
          fontSize: 13,
        ),
        fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF16A34A), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDC2626)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDC2626)),
        ),
      ),
      validator: required
          ? (v) {
              if (v == null || v.trim().isEmpty) return 'reason_required'.tr;
              if (v.trim().length < 5) return 'reason_too_short'.tr;
              return null;
            }
          : null,
    );
  }
}

// ── Generic text input ────────────────────────────────────────────────────────
class _TextFieldInput extends StatelessWidget {
  final bool isDark;
  final TextEditingController ctrl;
  final String hint;
  final bool required;

  const _TextFieldInput({
    required this.isDark,
    required this.ctrl,
    required this.hint,
    required this.required,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      style: TextStyle(
        color: isDark ? Colors.white : const Color(0xFF0F172A),
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
          fontSize: 13,
        ),
        fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF16A34A), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDC2626)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDC2626)),
        ),
      ),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? 'reason_required'.tr : null
          : null,
    );
  }
}

// ── Receipt section ───────────────────────────────────────────────────────────
class _ReceiptSection extends GetView<SubmitClaimController> {
  final bool isDark;
  const _ReceiptSection({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return formSectionCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sectionLabel(label: 'add_receipt'.tr, isDark: isDark),
          const SizedBox(height: 10),
          Obx(() {
            final hasFile = controller.receiptFile.value != null;
            final isPicking = controller.isPickingFile.value;
            final err = controller.fileError.value;

            return Column(
              children: [
                GestureDetector(
                  onTap: hasFile ? null : controller.pickReceipt,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: hasFile ? 14 : 20),
                    decoration: BoxDecoration(
                      color: hasFile
                          ? const Color(0xFF16A34A).withValues(alpha: 0.06)
                          : isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: hasFile
                            ? const Color(0xFF16A34A).withValues(alpha: 0.3)
                            : isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                        width: 1.5,
                      ),
                    ),
                    child: isPicking
                        ? const Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF16A34A),
                              ),
                            ),
                          )
                        : hasFile
                        ? _FilePreview(isDark: isDark)
                        : _UploadPrompt(isDark: isDark),
                  ),
                ),
                if (err.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      err,
                      style: const TextStyle(color: Color(0xFFDC2626), fontSize: 12),
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _UploadPrompt extends StatelessWidget {
  final bool isDark;
  const _UploadPrompt({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFEAF3DE),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.upload_file_rounded, color: Color(0xFF16A34A), size: 22),
        ),
        const SizedBox(height: 10),
        Text(
          'add_receipt'.tr,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1E293B),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'add_receipt_note'.tr,
          style: TextStyle(
            color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _FilePreview extends GetView<SubmitClaimController> {
  final bool isDark;
  const _FilePreview({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF16A34A).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.description_rounded, color: Color(0xFF16A34A), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.receiptName.value,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${controller.receiptSizeKB.value} KB',
                  style: TextStyle(
                    color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: controller.removeReceipt,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFFDC2626).withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.close_rounded, color: Color(0xFFDC2626), size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared input decoration helper ────────────────────────────────────────────
InputDecoration _inputDec({
  required bool isDark,
  String? hint,
  String? prefix,
  String? suffix,
  Color focusColor = const Color(0xFF16A34A),
  bool dense = false,
}) {
  final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
  return InputDecoration(
    hintText: hint,
    prefixText: prefix,
    suffixText: suffix,
    isDense: dense,
    hintStyle: TextStyle(
      color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
    ),
    prefixStyle: TextStyle(
      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
      fontWeight: FontWeight.w600,
    ),
    suffixStyle: TextStyle(
      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
      fontSize: 12,
    ),
    fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
    filled: true,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: borderColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: borderColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: focusColor, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFDC2626)),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFDC2626)),
    ),
  );
}
