import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:permission_handler/permission_handler.dart';
import 'package:staff_attendance/api/api_client.dart';
import 'package:staff_attendance/apps/controllers/claims_controller/claims_controller.dart';
import 'package:staff_attendance/apps/models/claim_model.dart';
import 'package:staff_attendance/apps/routes/api_routes.dart';
import 'package:staff_attendance/widgets/app_toast.dart';

class SubmitClaimController extends GetxController {
  // ── Category / type selection ──────────────────────────────────────────────
  final selectedCategory = ClaimCategory.general.obs;
  final selectedGeneralType = ClaimType.medical.obs;
  final selectedTravelType = ClaimType.mileage.obs;

  // ── General fields ─────────────────────────────────────────────────────────
  final amountCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();

  // ── Travel / mileage fields ────────────────────────────────────────────────
  final selectedVehicle = 'car'.obs;
  final distanceCtrl = TextEditingController();
  final tollCtrl = TextEditingController();
  final parkingCtrl = TextEditingController();
  final miscCtrl = TextEditingController();
  final travelFromCtrl = TextEditingController();
  final travelToCtrl = TextEditingController();
  final travelPurposeCtrl = TextEditingController();
  final previewedAmount = Rxn<double>();
  final isPreviewing = false.obs;

  // ── Common ─────────────────────────────────────────────────────────────────
  final claimDate = Rxn<DateTime>();
  final isSubmitting = false.obs;
  final formKey = GlobalKey<FormState>();

  // ── Receipt ────────────────────────────────────────────────────────────────
  final receiptFile = Rxn<File>();
  final receiptName = ''.obs;
  final receiptSizeKB = 0.obs;
  final isPickingFile = false.obs;
  final fileError = ''.obs;

  ClaimType get effectiveType => selectedCategory.value == ClaimCategory.general
      ? selectedGeneralType.value
      : selectedTravelType.value;

  bool get isMileage =>
      selectedCategory.value == ClaimCategory.travel &&
      selectedTravelType.value == ClaimType.mileage;

  void switchCategory(ClaimCategory cat) {
    selectedCategory(cat);
    previewedAmount(null);
    claimDate(null);
    amountCtrl.clear();
    descriptionCtrl.clear();
    distanceCtrl.clear();
    tollCtrl.clear();
    parkingCtrl.clear();
    miscCtrl.clear();
    travelFromCtrl.clear();
    travelToCtrl.clear();
    travelPurposeCtrl.clear();
    removeReceipt();
  }

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

  Future<void> previewMileage() async {
    final dist = double.tryParse(distanceCtrl.text);
    if (dist == null || dist <= 0) {
      AppToast.failed('missing_distance'.tr, 'missing_distance_body'.tr);
      return;
    }
    isPreviewing(true);
    try {
      final payload = <String, dynamic>{
        'vehicle_type': selectedVehicle.value,
        'distance_km': dist,
      };
      final tollVal = double.tryParse(tollCtrl.text);
      final parkVal = double.tryParse(parkingCtrl.text);
      final miscVal = double.tryParse(miscCtrl.text);
      if (tollVal != null && tollVal > 0) payload['toll_amount'] = tollVal;
      if (parkVal != null && parkVal > 0) payload['parking_amount'] = parkVal;
      if (miscVal != null && miscVal > 0) payload['miscellaneous_amount'] = miscVal;

      final res = await ApiClient.instance.post(
        ApiList.claimsCalculateMileage,
        data: payload,
      );
      final d = res.data['data'] as Map<String, dynamic>;
      final amt = (d['total_amount'] ?? d['amount'] ?? d['mileage_amount']) as num?;
      if (amt != null) previewedAmount(amt.toDouble());
    } catch (e) {
      AppToast.failed(
        'preview_failed'.tr,
        ApiClient.extractError(e, fallback: 'submission_failed'.tr),
      );
    } finally {
      isPreviewing(false);
    }
  }

  Future<void> pickReceipt() async {
    fileError('');
    isPickingFile(true);
    try {
      // Permission.photos maps to READ_MEDIA_IMAGES on Android 13+,
      // READ_EXTERNAL_STORAGE on older. Storage permission is deprecated on API 33+.
      final status = await Permission.photos.request();
      if (status.isPermanentlyDenied) {
        openAppSettings();
        return;
      }
      final picked = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx', 'xls', 'xlsx'],
      );
      if (picked == null || picked.path == null) return;
      if ((picked.lengthSync() ?? 0) > 5 * 1024 * 1024) {
        fileError('file_too_large'.tr);
        return;
      }
      receiptFile(File(picked.path!));
      receiptName(picked.name);
      receiptSizeKB(((picked.lengthSync() ?? 0) / 1024).ceil());
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
      AppToast.failed('missing_claim_date'.tr, 'missing_claim_date_body'.tr);
      return;
    }
    if (isMileage) {
      if ((double.tryParse(distanceCtrl.text) ?? 0) <= 0) {
        AppToast.failed('missing_distance'.tr, 'missing_distance_body'.tr);
        return;
      }
    } else if (selectedCategory.value == ClaimCategory.travel) {
      if (travelFromCtrl.text.trim().isEmpty || travelToCtrl.text.trim().isEmpty) {
        AppToast.failed('missing_travel_details'.tr, 'missing_travel_details_body'.tr);
        return;
      }
    }

    try {
      isSubmitting(true);
      final map = <String, dynamic>{
        'type': ClaimModel.typeToApi(effectiveType),
        'claim_date': claimDate.value!.toIso8601String().split('T').first,
      };

      if (isMileage) {
        final dist = double.parse(distanceCtrl.text);
        map['vehicle_type'] = selectedVehicle.value;
        map['distance_km'] = dist;
        final toll = double.tryParse(tollCtrl.text);
        final park = double.tryParse(parkingCtrl.text);
        final misc = double.tryParse(miscCtrl.text);
        if (toll != null && toll > 0) map['toll_amount'] = toll;
        if (park != null && park > 0) map['parking_amount'] = park;
        if (misc != null && misc > 0) map['miscellaneous_amount'] = misc;
      } else {
        map['amount'] = double.tryParse(amountCtrl.text) ?? 0;
        if (selectedCategory.value == ClaimCategory.general) {
          map['description'] = descriptionCtrl.text.trim();
        } else {
          map['travel_from'] = travelFromCtrl.text.trim();
          map['travel_to'] = travelToCtrl.text.trim();
          if (travelPurposeCtrl.text.isNotEmpty) {
            map['travel_purpose'] = travelPurposeCtrl.text.trim();
          }
        }
      }

      if (receiptFile.value != null) {
        map['receipt'] = await MultipartFile.fromFile(
          receiptFile.value!.path,
          filename: receiptName.value,
        );
      }

      final res = await ApiClient.instance.post(
        ApiList.claimsSubmit,
        data: FormData.fromMap(map),
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
          sendTimeout: const Duration(seconds: 60),
        ),
      );

      final saved = ClaimModel.fromJson(res.data['data'] as Map<String, dynamic>);
      Get.back();

      if (isMileage) {
        AppToast.pending(
          'claim_submitted_title'.tr,
          'claim_mileage_submitted_body'.trParams({'km': distanceCtrl.text}),
        );
      } else {
        AppToast.pending(
          'claim_submitted_title'.tr,
          'claim_submitted_body'.trParams({
            'type': effectiveType.name,
            'amount': saved.amountFormatted,
          }),
        );
      }

      if (Get.isRegistered<ClaimsController>()) {
        Get.find<ClaimsController>().fetchAll();
      }
    } on DioException catch (e) {
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
    amountCtrl.dispose();
    descriptionCtrl.dispose();
    distanceCtrl.dispose();
    tollCtrl.dispose();
    parkingCtrl.dispose();
    miscCtrl.dispose();
    travelFromCtrl.dispose();
    travelToCtrl.dispose();
    travelPurposeCtrl.dispose();
    super.onClose();
  }
}
