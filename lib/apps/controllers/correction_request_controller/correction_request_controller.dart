import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staff_attendance/api/api_client.dart';
import 'package:staff_attendance/widgets/app_toast.dart';

class CorrectionRequestController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final selectedDate = DateTime.now().obs;
  final requestType = 'Forgot check-out'.obs;
  final checkInController = TextEditingController();
  final checkOutController = TextEditingController();
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
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) selectedDate(picked);
  }

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    try {
      isSubmitting(true);
      await ApiClient.instance.post(
        '/attendance/correction-requests',
        data: {
          'date': selectedDate.value.toIso8601String(),
          'type': requestType.value,
          'check_in': checkInController.text.trim(),
          'check_out': checkOutController.text.trim(),
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
    checkInController.dispose();
    checkOutController.dispose();
    reasonController.dispose();
    super.onClose();
  }
}
