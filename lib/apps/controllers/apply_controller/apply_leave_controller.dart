import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staff_attendance/api/api_client.dart';
import 'package:staff_attendance/widgets/app_toast.dart';

import '../../models/leave_model.dart';

class ApplyLeaveController extends GetxController {
  // ── Form state ──
  final selectedType = LeaveType.annual.obs;
  final startDate = Rxn<DateTime>();
  final endDate = Rxn<DateTime>();
  final reasonCtrl = TextEditingController();
  final isSubmitting = false.obs;
  final formKey = GlobalKey<FormState>();

  // ── Balance (fetched to show remaining days) ──
  final balance = LeaveBalance.defaults().obs;
  final isLoadingBal = false.obs;

  // ── Computed ──
  int get totalDays {
    if (startDate.value == null || endDate.value == null) return 0;
    return endDate.value!.difference(startDate.value!).inDays + 1;
  }

  int get remainingForType {
    final b = balance.value;
    switch (selectedType.value) {
      case LeaveType.annual:
        return b.annualLeft;
      case LeaveType.medical:
        return b.medicalLeft;
      case LeaveType.emergency:
        return b.emergencyLeft;
      default:
        return 99;
    }
  }

  bool get hasEnoughBalance =>
      selectedType.value == LeaveType.unpaid ||
      selectedType.value == LeaveType.other ||
      totalDays <= remainingForType;

  @override
  void onInit() {
    super.onInit();
    _fetchBalance();
  }

  Future<void> _fetchBalance() async {
    try {
      isLoadingBal(true);
      final response = await ApiClient.instance.get('/leave/balance');
      balance(
        LeaveBalance.fromJson(response.data['data'] as Map<String, dynamic>),
      );
    } catch (_) {
    } finally {
      isLoadingBal(false);
    }
  }

  void pickStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate.value ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: _datePickerTheme,
    );
    if (picked == null) return;
    startDate(picked);
    // Reset end date if before start
    if (endDate.value != null && endDate.value!.isBefore(picked)) {
      endDate(picked);
    }
  }

  void pickEndDate(BuildContext context) async {
    if (startDate.value == null) {
      AppToast.failed(
        'Select start date first',
        'Please choose the leave start date first.',
      );
      return;
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: endDate.value ?? startDate.value!,
      firstDate: startDate.value!,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: _datePickerTheme,
    );
    if (picked != null) endDate(picked);
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

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (startDate.value == null || endDate.value == null) {
      AppToast.failed('Missing dates', 'Please select start and end date');
      return;
    }
    if (!hasEnoughBalance) {
      AppToast.failed(
        'Insufficient balance',
        'You only have $remainingForType day(s) left for ${selectedType.value.name} leave',
      );
      return;
    }

    try {
      isSubmitting(true);
      await ApiClient.instance.post(
        '/leave/apply',
        data: {
          'type': selectedType.value.name,
          'start_date': startDate.value!.toIso8601String().split('T').first,
          'end_date': endDate.value!.toIso8601String().split('T').first,
          'total_days': totalDays,
          'reason': reasonCtrl.text.trim(),
        },
      );

      Get.back();
      AppToast.pending(
        'Leave applied',
        '$totalDays day(s) submitted for approval',
      );
    } catch (e) {
      AppToast.failed('Submission failed', e.toString());
    } finally {
      isSubmitting(false);
    }
  }

  @override
  void onClose() {
    reasonCtrl.dispose();
    super.onClose();
  }
}
