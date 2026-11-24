import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:intl/intl.dart';
import 'package:staff_attendance/api/api_client.dart';
import 'package:staff_attendance/apps/routes/api_routes.dart';
import 'package:staff_attendance/apps/models/document_model.dart';
import 'package:staff_attendance/widgets/app_toast.dart';

class DocumentUploadController extends GetxController {
  final isUploading = false.obs;
  final uploadError = ''.obs;
  final selectedType = DocumentType.ic.obs;
  final selectedFile = Rxn<PlatformFile>();
  final noteController = TextEditingController();
  final expiresAtController = TextEditingController();
  final selectedExpiresAt = Rxn<DateTime>();

  static const int _maxBytes = 10 * 1024 * 1024; // 10 MB (per API docs)
  static const List<String> _allowedExtensions = [
    'pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx',
  ];

  Future<void> pickFile() async {
    uploadError('');
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: _allowedExtensions,
    );
    if (file == null) return;

    if ((file.lengthSync() ?? 0) > _maxBytes) {
      uploadError('file_too_large'.tr);
      return;
    }
    selectedFile(file);
  }

  Future<void> pickExpiryDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 20)),
    );
    if (picked != null) {
      selectedExpiresAt(picked);
      expiresAtController.text = DateFormat('d MMM yyyy').format(picked);
    }
  }

  void clearExpiry() {
    selectedExpiresAt(null);
    expiresAtController.clear();
  }

  Future<void> submit() async {
    final file = selectedFile.value;
    if (file == null || file.path == null) {
      uploadError('Please choose a file before uploading.');
      return;
    }

    try {
      uploadError('');
      isUploading(true);

      final fields = <String, dynamic>{
        'type': selectedType.value.name,
        'file': await MultipartFile.fromFile(file.path!, filename: file.name),
      };
      final note = noteController.text.trim();
      if (note.isNotEmpty) fields['note'] = note;
      final exp = selectedExpiresAt.value;
      if (exp != null) fields['expires_at'] = DateFormat('yyyy-MM-dd').format(exp);

      final form = FormData.fromMap(fields);
      await ApiClient.instance.post(
        ApiList.documentsUpload,
        data: form,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
          sendTimeout: const Duration(seconds: 60),
        ),
      );
      AppToast.success(
        'upload_complete'.tr,
        file.name,
      );
      Get.back(result: true);
    } on DioException catch (e) {
      debugPrint('UPLOAD DioException: ${e.type} | ${e.response?.statusCode} | ${e.response?.data}');
      uploadError(
        ApiClient.extractError(e, fallback: 'Upload failed. Please try again.'),
      );
    } catch (e) {
      debugPrint('UPLOAD error: $e');
      uploadError('Upload failed. Please try again.');
    } finally {
      isUploading(false);
    }
  }

  String typeLabel(DocumentType type) {
    switch (type) {
      case DocumentType.ic:
        return 'IC / MyKad';
      case DocumentType.contract:
        return 'Employment contract';
      case DocumentType.cert:
        return 'Certificate';
      case DocumentType.medical:
        return 'Medical cert';
      case DocumentType.passport:
        return 'Passport';
      case DocumentType.other:
        return 'Other document';
    }
  }

  String fileSize(PlatformFile file) {
    final bytes = file.lengthSync() ?? 0;
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  void onClose() {
    noteController.dispose();
    expiresAtController.dispose();
    super.onClose();
  }
}
