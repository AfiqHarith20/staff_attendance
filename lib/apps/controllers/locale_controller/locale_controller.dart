import 'dart:ui';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LocaleController extends GetxController {
  final _storage = GetStorage();
  static const _key = 'locale';

  final _locale = Locale('en', 'US').obs;
  Locale get locale => _locale.value;

  @override
  void onInit() {
    super.onInit();
    final stored = _storage.read<String>(_key);
    if (stored != null && stored.isNotEmpty) {
      final parts = stored.split('_');
      if (parts.length == 2) {
        _locale(Locale(parts[0], parts[1]));
      }
    }
    // Always update Get's locale to the resolved value (default or stored)
    Get.updateLocale(_locale.value);
  }

  void setLocale(Locale locale) {
    _locale(locale);
    Get.updateLocale(locale);
    _storage.write(_key, '${locale.languageCode}_${locale.countryCode}');
  }
}
