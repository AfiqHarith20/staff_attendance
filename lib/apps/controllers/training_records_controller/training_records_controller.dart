import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staff_attendance/api/api_client.dart';
import 'package:staff_attendance/apps/models/training_record_model.dart';
import 'package:staff_attendance/apps/routes/api_routes.dart';
import 'package:staff_attendance/widgets/app_toast.dart';

class TrainingRecordsController extends GetxController {
  final records = <TrainingRecordModel>[].obs;
  final isLoading = false.obs;
  final hasError = false.obs;
  final isSubmitting = false.obs;

  // ── Log form state ──────────────────────────────────────────────────────────
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final providerController = TextEditingController();
  final notesController = TextEditingController();
  final costController = TextEditingController();
  final selectedType = 'external'.obs;
  final selectedFundedBy = 'self'.obs;
  final completedOn = Rxn<DateTime>();
  final expiryDate = Rxn<DateTime>();

  static const Map<String, String> types = {
    'external': 'External Course',
    'internal': 'Internal Training',
    'online': 'Online / E-Learning',
    'conference': 'Conference / Seminar',
    'certification': 'Professional Certification',
  };

  static const Map<String, String> fundedByOptions = {
    'self': 'Self-funded',
    'company': 'Company-funded',
    'hrd_corp': 'HRD Corp (SBL-Khas)',
  };

  @override
  void onInit() {
    super.onInit();
    fetchRecords();
  }

  Future<void> fetchRecords() async {
    try {
      isLoading(true);
      hasError(false);
      final res = await ApiClient.instance.get(ApiList.training);
      final list = (res.data['data'] as List<dynamic>? ?? [])
          .map((e) => TrainingRecordModel.fromJson(e as Map<String, dynamic>))
          .toList();
      records.assignAll(list);
    } on DioException catch (e) {
      hasError(true);
      AppToast.failed('Failed to load', ApiClient.extractError(e, fallback: 'Could not load training records.'));
    } catch (_) {
      hasError(true);
    } finally {
      isLoading(false);
    }
  }

  Future<void> submitRecord() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (completedOn.value == null) {
      AppToast.failed('Missing date', 'Please select the completion date.');
      return;
    }
    try {
      isSubmitting(true);
      final payload = <String, dynamic>{
        'title': titleController.text.trim(),
        'type': selectedType.value,
        'funded_by': selectedFundedBy.value,
        'completed_on': completedOn.value!.toIso8601String().split('T').first,
      };
      if (providerController.text.trim().isNotEmpty) {
        payload['provider'] = providerController.text.trim();
      }
      if (expiryDate.value != null) {
        payload['expiry_date'] = expiryDate.value!.toIso8601String().split('T').first;
      }
      if (costController.text.trim().isNotEmpty) {
        payload['cost'] = costController.text.trim();
      }
      if (notesController.text.trim().isNotEmpty) {
        payload['notes'] = notesController.text.trim();
      }
      await ApiClient.instance.post(ApiList.training, data: payload);
      Get.back();
      AppToast.success('Training record logged', 'Your record has been submitted for verification.');
      _resetForm();
      await fetchRecords();
    } on DioException catch (e) {
      AppToast.failed('Submission failed', ApiClient.extractError(e, fallback: 'Could not log training record.'));
    } finally {
      isSubmitting(false);
    }
  }

  void _resetForm() {
    titleController.clear();
    providerController.clear();
    notesController.clear();
    costController.clear();
    selectedType('external');
    selectedFundedBy('self');
    completedOn.value = null;
    expiryDate.value = null;
  }

  @override
  void onClose() {
    titleController.dispose();
    providerController.dispose();
    notesController.dispose();
    costController.dispose();
    super.onClose();
  }
}
