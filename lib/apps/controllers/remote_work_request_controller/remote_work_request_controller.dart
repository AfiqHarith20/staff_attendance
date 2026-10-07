import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staff_attendance/api/api_client.dart';
import 'package:staff_attendance/widgets/app_toast.dart';

class RemoteWorkRequestController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final startDate = DateTime.now().obs;
  final endDate = DateTime.now().obs;
  final workLocation = 'Home'.obs;
  final reasonController = TextEditingController();
  final isSubmitting = false.obs;

  final locations = const ['Home', 'Client site', 'Co-working space', 'Other'];

  Future<void> pickStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate.value,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      startDate(picked);
      if (endDate.value.isBefore(picked)) endDate(picked);
    }
  }

  Future<void> pickEndDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: endDate.value,
      firstDate: startDate.value,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) endDate(picked);
  }

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    try {
      isSubmitting(true);
      await ApiClient.instance.post(
        '/remote-work-requests',
        data: {
          'start_date': startDate.value.toIso8601String(),
          'end_date': endDate.value.toIso8601String(),
          'location': workLocation.value,
          'reason': reasonController.text.trim(),
        },
      );
      AppToast.pending(
        'Request submitted',
        'Your remote work request has been sent for approval.',
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
