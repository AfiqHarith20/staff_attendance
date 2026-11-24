import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staff_attendance/api/api_client.dart';
import 'package:staff_attendance/apps/routes/api_routes.dart';
import 'package:staff_attendance/widgets/app_toast.dart';

import '../../models/leave_model.dart';
import '../time_off_controller/time_off_controller.dart';

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
  // Counts Mon–Fri only, matching the server-side diffInWeekdays calculation.
  int get totalDays {
    if (startDate.value == null || endDate.value == null) return 0;
    int count = 0;
    DateTime d = startDate.value!;
    final end = endDate.value!;
    while (!d.isAfter(end)) {
      if (d.weekday <= DateTime.friday) count++;
      d = d.add(const Duration(days: 1));
    }
    return count;
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
      final response = await ApiClient.instance.get(ApiList.leaveBalance);
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
        'select_start_first'.tr,
        'select_start_first_body'.tr,
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
      AppToast.failed('missing_dates_title'.tr, 'missing_dates_body'.tr);
      return;
    }
    if (!hasEnoughBalance) {
      AppToast.failed(
        'insufficient_balance_title'.tr,
        'insufficient_balance_body'.trParams({
          'days': remainingForType.toString(),
          'type': selectedType.value.name.tr,
        }),
      );
      return;
    }

    try {
      isSubmitting(true);
      await ApiClient.instance.post(
        ApiList.leaveApply,
        data: {
          'type': selectedType.value.name,
          'start_date': startDate.value!.toIso8601String().split('T').first,
          'end_date': endDate.value!.toIso8601String().split('T').first,
          'reason': reasonCtrl.text.trim(),
        },
      );

      Get.back();
      AppToast.pending(
        'leave_applied_title'.tr,
        'leave_applied_body'.trParams({'days': totalDays.toString()}),
      );

      // Refresh the time-off list so the new application appears immediately
      if (Get.isRegistered<TimeOffController>()) {
        Get.find<TimeOffController>().fetchAll();
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

  @override
  void onClose() {
    reasonCtrl.dispose();
    super.onClose();
  }
}
