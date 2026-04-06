import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class StorageService extends GetxService {
  final _box = GetStorage();

  static StorageService get to => Get.find();

  String? getAuthToken() => _box.read<String>('auth_token');
  Future<void> saveAuthToken(String token) => _box.write('auth_token', token);
  Future<void> clearAuthToken() => _box.remove('auth_token');

  static Future<void> saveFcmToken(String token) =>
      GetStorage().write('fcm_token', token);
  static String? getFcmToken() => GetStorage().read<String>('fcm_token');
}
