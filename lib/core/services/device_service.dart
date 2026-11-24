import 'dart:io';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:get_storage/get_storage.dart';
import 'package:staff_attendance/api/api_client.dart';
import 'package:staff_attendance/apps/routes/api_routes.dart';
import 'package:staff_attendance/core/services/storage_service.dart';

/// Handles FCM / APNs device token registration with the backend.
/// Call [register] after login and on app resume.
/// Call [unregister] before clearing the auth token on logout.
class DeviceService {
  static String get _platform => Platform.isAndroid ? 'android' : 'ios';

  static bool get _isLoggedIn =>
      GetStorage().read<String>('auth_token') != null;

  /// POST /devices — registers or refreshes the push token for this device.
  /// Safe to call multiple times (the backend upserts on token value).
  static Future<void> register() async {
    final token = StorageService.getFcmToken();
    if (token == null || token.isEmpty) return;
    try {
      await ApiClient.instance.post(
        ApiList.devices,
        data: {'token': token, 'platform': _platform},
      );
      debugPrint('DEVICE registered: $_platform');
    } catch (e) {
      debugPrint('DEVICE register error: $e');
    }
  }

  /// POST /devices — registers if the user is currently logged in.
  /// Used from app-resume and token-refresh paths where login state is unknown.
  static Future<void> registerIfLoggedIn() async {
    if (_isLoggedIn) await register();
  }

  /// DELETE /devices — removes the push token so this device stops receiving
  /// push notifications. Must be called before the auth token is cleared.
  static Future<void> unregister() async {
    final token = StorageService.getFcmToken();
    if (token == null || token.isEmpty) return;
    try {
      await ApiClient.instance.delete(
        ApiList.devices,
        data: {'token': token, 'platform': _platform},
      );
      debugPrint('DEVICE unregistered: $_platform');
    } catch (e) {
      debugPrint('DEVICE unregister error: $e');
    }
  }
}
