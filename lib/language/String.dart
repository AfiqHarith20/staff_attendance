import 'dart:ui';

import 'package:get/get.dart';
import 'en.dart';
import 'my.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {'en_US': en_US, 'my_MY': my_MY};
}

/// Helper: list of supported locales used elsewhere if needed.
const supportedLocales = [Locale('en', 'US'), Locale('my', 'MY')];
