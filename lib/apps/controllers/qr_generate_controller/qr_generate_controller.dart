import 'dart:async';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:staff_attendance/api/api_client.dart';
import 'package:staff_attendance/apps/routes/api_routes.dart';

class QRGenerateController extends GetxController {
  final token = RxnString();
  final expiresAt = Rxn<DateTime>();
  final isLoading = false.obs;

  Timer? _expiryTimer;

  @override
  void onInit() {
    super.onInit();
    rotate();
    // Tick every 10 s so the expiry badge switches to red without user action.
    _expiryTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      expiresAt.refresh();
    });
  }

  @override
  void onClose() {
    _expiryTimer?.cancel();
    super.onClose();
  }

  /// GET /qr/generate — rotates the token each call.
  Future<void> rotate() async {
    try {
      isLoading(true);
      token(null);
      final response = await ApiClient.instance.get(ApiList.qrGenerate);
      final data = response.data['data'] as Map<String, dynamic>;
      token(data['token'] as String?);
      final expiresAtStr = data['expires_at'] as String?;
      if (expiresAtStr != null) {
        expiresAt(DateTime.tryParse(expiresAtStr)?.toLocal());
      }
    } catch (e) {
      debugPrint('QR_GENERATE error: $e');
    } finally {
      isLoading(false);
    }
  }

  String get expiryLabel {
    final exp = expiresAt.value;
    if (exp == null) return '';
    return 'Expires at ${DateFormat('h:mm a').format(exp)}';
  }

  bool get isExpired {
    final exp = expiresAt.value;
    if (exp == null) return false;
    return DateTime.now().isAfter(exp);
  }
}
