import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staff_attendance/api/api_client.dart';
import 'package:staff_attendance/apps/models/shift_swap_model.dart';
import 'package:staff_attendance/apps/routes/api_routes.dart';
import 'package:staff_attendance/widgets/app_toast.dart';

class ShiftSwapController extends GetxController {
  final swaps = <ShiftSwapModel>[].obs;
  final isLoading = false.obs;
  final hasError = false.obs;
  final isSubmitting = false.obs;
  final isCancelling = false.obs;

  // ── Apply form state ────────────────────────────────────────────────────────
  final formKey = GlobalKey<FormState>();
  final reasonController = TextEditingController();
  final selectedShiftId = Rxn<int>();
  final targetIdController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchSwaps();
  }

  Future<void> fetchSwaps() async {
    try {
      isLoading(true);
      hasError(false);
      final res = await ApiClient.instance.get(ApiList.shiftSwaps);
      final list = (res.data['data'] as List<dynamic>? ?? [])
          .map((e) => ShiftSwapModel.fromJson(e as Map<String, dynamic>))
          .toList();
      swaps.assignAll(list);
    } on DioException catch (e) {
      hasError(true);
      AppToast.failed('Failed to load', ApiClient.extractError(e, fallback: 'Could not load shift swaps.'));
    } catch (_) {
      hasError(true);
    } finally {
      isLoading(false);
    }
  }

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (selectedShiftId.value == null) {
      AppToast.failed('Missing shift', 'Please select the shift you want to swap.');
      return;
    }
    final targetId = int.tryParse(targetIdController.text.trim());
    if (targetId == null) {
      AppToast.failed('Invalid target', 'Please enter a valid colleague ID.');
      return;
    }
    try {
      isSubmitting(true);
      await ApiClient.instance.post(ApiList.shiftSwaps, data: {
        'requester_shift_id': selectedShiftId.value,
        'target_id': targetId,
        'reason': reasonController.text.trim(),
      });
      Get.back();
      AppToast.pending('Swap requested', 'Your shift swap request has been submitted.');
      _resetForm();
      await fetchSwaps();
    } on DioException catch (e) {
      AppToast.failed('Request failed', ApiClient.extractError(e, fallback: 'Could not submit swap request.'));
    } finally {
      isSubmitting(false);
    }
  }

  Future<void> cancel(ShiftSwapModel swap) async {
    try {
      isCancelling(true);
      await ApiClient.instance.delete(ApiList.shiftSwapCancel('${swap.id}'));
      AppToast.success('Cancelled', 'Shift swap request cancelled.');
      await fetchSwaps();
    } on DioException catch (e) {
      AppToast.failed('Failed', ApiClient.extractError(e, fallback: 'Could not cancel request.'));
    } finally {
      isCancelling(false);
    }
  }

  void _resetForm() {
    reasonController.clear();
    targetIdController.clear();
    selectedShiftId.value = null;
  }

  @override
  void onClose() {
    reasonController.dispose();
    targetIdController.dispose();
    super.onClose();
  }
}
