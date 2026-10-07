import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staff_attendance/api/api_client.dart';
import 'package:staff_attendance/apps/routes/routes.dart';
import 'package:staff_attendance/widgets/app_toast.dart';

class HelpSupportController extends GetxController {
  final issueController = TextEditingController();
  final isSubmitting = false.obs;

  final faqs = const [
    {
      'title': 'What should I do if I forgot to check out?',
      'body':
          'Submit a correction request with the correct checkout time and reason.',
    },
    {
      'title': 'How late is considered late?',
      'body':
          'Any check-in after the assigned shift start time may be flagged.',
    },
    {
      'title': 'Where do I upload MC documents?',
      'body':
          'Use My Documents to upload medical certificates and supporting files.',
    },
  ];

  Future<void> reportIssue() async {
    final text = issueController.text.trim();
    if (text.isEmpty) {
      AppToast.failed('Report issue', 'Please describe the issue first.');
      return;
    }
    try {
      isSubmitting(true);
      await ApiClient.instance.post('/support/issues', data: {'message': text});
      issueController.clear();
      AppToast.success(
        'Issue reported',
        'HR support has received your message.',
      );
    } finally {
      isSubmitting(false);
    }
  }

  void openAttendanceRules() => Get.toNamed(Routes.attendanceHistory);
  void openClaimRules() => Get.toNamed(Routes.submitClaim);
  void openLeavePolicy() => Get.toNamed(Routes.companyPolicy);

  @override
  void onClose() {
    issueController.dispose();
    super.onClose();
  }
}
