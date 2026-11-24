import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:staff_attendance/api/api_client.dart';
import 'package:staff_attendance/apps/models/admin_asset_model.dart';
import 'package:staff_attendance/apps/routes/api_routes.dart';
import 'package:staff_attendance/widgets/app_toast.dart';

class AdminAssetsController extends GetxController {
  final assets = <AdminAssetModel>[].obs;
  final isLoading = false.obs;
  final hasError = false.obs;
  final searchQuery = ''.obs;
  final filterCategory = Rxn<String>();
  final filterAssigned = Rxn<bool>();
  final searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchAssets();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  List<AdminAssetModel> get filtered {
    final q = searchQuery.value.toLowerCase();
    final cat = filterCategory.value;
    final assigned = filterAssigned.value;
    return assets.where((a) {
      final matchQ = q.isEmpty ||
          a.name.toLowerCase().contains(q) ||
          (a.code?.toLowerCase().contains(q) ?? false) ||
          (a.brand?.toLowerCase().contains(q) ?? false);
      final matchCat = cat == null || a.category == cat;
      final matchAssigned = assigned == null || a.isAssigned == assigned;
      return matchQ && matchCat && matchAssigned;
    }).toList();
  }

  Future<void> fetchAssets() async {
    try {
      isLoading(true);
      hasError(false);
      final params = <String, dynamic>{
        if (filterCategory.value != null) 'category': filterCategory.value,
        if (filterAssigned.value != null)
          'assigned': filterAssigned.value! ? '1' : '0',
      };
      final res = await ApiClient.instance.get(
        ApiList.adminAssets,
        queryParameters: params,
      );
      final list = (res.data['data'] as List<dynamic>? ?? [])
          .map((e) => AdminAssetModel.fromJson(e as Map<String, dynamic>))
          .toList();
      assets.assignAll(list);
    } on DioException catch (e) {
      hasError(true);
      AppToast.failed('Failed', ApiClient.extractError(e, fallback: 'Could not load assets.'));
    } catch (_) {
      hasError(true);
    } finally {
      isLoading(false);
    }
  }

  Future<void> assign(AdminAssetModel asset, int userId) async {
    try {
      await ApiClient.instance.post(
        ApiList.adminAssetAssign(asset.id.toString()),
        data: {'user_id': userId},
      );
      AppToast.success('Assigned', '${asset.name} assigned.');
      await fetchAssets();
    } on DioException catch (e) {
      AppToast.failed('Failed', ApiClient.extractError(e, fallback: 'Could not assign asset.'));
    }
  }

  Future<void> unassign(AdminAssetModel asset) async {
    try {
      await ApiClient.instance.delete(
        ApiList.adminAssetUnassign(asset.id.toString()),
      );
      AppToast.success('Unassigned', '${asset.name} unassigned.');
      await fetchAssets();
    } on DioException catch (e) {
      AppToast.failed('Failed', ApiClient.extractError(e, fallback: 'Could not unassign asset.'));
    }
  }
}
