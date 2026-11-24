import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staff_attendance/api/api_client.dart';
import 'package:staff_attendance/apps/models/admin_announcement_model.dart';
import 'package:staff_attendance/apps/routes/api_routes.dart';
import 'package:staff_attendance/widgets/app_toast.dart';

class AdminAnnouncementController extends GetxController {
  final announcements = <AdminAnnouncementModel>[].obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final isDeleting = false.obs;
  final hasError = false.obs;

  // Form state
  final titleController = TextEditingController();
  final summaryController = TextEditingController();
  final bodyController = TextEditingController();
  final selectedCategory = Rxn<String>();
  final isPinned = false.obs;
  final publishNow = true.obs;

  static const List<String> categories = [
    'general',
    'hr',
    'it',
    'operations',
    'management',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchAnnouncements();
  }

  @override
  void onClose() {
    titleController.dispose();
    summaryController.dispose();
    bodyController.dispose();
    super.onClose();
  }

  void resetForm() {
    titleController.clear();
    summaryController.clear();
    bodyController.clear();
    selectedCategory.value = null;
    isPinned.value = false;
    publishNow.value = true;
  }

  Future<void> fetchAnnouncements() async {
    try {
      isLoading(true);
      hasError(false);
      final res = await ApiClient.instance.get(ApiList.adminAnnouncements);
      final list = (res.data['data'] as List<dynamic>? ?? [])
          .map((e) => AdminAnnouncementModel.fromJson(e as Map<String, dynamic>))
          .toList();
      announcements.assignAll(list);
    } on DioException catch (e) {
      hasError(true);
      AppToast.failed('Failed', ApiClient.extractError(e, fallback: 'Could not load announcements.'));
    } catch (_) {
      hasError(true);
    } finally {
      isLoading(false);
    }
  }

  Future<void> create() async {
    final title = titleController.text.trim();
    final body = bodyController.text.trim();
    if (title.isEmpty || body.isEmpty) {
      AppToast.failed('Validation', 'Title and body are required.');
      return;
    }

    try {
      isSaving(true);
      final payload = <String, dynamic>{
        'title': title,
        'body': body,
        if (summaryController.text.trim().isNotEmpty)
          'summary': summaryController.text.trim(),
        if (selectedCategory.value != null) 'category': selectedCategory.value,
        'is_pinned': isPinned.value,
        if (publishNow.value) 'publish_now': true,
      };
      await ApiClient.instance.post(ApiList.adminAnnouncements, data: payload);
      AppToast.success('Created', 'Announcement published.');
      resetForm();
      await fetchAnnouncements();
      Get.back();
    } on DioException catch (e) {
      AppToast.failed('Failed', ApiClient.extractError(e, fallback: 'Could not create announcement.'));
    } catch (_) {
      AppToast.failed('Error', 'Unexpected error. Please retry.');
    } finally {
      isSaving(false);
    }
  }

  Future<void> updateAnnouncement(AdminAnnouncementModel item) async {
    final title = titleController.text.trim();
    final body = bodyController.text.trim();
    if (title.isEmpty || body.isEmpty) {
      AppToast.failed('Validation', 'Title and body are required.');
      return;
    }

    try {
      isSaving(true);
      final payload = <String, dynamic>{
        'title': title,
        'body': body,
        if (summaryController.text.trim().isNotEmpty)
          'summary': summaryController.text.trim(),
        if (selectedCategory.value != null) 'category': selectedCategory.value,
        'is_pinned': isPinned.value,
        if (publishNow.value) 'publish_now': true,
      };
      await ApiClient.instance.patch(
        ApiList.adminAnnouncement(item.id.toString()),
        data: payload,
      );
      AppToast.success('Updated', 'Announcement updated.');
      resetForm();
      await fetchAnnouncements();
      Get.back();
    } on DioException catch (e) {
      AppToast.failed('Failed', ApiClient.extractError(e, fallback: 'Could not update announcement.'));
    } catch (_) {
      AppToast.failed('Error', 'Unexpected error. Please retry.');
    } finally {
      isSaving(false);
    }
  }

  Future<void> delete(AdminAnnouncementModel item) async {
    if (isDeleting.value) return;
    try {
      isDeleting(true);
      await ApiClient.instance.delete(
        ApiList.adminAnnouncement(item.id.toString()),
      );
      announcements.remove(item);
      AppToast.success('Deleted', 'Announcement removed.');
    } on DioException catch (e) {
      AppToast.failed('Failed', ApiClient.extractError(e, fallback: 'Could not delete announcement.'));
    } finally {
      isDeleting(false);
    }
  }

  void populateForm(AdminAnnouncementModel item) {
    titleController.text = item.title;
    summaryController.text = item.summary ?? '';
    bodyController.text = item.body;
    selectedCategory.value = item.category;
    isPinned.value = item.isPinned;
    publishNow.value = item.isPublished;
  }
}
