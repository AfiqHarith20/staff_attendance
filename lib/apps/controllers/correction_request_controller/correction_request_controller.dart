import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staff_attendance/api/api_client.dart';
import 'package:staff_attendance/apps/routes/api_routes.dart';
import 'package:staff_attendance/widgets/app_toast.dart';

class CorrectionRequestController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final selectedDate = DateTime.now().obs;
  final requestType = 'Forgot check-out'.obs;
  final selectedCheckIn = Rxn<TimeOfDay>();
  final selectedCheckOut = Rxn<TimeOfDay>();
  final reasonController = TextEditingController();
  final isSubmitting = false.obs;

  final requestTypes = const [
    'Forgot check-in',
    'Forgot check-out',
    'Wrong location',
    'Incorrect time',
    'Other adjustment',
  ];

  Future<void> pickDate(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: isDark
              ? const ColorScheme.dark(
                  primary: Color(0xFF4A90D9),
                  onPrimary: Colors.white,
                  secondary: Color(0xFF4A90D9),
                  onSecondary: Colors.white,
                  surface: Color(0xFF182338),
                  onSurface: Colors.white,
                )
              : const ColorScheme.light(
                  primary: Color(0xFF185FA5),
                  onPrimary: Colors.white,
                  secondary: Color(0xFF185FA5),
                  onSecondary: Colors.white,
                  surface: Colors.white,
                  onSurface: Color(0xFF1E293B),
                ),
        ),
        child: child!,
      ),
    );
    if (picked != null) selectedDate(picked);
  }

  Widget _timePickerTheme(BuildContext context, Widget? child) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: isDark
            ? const ColorScheme.dark(
                primary: Color(0xFF4A90D9),
                onPrimary: Colors.white,
                secondary: Color(0xFF4A90D9),
                onSecondary: Colors.white,
                surface: Color(0xFF182338),
                onSurface: Colors.white,
                surfaceContainerHighest: Color(0xFF23314F),
                onSurfaceVariant: Color(0xFF8FA3BF),
                outline: Color(0xFF334155),
              )
            : const ColorScheme.light(
                primary: Color(0xFF185FA5),
                onPrimary: Colors.white,
                secondary: Color(0xFF185FA5),
                onSecondary: Colors.white,
                surface: Colors.white,
                onSurface: Color(0xFF1E293B),
                surfaceContainerHighest: Color(0xFFE6F1FB),
                onSurfaceVariant: Color(0xFF64748B),
                outline: Color(0xFFCBD5E1),
              ),
        timePickerTheme: TimePickerThemeData(
          backgroundColor: isDark ? const Color(0xFF182338) : Colors.white,
          dialBackgroundColor: isDark ? const Color(0xFF23314F) : const Color(0xFFEFF6FF),
          dialHandColor: const Color(0xFF185FA5),
          dialTextColor: WidgetStateColor.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return Colors.white;
            return isDark ? Colors.white : const Color(0xFF1E293B);
          }),
          hourMinuteShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          hourMinuteColor: WidgetStateColor.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const Color(0xFF185FA5);
            }
            return isDark ? const Color(0xFF23314F) : const Color(0xFFEFF6FF);
          }),
          hourMinuteTextColor: WidgetStateColor.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return Colors.white;
            return isDark ? Colors.white : const Color(0xFF1E293B);
          }),
          dayPeriodShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: Color(0xFF185FA5), width: 1.5),
          ),
          dayPeriodColor: WidgetStateColor.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const Color(0xFF185FA5);
            }
            return Colors.transparent;
          }),
          dayPeriodTextColor: WidgetStateColor.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return Colors.white;
            return isDark ? const Color(0xFF8FA3BF) : const Color(0xFF185FA5);
          }),
          dayPeriodBorderSide: const BorderSide(color: Color(0xFF185FA5), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          entryModeIconColor: isDark ? const Color(0xFF8FA3BF) : const Color(0xFF64748B),
          cancelButtonStyle: TextButton.styleFrom(
            foregroundColor: isDark ? const Color(0xFF8FA3BF) : const Color(0xFF64748B),
          ),
          confirmButtonStyle: TextButton.styleFrom(
            foregroundColor: const Color(0xFF185FA5),
          ),
        ),
      ),
      child: child!,
    );
  }

  Future<void> pickCheckInTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedCheckIn.value ?? const TimeOfDay(hour: 9, minute: 0),
      initialEntryMode: TimePickerEntryMode.dial,
      builder: _timePickerTheme,
    );
    if (picked != null) selectedCheckIn(picked);
  }

  Future<void> pickCheckOutTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedCheckOut.value ?? const TimeOfDay(hour: 18, minute: 0),
      initialEntryMode: TimePickerEntryMode.dial,
      builder: _timePickerTheme,
    );
    if (picked != null) selectedCheckOut(picked);
  }

  // Formats TimeOfDay as "HH:mm" for the API (24-hour).
  static String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    try {
      isSubmitting(true);
      final checkIn = selectedCheckIn.value;
      final checkOut = selectedCheckOut.value;
      await ApiClient.instance.post(
        ApiList.correctionRequests,
        data: {
          'date': selectedDate.value.toIso8601String().split('T').first,
          'type': requestType.value,
          if (checkIn != null) 'check_in': _fmt(checkIn),
          if (checkOut != null) 'check_out': _fmt(checkOut),
          'reason': reasonController.text.trim(),
        },
      );
      AppToast.pending(
        'Request submitted',
        'Your attendance correction has been sent for review.',
      );
      Get.back(result: true);
    } finally {
      isSubmitting(false);
    }
  }

  @override
  void onClose() {
    reasonController.dispose();
    super.onClose();
  }
}
