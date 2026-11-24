import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staff_attendance/api/api_client.dart';
import 'package:staff_attendance/apps/routes/api_routes.dart';
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
        ApiList.forgotPassword,
        data: {'email': emailController.text.trim()},
      );
      // Response is always 200 regardless of whether the email is registered
      // (privacy — prevents account enumeration).
      AppToast.success(
        'forgot_password'.tr,
        'reset_link_sent'.tr,
      );
      Get.back();
    } on DioException catch (e) {
      AppToast.failed(
        'forgot_password'.tr,
        ApiClient.extractError(e, fallback: 'submission_failed'.tr),
      );
    } catch (_) {
      AppToast.failed('forgot_password'.tr, 'submission_failed'.tr);
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
