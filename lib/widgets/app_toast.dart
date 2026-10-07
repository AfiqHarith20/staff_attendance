import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class AppToast {
  const AppToast._();

  static void approved(String title, String message) {
    _show(
      title: title,
      message: message,
      type: ToastificationType.success,
      primaryColor: const Color(0xFF16A34A),
    );
  }

  static void success(String title, String message) {
    approved(title, message);
  }

  static void failed(String title, String message) {
    _show(
      title: title,
      message: message,
      type: ToastificationType.error,
      primaryColor: const Color(0xFFDC2626),
    );
  }

  static void pending(String title, String message) {
    _show(
      title: title,
      message: message,
      type: ToastificationType.warning,
      primaryColor: const Color(0xFFF59E0B),
    );
  }

  static void info(String title, String message) {
    _show(
      title: title,
      message: message,
      type: ToastificationType.info,
      primaryColor: const Color(0xFF185FA5),
    );
  }

  static void _show({
    required String title,
    required String message,
    required ToastificationType type,
    required Color primaryColor,
  }) {
    toastification.show(
      alignment: Alignment.topCenter,
      autoCloseDuration: const Duration(seconds: 3),
      borderRadius: BorderRadius.circular(14),
      closeOnClick: true,
      dragToClose: true,
      description: Text(message),
      primaryColor: primaryColor,
      showProgressBar: false,
      style: ToastificationStyle.flatColored,
      title: Text(title),
      type: type,
    );
  }
}
