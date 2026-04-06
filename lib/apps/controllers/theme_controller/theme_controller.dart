import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  final _storage = GetStorage();
  static const _key = 'is_dark_mode';

  final _isDark = false.obs;
  bool get isDark => _isDark.value;
  ThemeMode get themeMode => _isDark.value ? ThemeMode.dark : ThemeMode.light;

  @override
  void onInit() {
    super.onInit();
    _isDark(_storage.read<bool>(_key) ?? false);
  }

  void toggle() {
    _isDark(!_isDark.value);
    _storage.write(_key, _isDark.value);
    Get.changeThemeMode(themeMode);
  }
}
