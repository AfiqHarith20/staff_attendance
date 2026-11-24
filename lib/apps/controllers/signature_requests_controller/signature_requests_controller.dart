import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:staff_attendance/api/api_client.dart';
import 'package:staff_attendance/apps/models/signature_request_model.dart';
import 'package:staff_attendance/apps/routes/api_routes.dart';
import 'package:staff_attendance/widgets/app_toast.dart';

class SignatureRequestsController extends GetxController {
  final requests = <SignatureRequestModel>[].obs;
  final isLoading = false.obs;
  final hasError = false.obs;
  final isActioning = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    try {
      isLoading(true);
      hasError(false);
      final res = await ApiClient.instance.get(ApiList.signatureRequests);
      final list = (res.data['data'] as List<dynamic>? ?? [])
          .map((e) => SignatureRequestModel.fromJson(e as Map<String, dynamic>))
          .toList();
      requests.assignAll(list);
    } on DioException catch (e) {
      hasError(true);
      AppToast.failed('Failed to load', ApiClient.extractError(e, fallback: 'Could not load signature requests.'));
    } catch (_) {
      hasError(true);
    } finally {
      isLoading(false);
    }
  }

  Future<void> sign(SignatureRequestModel req) async {
    try {
      isActioning(true);
      await ApiClient.instance.post(ApiList.signatureSign('${req.id}'));
      AppToast.success('Signed', 'You have signed "${req.title}".');
      await fetchRequests();
    } on DioException catch (e) {
      AppToast.failed('Failed', ApiClient.extractError(e, fallback: 'Could not sign document.'));
    } finally {
      isActioning(false);
    }
  }

  Future<void> decline(SignatureRequestModel req, String reason) async {
    try {
      isActioning(true);
      await ApiClient.instance.post(
        ApiList.signatureDecline('${req.id}'),
        data: {'reason': reason},
      );
      AppToast.failed('Declined', 'You have declined "${req.title}".');
      await fetchRequests();
    } on DioException catch (e) {
      AppToast.failed('Failed', ApiClient.extractError(e, fallback: 'Could not decline request.'));
    } finally {
      isActioning(false);
    }
  }
}
