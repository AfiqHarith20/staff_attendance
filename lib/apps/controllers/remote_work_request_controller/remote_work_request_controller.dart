import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staff_attendance/api/api_client.dart';
import 'package:staff_attendance/apps/routes/api_routes.dart';
import 'package:staff_attendance/widgets/app_toast.dart';

import '../remote_work_controller/remote_work_controller.dart';

class RemoteWorkRequestController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final startDate = Rxn<DateTime>();
  final endDate = Rxn<DateTime>();
  final workLocation = 'Home'.obs;
  final reasonController = TextEditingController();
  final isSubmitting = false.obs;

  static const locations = ['Home', 'Client site', 'Co-working space', 'Other'];

  Future<void> pickStartDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate.value ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: _datePickerTheme,
    );
    if (picked != null) {
      startDate(picked);
      if (endDate.value != null && endDate.value!.isBefore(picked)) {
        endDate(picked);
      }
    }
  }

  Future<void> pickEndDate(BuildContext context) async {
    final from = startDate.value ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: endDate.value ?? from,
      firstDate: from,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: _datePickerTheme,
    );
    if (picked != null) endDate(picked);
  }

  Widget Function(BuildContext, Widget?) get _datePickerTheme =>
      (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF7F77DD),
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
    try {
      isSubmitting(true);
      await ApiClient.instance.post(
        ApiList.remoteWorkRequests,
        data: {
          'start_date': startDate.value!.toIso8601String().split('T').first,
          'end_date': endDate.value!.toIso8601String().split('T').first,
          'location': workLocation.value,
          'reason': reasonController.text.trim(),
        },
      );

      Get.back();
      AppToast.pending(
        'remote_submitted_title'.tr,
        'remote_submitted_body'.tr,
      );

      if (Get.isRegistered<RemoteWorkController>()) {
        Get.find<RemoteWorkController>().fetchAll();
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
    reasonController.dispose();
    super.onClose();
  }
}
