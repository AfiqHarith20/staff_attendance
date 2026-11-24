import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:staff_attendance/api/api_client.dart';
import 'package:staff_attendance/apps/models/job_posting_model.dart';
import 'package:staff_attendance/apps/routes/api_routes.dart';
import 'package:staff_attendance/widgets/app_toast.dart';

class JobBoardController extends GetxController {
  final jobs = <JobPostingModel>[].obs;
  final isLoading = false.obs;
  final hasError = false.obs;
  final searchQuery = ''.obs;

  List<JobPostingModel> get filtered {
    final q = searchQuery.value.toLowerCase();
    if (q.isEmpty) return jobs;
    return jobs.where((j) =>
        j.title.toLowerCase().contains(q) ||
        (j.department?.toLowerCase().contains(q) ?? false) ||
        (j.location?.toLowerCase().contains(q) ?? false)).toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchJobs();
  }

  Future<void> fetchJobs() async {
    try {
      isLoading(true);
      hasError(false);
      final res = await ApiClient.instance.get(ApiList.jobs);
      final list = (res.data['data'] as List<dynamic>? ?? [])
          .map((e) => JobPostingModel.fromJson(e as Map<String, dynamic>))
          .toList();
      jobs.assignAll(list);
    } on DioException catch (e) {
      hasError(true);
      AppToast.failed('Failed to load', ApiClient.extractError(e, fallback: 'Could not load job board.'));
    } catch (_) {
      hasError(true);
    } finally {
      isLoading(false);
    }
  }
}
