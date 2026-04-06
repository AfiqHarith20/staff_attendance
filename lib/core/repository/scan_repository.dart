import 'dart:io';
import 'package:dio/dio.dart';
import 'package:staff_attendance/api/api_client.dart';
import 'package:get_storage/get_storage.dart';
import 'package:staff_attendance/apps/models/document_model.dart';

class ScanRepository {
  final _client = ApiClient.instance;

  // Staff: POST check-in with QR token
  Future<Map<String, dynamic>> checkIn(String qrToken) async {
    try {
      final deviceId = GetStorage().read<String>('device_id') ?? '';
      final response = await _client.post(
        '/attendance/checkin',
        data: {'qr_token': qrToken, 'device_id': deviceId},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw e.response?.data['message'] as String? ?? 'Check-in failed';
    }
  }

  // Staff: fetch their document list
  Future<List<DocumentModel>> fetchDocuments() async {
    try {
      final response = await _client.get('/documents');
      return (response.data['data'] as List)
          .map((e) => DocumentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw e.response?.data['message'] as String? ??
          'Failed to load documents';
    }
  }

  // Staff: upload MC / document
  Future<DocumentModel> uploadDocument({
    required File file,
    required DocumentType type,
    String? note,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
        'type': type.name,
        if (note != null && note.isNotEmpty) 'note': note,
      });

      final response = await _client.post(
        '/documents/upload',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
          sendTimeout: const Duration(seconds: 60),
        ),
      );
      return DocumentModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw e.response?.data['message'] as String? ?? 'Upload failed';
    }
  }

  // Admin: get current active QR token
  Future<Map<String, dynamic>> fetchQrToken() async {
    try {
      final response = await _client.get('/qr/generate');
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw e.response?.data['message'] as String? ?? 'Failed to get QR';
    }
  }
}
