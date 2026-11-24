import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:staff_attendance/api/api_client.dart';
import 'package:staff_attendance/apps/models/asset_model.dart';
import 'package:staff_attendance/apps/routes/api_routes.dart';
import 'package:staff_attendance/widgets/app_toast.dart';

class MyAssetsController extends GetxController {
  final assets = <AssetModel>[].obs;
  final isLoading = false.obs;
  final hasError = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAssets();
  }

  Future<void> fetchAssets() async {
    try {
      isLoading(true);
      hasError(false);
      final res = await ApiClient.instance.get(ApiList.myAssets);
      final list = (res.data['data'] as List<dynamic>? ?? [])
          .map((e) => AssetModel.fromJson(e as Map<String, dynamic>))
          .toList();
      assets.assignAll(list);
    } on DioException catch (e) {
      hasError(true);
      AppToast.failed('Failed to load', ApiClient.extractError(e, fallback: 'Could not load assets.'));
    } catch (_) {
      hasError(true);
    } finally {
      isLoading(false);
    }
  }
}
