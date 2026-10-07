import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staff_attendance/api/api_client.dart';
import 'package:staff_attendance/widgets/app_toast.dart';

enum OvertimeType { weekday, weekend, publicHoliday }

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
    if (diff <= 0) return 'Invalid';
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

  // Rate multiplier per type
  double get rateMultiplier {
    switch (selectedType.value) {
      case OvertimeType.weekday:
        return 1.5;
      case OvertimeType.weekend:
        return 2.0;
      case OvertimeType.publicHoliday:
        return 3.0;
    }
  }

  static const _typeLabels = {
    OvertimeType.weekday: 'Weekday OT',
    OvertimeType.weekend: 'Weekend OT',
    OvertimeType.publicHoliday: 'Public Holiday OT',
  };

  static const _typeRateLabels = {
    OvertimeType.weekday: '1.5×',
    OvertimeType.weekend: '2.0×',
    OvertimeType.publicHoliday: '3.0×',
  };

  String get typeLabel => _typeLabels[selectedType.value]!;
  String get rateLabel => _typeRateLabels[selectedType.value]!;

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
    // Clear end time if it's before the new start
    if (endTime.value != null) {
      final startMins = picked.hour * 60 + picked.minute;
      final endMins = endTime.value!.hour * 60 + endTime.value!.minute;
      if (endMins <= startMins) endTime(null);
    }
  }

  void pickEndTime(BuildContext context) async {
    if (startTime.value == null) {
      AppToast.failed(
        'Select start time first',
        'Please choose the OT start time first.',
      );
      return;
    }
    final picked = await showTimePicker(
      context: context,
      initialTime:
          endTime.value ??
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
      AppToast.failed('Invalid time', 'End time must be after start time');
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

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (selectedDate.value == null) {
      AppToast.failed('Missing date', 'Please select the OT date');
      return;
    }
    if (startTime.value == null || endTime.value == null) {
      AppToast.failed('Missing time', 'Please select start and end time');
      return;
    }
    if (estimatedHours <= 0) {
      AppToast.failed(
        'Invalid time range',
        'End time must be after start time',
      );
      return;
    }

    try {
      isSubmitting(true);
      await ApiClient.instance.post(
        '/overtime/apply',
        data: {
          'date': selectedDate.value!.toIso8601String().split('T').first,
          'start_time':
              '${startTime.value!.hour.toString().padLeft(2, '0')}:${startTime.value!.minute.toString().padLeft(2, '0')}',
          'end_time':
              '${endTime.value!.hour.toString().padLeft(2, '0')}:${endTime.value!.minute.toString().padLeft(2, '0')}',
          'estimated_hours': estimatedHours.toStringAsFixed(2),
          'type': selectedType.value.name,
          'reason': reasonCtrl.text.trim(),
        },
      );

      Get.back();
      AppToast.pending(
        'OT request submitted',
        '$durationLabel on ${_formatDate(selectedDate.value!)} — pending approval',
      );
    } catch (e) {
      AppToast.failed('Submission failed', e.toString());
    } finally {
      isSubmitting(false);
    }
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

  @override
  void onClose() {
    reasonCtrl.dispose();
    super.onClose();
  }
}
