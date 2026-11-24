import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/training_records_controller/training_records_controller.dart';
import 'package:staff_attendance/apps/models/training_record_model.dart';
import 'package:staff_attendance/apps/themes/app_colors.dart';
import 'package:staff_attendance/widgets/app_page_widgets.dart';

const _typeColors = <String, Color>{
  'external': Color(0xFF2563EB),
  'internal': Color(0xFF7C3AED),
  'online': Color(0xFF0891B2),
  'conference': Color(0xFFD97706),
  'certification': Color(0xFF16A34A),
};

class TrainingRecordsScreen extends GetView<TrainingRecordsController> {
  const TrainingRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: bg,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showLogSheet(context, isDark),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Log Training', style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5),
            );
          }
          if (controller.hasError.value) {
            return _ErrorRetry(isDark: isDark, onRetry: controller.fetchRecords);
          }
          return RefreshIndicator(
            onRefresh: controller.fetchRecords,
            color: AppColors.primary,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: [
                const AppPageHeader(title: 'Training Records'),
                const SizedBox(height: 12),
                if (controller.records.isEmpty)
                  _Empty(isDark: isDark)
                else
                  ...controller.records.map((r) => _RecordCard(record: r, isDark: isDark)),
              ],
            ),
          );
        }),
      ),
    );
  }

  void _showLogSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LogTrainingSheet(isDark: isDark),
    );
  }
}

class _RecordCard extends StatelessWidget {
  final TrainingRecordModel record;
  final bool isDark;
  const _RecordCard({required this.record, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final card = isDark ? const Color(0xFF1E293B) : Colors.white;
    final border = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final text = isDark ? Colors.white : const Color(0xFF0F172A);
    final muted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final accent = _typeColors[record.type] ?? AppColors.primary;

    Color statusColor;
    String statusLabel;
    if (record.isExpired) {
      statusColor = const Color(0xFFDC2626);
      statusLabel = 'Expired';
    } else if (record.isExpiringSoon) {
      statusColor = const Color(0xFFF59E0B);
      statusLabel = 'Expiring soon';
    } else if (record.verifiedAt != null) {
      statusColor = const Color(0xFF16A34A);
      statusLabel = 'Verified';
    } else {
      statusColor = const Color(0xFF94A3B8);
      statusLabel = 'Pending verification';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 6,
                height: 40,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(record.title,
                        style: TextStyle(
                          color: text, fontSize: 14, fontWeight: FontWeight.w700,
                        )),
                    if (record.provider != null)
                      Text(record.provider!,
                          style: TextStyle(color: muted, fontSize: 12)),
                  ],
                ),
              ),
              AppStatusBadge(label: statusLabel, color: statusColor),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _Chip(label: record.typeLabel, color: accent),
              _Chip(label: record.fundedByLabel, color: muted),
              _Chip(label: 'Completed ${record.completedOn}', color: muted),
              if (record.expiryDate != null)
                _Chip(label: 'Expires ${record.expiryDate}', color: record.isExpired ? const Color(0xFFDC2626) : muted),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}

class _LogTrainingSheet extends GetView<TrainingRecordsController> {
  final bool isDark;
  const _LogTrainingSheet({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final text = isDark ? Colors.white : const Color(0xFF0F172A);
    final muted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scroll) => Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.fromLTRB(
          16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Form(
          key: controller.formKey,
          child: ListView(
            controller: scroll,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: muted.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Log Training',
                  style: TextStyle(color: text, fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              _Field(
                controller: controller.titleController,
                label: 'Training title *',
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
              ),
              const SizedBox(height: 12),
              _Field(
                controller: controller.providerController,
                label: 'Provider / institution',
              ),
              const SizedBox(height: 12),
              Obx(() => _DropdownRow<String>(
                    label: 'Type',
                    value: controller.selectedType.value,
                    items: TrainingRecordsController.types,
                    onChanged: controller.selectedType,
                    isDark: isDark,
                  )),
              const SizedBox(height: 12),
              Obx(() => _DropdownRow<String>(
                    label: 'Funded by',
                    value: controller.selectedFundedBy.value,
                    items: TrainingRecordsController.fundedByOptions,
                    onChanged: controller.selectedFundedBy,
                    isDark: isDark,
                  )),
              const SizedBox(height: 12),
              Obx(() => _DatePickerRow(
                    label: 'Completion date *',
                    value: controller.completedOn.value,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: controller.completedOn.value ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) controller.completedOn.value = picked;
                    },
                    muted: muted,
                    text: text,
                  )),
              const SizedBox(height: 12),
              Obx(() => _DatePickerRow(
                    label: 'Expiry date (optional)',
                    value: controller.expiryDate.value,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: controller.expiryDate.value ??
                            DateTime.now().add(const Duration(days: 365)),
                        firstDate: controller.completedOn.value ?? DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) controller.expiryDate.value = picked;
                    },
                    muted: muted,
                    text: text,
                  )),
              const SizedBox(height: 12),
              _Field(
                controller: controller.costController,
                label: 'Cost (RM, optional)',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              _Field(
                controller: controller.notesController,
                label: 'Notes (optional)',
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              Obx(() => FilledButton(
                    onPressed: controller.isSubmitting.value ? null : controller.submitRecord,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: controller.isSubmitting.value
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2,
                            ),
                          )
                        : const Text('Submit Record',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;

  const _Field({
    required this.controller,
    required this.label,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}

class _DropdownRow<T> extends StatelessWidget {
  final String label;
  final T value;
  final Map<String, String> items;
  final void Function(String) onChanged;
  final bool isDark;

  const _DropdownRow({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value as String,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      items: items.entries
          .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
          .toList(),
      onChanged: (v) { if (v != null) onChanged(v); },
    );
  }
}

class _DatePickerRow extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  final Color muted;
  final Color text;

  const _DatePickerRow({
    required this.label,
    required this.value,
    required this.onTap,
    required this.muted,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          suffixIcon: const Icon(Icons.calendar_today_rounded, size: 18),
        ),
        child: Text(
          value != null
              ? '${value!.year}-${value!.month.toString().padLeft(2, '0')}-${value!.day.toString().padLeft(2, '0')}'
              : 'Select date',
          style: TextStyle(color: value != null ? text : muted, fontSize: 14),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final bool isDark;
  const _Empty({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 28),
          child: Column(
            children: [
              Icon(Icons.school_rounded,
                  size: 40, color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
              const SizedBox(height: 12),
              Text(
                'No training records yet',
                style: TextStyle(
                  color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tap + to log a completed training.',
                style: TextStyle(
                  color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  final bool isDark;
  final VoidCallback onRetry;
  const _ErrorRetry({required this.isDark, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_rounded,
              size: 48, color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
          const SizedBox(height: 12),
          Text('Could not load training records',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                fontSize: 15, fontWeight: FontWeight.w700,
              )),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Retry'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}
