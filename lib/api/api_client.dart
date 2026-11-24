import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:staff_attendance/apps/routes/api_routes.dart';

class _PrettyLogger extends Interceptor {
  static const _enc = JsonEncoder.withIndent('  ');

  static String _fmt(dynamic body) {
    if (body == null) return 'null';
    if (body is Map || body is List) {
      try {
        return _enc.convert(body);
      } catch (_) {}
    }
    final s = body.toString();
    try {
      return _enc.convert(jsonDecode(s));
    } catch (_) {
      return s;
    }
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('┌── [${options.method}] ${options.uri}');
    if (options.data != null) {
      debugPrint('│  Body:\n${_fmt(options.data).split('\n').map((l) => '│    $l').join('\n')}');
    }
    debugPrint('└──────────────────────────────────────────');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final status = response.statusCode;
    debugPrint('┌── [${status}] ${response.requestOptions.uri}');
    debugPrint('│  Response:\n${_fmt(response.data).split('\n').map((l) => '│    $l').join('\n')}');
    debugPrint('└──────────────────────────────────────────');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('┌── [ERROR] ${err.requestOptions.uri}');
    debugPrint('│  Type   : ${err.type.name}');
    if (err.response != null) {
      debugPrint('│  Status : ${err.response!.statusCode}');
      debugPrint('│  Body   :\n${_fmt(err.response!.data).split('\n').map((l) => '│    $l').join('\n')}');
    } else {
      debugPrint('│  Message: ${err.message}');
    }
    debugPrint('└──────────────────────────────────────────');
    handler.next(err);
  }
}

/// API client that talks to the real Laravel backend via Sanctum bearer tokens.
class ApiClient {
  ApiClient._internal()
    : _dio = Dio(
        BaseOptions(
          baseUrl: ApiList.baseUrl,
          contentType: Headers.jsonContentType,
          headers: {'Accept': 'application/json'},
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 15),
        ),
      ) {
    debugPrint('ApiClient baseUrl: ${ApiList.baseUrl}');
    if (kDebugMode) {
      _dio.interceptors.add(_PrettyLogger());
    }
  }

  static final ApiClient instance = ApiClient._internal();

  final Dio _dio;

  /// Stores the Sanctum token so future authenticated requests include it.
  void setAuthToken(String? token) {
    if (token == null) {
      _dio.options.headers.remove('Authorization');
    } else {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  Future<Response> post(String path, {dynamic data, Options? options}) async {
    final response = await _dio.post(path, data: data, options: options);
    if (path == ApiList.login) {
      final token =
          (response.data['data'] as Map<String, dynamic>?)?['token']
              as String?;
      setAuthToken(token);
    }
    if (path == ApiList.logout) {
      setAuthToken(null);
    }
    return response;
  }

  Future<Response> patch(String path, {dynamic data, Options? options}) async {
    return _dio.patch(path, data: data, options: options);
  }

  Future<Response> delete(String path, {dynamic data}) async {
    return _dio.delete(path, data: data);
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.get(path, queryParameters: queryParameters);
  }

  /// Extracts a human-readable message from a Dio/Laravel error response.
  static String extractError(dynamic e, {String fallback = 'Something went wrong'}) {
    if (e is DioException) {
      final msg = e.response?.data?['message'] as String?;
      if (msg != null && msg.isNotEmpty) return msg;
    }
    return fallback;
  }
}
