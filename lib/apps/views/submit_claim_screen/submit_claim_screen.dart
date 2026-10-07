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
            _buildAppBar(context, isDark),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ClaimHero(isDark: isDark),
                      const SizedBox(height: 16),
                      formSectionCard(
                        isDark: isDark,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sectionLabel(label: 'Claim type', isDark: isDark),
                            const SizedBox(height: 10),
                            _ClaimTypeSelector(isDark: isDark),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      formSectionCard(
                        isDark: isDark,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sectionLabel(
                              label: 'Claim details',
                              isDark: isDark,
                            ),
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
                            sectionLabel(label: 'Description', isDark: isDark),
                            const SizedBox(height: 10),
                            _DescriptionField(isDark: isDark),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      formSectionCard(
                        isDark: isDark,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sectionLabel(
                              label: 'Receipt / supporting document',
                              isDark: isDark,
                            ),
                            const SizedBox(height: 10),
                            _ReceiptUploader(isDark: isDark),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      noteCard(
                        isDark: isDark,
                        lines: const [
                          'Attach a clear receipt or supporting document for each claim.',
                          'Include enough description so finance can understand the purpose quickly.',
                          'Claims may be rejected or returned if the amount, date, or proof is incomplete.',
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
      bottomNavigationBar: _SubmitBottomBar(isDark: isDark),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
    return appBar(isDark: isDark, title: 'Submit Claim');
  }
}

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
      child: const Row(
        children: [
          Icon(Icons.receipt_long_rounded, color: Colors.white, size: 26),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Submit a complete claim',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Add the amount, date, and receipt clearly so finance can review and process it faster.',
                  style: TextStyle(color: Color(0xFFE8FFF0), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Claim type selector ───────────────────────────────────────────────────────
class _ClaimTypeSelector extends GetView<SubmitClaimController> {
  final bool isDark;
  const _ClaimTypeSelector({required this.isDark});

  static const _types = [
    (ClaimType.medical, 'Medical', 0xFF185FA5, Icons.local_hospital_rounded),
    (
      ClaimType.transport,
      'Transport',
      0xFF16A34A,
      Icons.directions_car_rounded,
    ),
    (ClaimType.meal, 'Meal', 0xFFF59E0B, Icons.restaurant_rounded),
    (ClaimType.accommodation, 'Hotel', 0xFF7F77DD, Icons.hotel_rounded),
    (ClaimType.others, 'Others', 0xFF64748B, Icons.more_horiz_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CLAIM TYPE',
          style: TextStyle(
            color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 10),
        Obx(
          () => Row(
            children: _types.asMap().entries.map((entry) {
              final i = entry.key;
              final t = entry.value;
              final isActive = controller.selectedType.value == t.$1;
              final color = Color(t.$3);
              return Expanded(
                child: GestureDetector(
                  onTap: () => controller.selectedType(t.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: i < _types.length - 1
                        ? const EdgeInsets.only(right: 6)
                        : EdgeInsets.zero,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isActive
                          ? color.withOpacity(0.12)
                          : Colors.transparent,
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
                        Icon(
                          t.$4,
                          size: 18,
                          color: isActive
                              ? color
                              : isDark
                              ? const Color(0xFF475569)
                              : const Color(0xFFCBD5E1),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          t.$2,
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
        ),
      ],
    );
  }
}

// ── Amount field ──────────────────────────────────────────────────────────────
class _AmountField extends GetView<SubmitClaimController> {
  final bool isDark;
  const _AmountField({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AMOUNT (RM)',
          style: TextStyle(
            color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
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
          decoration: InputDecoration(
            prefixText: 'RM  ',
            prefixStyle: TextStyle(
              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
            hintText: '0.00',
            hintStyle: TextStyle(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
            ),
            fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF16A34A),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFDC2626)),
            ),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Required';
            final a = double.tryParse(v);
            if (a == null || a <= 0) return 'Invalid amount';
            if (a > 10000) return 'Max RM 10,000';
            return null;
          },
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
  const _DateTile({
    required this.isDark,
    required this.dateObs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CLAIM DATE',
          style: TextStyle(
            color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() {
          final d = dateObs.value;
          final hasDate = d != null;
          return GestureDetector(
            onTap: onTap,
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasDate
                      ? const Color(0xFF16A34A)
                      : isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 16,
                    color: hasDate
                        ? const Color(0xFF16A34A)
                        : isDark
                        ? const Color(0xFF475569)
                        : const Color(0xFFCBD5E1),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    hasDate ? DateFormat('d MMM yy').format(d) : 'Pick date',
                    style: TextStyle(
                      color: hasDate
                          ? isDark
                                ? Colors.white
                                : const Color(0xFF0F172A)
                          : isDark
                          ? const Color(0xFF475569)
                          : const Color(0xFFCBD5E1),
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
  const _DescriptionField({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller.descriptionCtrl,
      maxLines: 3,
      style: TextStyle(
        color: isDark ? Colors.white : const Color(0xFF0F172A),
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: 'Describe what this claim is for…',
        hintStyle: TextStyle(
          color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
          fontSize: 13,
        ),
        labelText: 'Description',
        labelStyle: TextStyle(
          color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
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
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Description is required';
        if (v.trim().length < 5) return 'Please provide more detail';
        return null;
      },
    );
  }
}

// ── Receipt uploader ──────────────────────────────────────────────────────────
class _ReceiptUploader extends GetView<SubmitClaimController> {
  final bool isDark;
  const _ReceiptUploader({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
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
              padding: EdgeInsets.symmetric(vertical: hasFile ? 14 : 22),
              decoration: BoxDecoration(
                color: hasFile
                    ? const Color(0xFF16A34A).withOpacity(0.06)
                    : isDark
                    ? const Color(0xFF1E293B)
                    : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: hasFile
                      ? const Color(0xFF16A34A).withOpacity(0.3)
                      : isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFCBD5E1),
                  width: 1.5,
                  style: hasFile ? BorderStyle.solid : BorderStyle.solid,
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
    });
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
          child: const Icon(
            Icons.upload_file_rounded,
            color: Color(0xFF16A34A),
            size: 22,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Tap to attach receipt',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1E293B),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'PDF, JPG, PNG — max 5 MB',
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
              color: const Color(0xFF16A34A).withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.description_rounded,
              color: Color(0xFF16A34A),
              size: 20,
            ),
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
                    color: isDark
                        ? const Color(0xFF475569)
                        : const Color(0xFF94A3B8),
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
                color: const Color(0xFFDC2626).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Color(0xFFDC2626),
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Submit bottom bar ─────────────────────────────────────────────────────────
class _SubmitBottomBar extends GetView<SubmitClaimController> {
  final bool isDark;
  const _SubmitBottomBar({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: Obx(
        () => SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: controller.isSubmitting.value ? null : controller.submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              disabledBackgroundColor: const Color(0xFF16A34A).withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: controller.isSubmitting.value
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Submit Claim',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
