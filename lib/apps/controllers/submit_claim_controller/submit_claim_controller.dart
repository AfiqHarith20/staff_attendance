import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:permission_handler/permission_handler.dart';
import 'package:staff_attendance/api/api_client.dart';
import 'package:staff_attendance/widgets/app_toast.dart';

import '../../../apps/models/claim_model.dart';

class SubmitClaimController extends GetxController {
  final selectedType = ClaimType.medical.obs;
  final claimDate = Rxn<DateTime>();
  final amountCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  final isSubmitting = false.obs;
  final formKey = GlobalKey<FormState>();

  // Receipt file
  final receiptFile = Rxn<File>();
  final receiptName = ''.obs;
  final receiptSizeKB = 0.obs;
  final isPickingFile = false.obs;
  final fileError = ''.obs;

  void pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: claimDate.value ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 90)),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF16A34A),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) claimDate(picked);
  }

  Future<void> pickReceipt() async {
    fileError('');
    isPickingFile(true);

    try {
      final status = await Permission.storage.request();
      if (status.isPermanentlyDenied) {
        openAppSettings();
        return;
      }

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );
      if (result == null || result.files.isEmpty) return;

      final picked = result.files.first;
      if (picked.path == null) return;

      // 5 MB limit
      if (picked.size > 5 * 1024 * 1024) {
        fileError('File too large. Max 5 MB.');
        return;
      }

      receiptFile(File(picked.path!));
      receiptName(picked.name);
      receiptSizeKB((picked.size / 1024).ceil());
    } finally {
      isPickingFile(false);
    }
  }

  void removeReceipt() {
    receiptFile(null);
    receiptName('');
    receiptSizeKB(0);
    fileError('');
  }

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (claimDate.value == null) {
      AppToast.failed('Missing date', 'Please select the claim date');
      return;
    }

    try {
      isSubmitting(true);

      final formData = FormData.fromMap({
        'type': selectedType.value.name,
        'amount': amountCtrl.text.trim(),
        'description': descriptionCtrl.text.trim(),
        'claim_date': claimDate.value!.toIso8601String().split('T').first,
        if (receiptFile.value != null)
          'receipt': await MultipartFile.fromFile(
            receiptFile.value!.path,
            filename: receiptName.value,
          ),
      });

      await ApiClient.instance.post(
        '/claims/submit',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
          sendTimeout: const Duration(seconds: 60),
        ),
      );

      Get.back();
      AppToast.pending(
        'Claim submitted',
        '${_typeLabel(selectedType.value)} claim of ${_formatAmount()} sent for approval',
      );
    } on DioException catch (e) {
      AppToast.failed(
        'Submission failed',
        e.response?.data['message'] as String? ?? 'Please try again',
      );
    } finally {
      isSubmitting(false);
    }
  }

  String _typeLabel(ClaimType t) => ClaimModel.typeLabels[t]!;
  String _formatAmount() {
    final a = double.tryParse(amountCtrl.text) ?? 0;
    return 'RM ${a.toStringAsFixed(2)}';
  }

  @override
  void onClose() {
    amountCtrl.dispose();
    descriptionCtrl.dispose();
    super.onClose();
  }
}
