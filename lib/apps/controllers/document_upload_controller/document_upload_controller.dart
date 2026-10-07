import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:staff_attendance/api/api_client.dart';
import 'package:staff_attendance/apps/models/document_model.dart';
import 'package:staff_attendance/widgets/app_toast.dart';

class DocumentUploadController extends GetxController {
  final isUploading = false.obs;
  final uploadError = ''.obs;
  final selectedType = DocumentType.mc.obs;
  final selectedFile = Rxn<PlatformFile>();
  final noteController = TextEditingController();

  Future<void> pickFile() async {
    uploadError('');
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
      withData: false,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.size > 5 * 1024 * 1024) {
      uploadError('File too large. Maximum 5 MB.');
      return;
    }
    selectedFile(file);
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
      final form = FormData.fromMap({
        'type': selectedType.value.name,
        'note': noteController.text.trim(),
        'file': await MultipartFile.fromFile(file.path!, filename: file.name),
      });
      await ApiClient.instance.post('/documents/upload', data: form);
      AppToast.success(
        'Upload complete',
        '${file.name} has been added to your documents.',
      );
      Get.back(result: true);
    } on DioException catch (e) {
      uploadError(e.response?.data['message'] as String? ?? 'Upload failed.');
    } catch (_) {
      uploadError('Upload failed. Please try again.');
    } finally {
      isUploading(false);
    }
  }

  String typeLabel(DocumentType type) {
    switch (type) {
      case DocumentType.mc:
        return 'Medical cert';
      case DocumentType.emergencyLeave:
        return 'Emergency leave';
      case DocumentType.annualLeave:
        return 'Annual leave';
      case DocumentType.other:
        return 'Other document';
    }
  }

  String fileSize(PlatformFile file) {
    final bytes = file.size;
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  void onClose() {
    noteController.dispose();
    super.onClose();
  }
}
