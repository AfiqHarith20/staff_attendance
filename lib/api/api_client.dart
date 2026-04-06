import 'package:dio/dio.dart';

/// Minimal dummy API client used during development when backend is unavailable.
/// Returns a successful login response for `/auth/login` with a dummy token.
class ApiClient {
  ApiClient._internal() {
    _dio = Dio();
  }

  static final ApiClient instance = ApiClient._internal();
  late final Dio _dio;

  /// Simulates a POST request. For `/auth/login` it returns a dummy token
  /// and role (admin if the email contains `admin`, otherwise `staff`).
  Future<Response> post(String path, {dynamic data, Options? options}) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 400));

    if (path == '/auth/login') {
      final email = data?['email'] as String? ?? '';
      final role = email.contains('admin') ? 'admin' : 'staff';
      final token = 'dummy_${role}_token';

      final resp = {
        'data': {'token': token, 'role': role},
      };

      return Response(
        data: resp,
        statusCode: 200,
        requestOptions: RequestOptions(path: path),
      );
    }

    if (path == '/attendance/checkin') {
      // simulate successful check-in
      final resp = {
        'data': {'status': 'ok', 'message': 'Checked in successfully'},
      };
      return Response(
        data: resp,
        statusCode: 200,
        requestOptions: RequestOptions(path: path),
      );
    }

    if (path == '/documents/upload') {
      // simulate uploaded document metadata
      String type = 'mc';
      try {
        if (data is FormData) {
          for (final field in data.fields) {
            if (field.key == 'type') {
              type = field.value;
              break;
            }
          }
        } else if (data is Map<String, dynamic> && data['type'] != null) {
          type = data['type'].toString();
        }
      } catch (_) {}

      final resp = {
        'data': {
          'id': 999,
          'filename': 'upload.dat',
          'type': type,
          'status': 'uploaded',
          'created_at': DateTime.now().toIso8601String(),
        },
      };
      return Response(
        data: resp,
        statusCode: 200,
        requestOptions: RequestOptions(path: path),
      );
    }

    // Default dummy response
    return Response(
      data: {'data': null},
      statusCode: 200,
      requestOptions: RequestOptions(path: path),
    );
  }

  /// Simulate a GET request returning dummy data for a few endpoints used
  /// by the app during development.
  Future<Response> get(String path) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (path == '/documents') {
      final resp = {
        'data': [
          {
            'id': 1,
            'filename': 'mc_jan.pdf',
            'type': 'mc',
            'status': 'uploaded',
            'created_at': DateTime.now().toIso8601String(),
          },
          {
            'id': 2,
            'filename': 'mc_feb.pdf',
            'type': 'mc',
            'status': 'uploaded',
            'created_at': DateTime.now().toIso8601String(),
          },
        ],
      };

      return Response(
        data: resp,
        statusCode: 200,
        requestOptions: RequestOptions(path: path),
      );
    }

    if (path == '/qr/generate') {
      final resp = {
        'data': {
          'token': 'dummy_qr_token_12345',
          'expires_at': DateTime.now()
              .add(const Duration(seconds: 30))
              .toIso8601String(),
        },
      };

      return Response(
        data: resp,
        statusCode: 200,
        requestOptions: RequestOptions(path: path),
      );
    }

    return Response(
      data: {'data': null},
      statusCode: 200,
      requestOptions: RequestOptions(path: path),
    );
  }
}
