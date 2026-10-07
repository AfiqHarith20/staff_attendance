import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staff_attendance/api/api_client.dart';
import 'package:staff_attendance/widgets/app_toast.dart';

class ForgotPasswordController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final isSubmitting = false.obs;

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    try {
      isSubmitting(true);
      await ApiClient.instance.post(
        '/auth/forgot-password',
        data: {'email': emailController.text.trim()},
      );
      AppToast.success(
        'Reset link sent',
        'Please check your email for the password reset instructions.',
      );
      Get.back();
    } finally {
      isSubmitting(false);
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
