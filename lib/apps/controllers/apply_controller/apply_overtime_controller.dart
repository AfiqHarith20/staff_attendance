import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staff_attendance/api/api_client.dart';
import 'package:staff_attendance/apps/models/overtime_model.dart';
import 'package:staff_attendance/apps/routes/api_routes.dart';
import 'package:staff_attendance/widgets/app_toast.dart';

import '../overtime_controller/overtime_controller.dart';

class ApplyOvertimeController extends GetxController {
  // ── Form state ──
  final selectedDate = Rxn<DateTime>();
  final startTime = Rxn<TimeOfDay>();
  final endTime = Rxn<TimeOfDay>();
  final selectedType = OvertimeType.weekday.obs;
  final reasonCtrl = TextEditingController();
  final isSubmitting = false.obs;
  final formKey = GlobalKey<FormState>();

  // ── Computed ──
  String get durationLabel {
    if (startTime.value == null || endTime.value == null) return '—';
    final startMins = startTime.value!.hour * 60 + startTime.value!.minute;
    final endMins = endTime.value!.hour * 60 + endTime.value!.minute;
    final diff = endMins - startMins;
    if (diff <= 0) return 'invalid_time'.tr;
    final h = diff ~/ 60;
    final m = diff % 60;
    return h > 0 ? (m > 0 ? '${h}h ${m}m' : '${h}h') : '${m}m';
  }

  double get estimatedHours {
    if (startTime.value == null || endTime.value == null) return 0;
    final startMins = startTime.value!.hour * 60 + startTime.value!.minute;
    final endMins = endTime.value!.hour * 60 + endTime.value!.minute;
    final diff = endMins - startMins;
    return diff > 0 ? diff / 60 : 0;
  }

  String get typeLabel => OvertimeModel.typeLabels[selectedType.value]!;
  String get rateLabel => OvertimeModel.rateLabels[selectedType.value]!;

  void pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: _datePickerTheme,
    );
    if (picked == null) return;
    selectedDate(picked);
    // Auto-set OT type based on day
    if (picked.weekday == DateTime.saturday ||
        picked.weekday == DateTime.sunday) {
      selectedType(OvertimeType.weekend);
    } else {
      selectedType(OvertimeType.weekday);
    }
  }

  void pickStartTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: startTime.value ?? const TimeOfDay(hour: 18, minute: 0),
      builder: _timePickerTheme,
    );
    if (picked == null) return;
    startTime(picked);
    if (endTime.value != null) {
      final startMins = picked.hour * 60 + picked.minute;
      final endMins = endTime.value!.hour * 60 + endTime.value!.minute;
      if (endMins <= startMins) endTime(null);
    }
  }

  void pickEndTime(BuildContext context) async {
    if (startTime.value == null) {
      AppToast.failed('select_start_time_first'.tr, 'select_start_time_first_body'.tr);
      return;
    }
    final picked = await showTimePicker(
      context: context,
      initialTime: endTime.value ??
          TimeOfDay(
            hour: (startTime.value!.hour + 2).clamp(0, 23),
            minute: startTime.value!.minute,
          ),
      builder: _timePickerTheme,
    );
    if (picked == null) return;
    final startMins = startTime.value!.hour * 60 + startTime.value!.minute;
    final endMins = picked.hour * 60 + picked.minute;
    if (endMins <= startMins) {
      AppToast.failed('invalid_time'.tr, 'end_after_start'.tr);
      return;
    }
    endTime(picked);
  }

  Widget Function(BuildContext, Widget?) get _datePickerTheme =>
      (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF185FA5),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      );

  Widget Function(BuildContext, Widget?) get _timePickerTheme =>
      (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFFD97706),
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
          timePickerTheme: const TimePickerThemeData(
            dialHandColor: Color(0xFFD97706),
          ),
        ),
        child: child!,
      );

  String _fmt2(int n) => n.toString().padLeft(2, '0');

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (selectedDate.value == null) {
      AppToast.failed('missing_ot_date'.tr, 'missing_ot_date_body'.tr);
      return;
    }
    if (startTime.value == null || endTime.value == null) {
      AppToast.failed('missing_time'.tr, 'missing_time_body'.tr);
      return;
    }
    if (estimatedHours <= 0) {
      AppToast.failed('invalid_time'.tr, 'end_after_start'.tr);
      return;
    }

    try {
      isSubmitting(true);
      await ApiClient.instance.post(
        ApiList.overtimeApply,
        data: {
          'date': selectedDate.value!.toIso8601String().split('T').first,
          'start_time': '${_fmt2(startTime.value!.hour)}:${_fmt2(startTime.value!.minute)}',
          'end_time': '${_fmt2(endTime.value!.hour)}:${_fmt2(endTime.value!.minute)}',
          'type': selectedType.value.name,
          'estimated_hours': estimatedHours,
          'reason': reasonCtrl.text.trim(),
        },
      );

      Get.back();
      AppToast.pending(
        'ot_submitted_title'.tr,
        'ot_submitted_body'.trParams({
          'dur': durationLabel,
          'date': _formatDate(selectedDate.value!),
        }),
      );

      if (Get.isRegistered<OvertimeController>()) {
        Get.find<OvertimeController>().fetchAll();
      }
    } catch (e) {
      AppToast.failed(
        'submission_failed'.tr,
        ApiClient.extractError(e, fallback: 'submission_failed'.tr),
      );
    } finally {
      isSubmitting(false);
    }
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  void onClose() {
    reasonCtrl.dispose();
    super.onClose();
  }
}
