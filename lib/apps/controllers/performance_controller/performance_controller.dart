import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staff_attendance/api/api_client.dart';
import 'package:staff_attendance/apps/models/performance_review_model.dart';
import 'package:staff_attendance/apps/routes/api_routes.dart';
import 'package:staff_attendance/widgets/app_toast.dart';

class PerformanceController extends GetxController {
  final reviews = <PerformanceReviewModel>[].obs;
  final isLoading = false.obs;
  final hasError = false.obs;
  final isSubmitting = false.obs;

  // Self-assessment form state for the currently open review
  final formKey = GlobalKey<FormState>();
  final selectedRating = Rxn<int>();
  final commentController = TextEditingController();
  // goal id → selected status
  final goalStatuses = <int, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchReviews();
  }

  Future<void> fetchReviews() async {
    try {
      isLoading(true);
      hasError(false);
      final res = await ApiClient.instance.get(ApiList.performance);
      final list = (res.data['data'] as List<dynamic>? ?? [])
          .map((e) => PerformanceReviewModel.fromJson(e as Map<String, dynamic>))
          .toList();
      reviews.assignAll(list);
    } on DioException catch (e) {
      hasError(true);
      AppToast.failed('Failed to load', ApiClient.extractError(e, fallback: 'Could not load performance reviews.'));
    } catch (_) {
      hasError(true);
    } finally {
      isLoading(false);
    }
  }

  void initSelfAssessment(PerformanceReviewModel review) {
    selectedRating.value = review.selfRating;
    commentController.text = review.selfComment ?? '';
    goalStatuses.assignAll({for (final g in review.goals) g.id: g.status});
  }

  Future<void> submitSelfAssessment(int reviewId) async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (selectedRating.value == null) {
      AppToast.failed('Missing rating', 'Please select your self-rating.');
      return;
    }
    try {
      isSubmitting(true);
      await ApiClient.instance.patch(
        ApiList.performanceSelfAssessment('$reviewId'),
        data: {
          'self_rating': selectedRating.value,
          'self_comment': commentController.text.trim(),
          'goals': goalStatuses.entries
              .map((e) => {'id': e.key, 'status': e.value})
              .toList(),
        },
      );
      Get.back();
      AppToast.success('Submitted', 'Your self-assessment has been submitted.');
      await fetchReviews();
    } on DioException catch (e) {
      AppToast.failed('Submission failed', ApiClient.extractError(e, fallback: 'Could not submit self-assessment.'));
    } finally {
      isSubmitting(false);
    }
  }

  Future<void> acknowledge(int reviewId, {String? comment}) async {
    try {
      isSubmitting(true);
      await ApiClient.instance.patch(
        ApiList.performanceAcknowledge('$reviewId'),
        data: {'acknowledgement_comment': comment},
      );
      AppToast.success('Acknowledged', 'You have acknowledged this review.');
      await fetchReviews();
    } on DioException catch (e) {
      AppToast.failed('Failed', ApiClient.extractError(e, fallback: 'Could not acknowledge review.'));
    } finally {
      isSubmitting(false);
    }
  }

  @override
  void onClose() {
    commentController.dispose();
    super.onClose();
  }
}
