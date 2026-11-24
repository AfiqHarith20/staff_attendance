import 'package:flutter/foundation.dart' show debugPrint;
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:staff_attendance/api/api_client.dart';
import 'package:staff_attendance/apps/routes/api_routes.dart';
import 'package:staff_attendance/apps/models/notification_model.dart';

class NotificationsController extends GetxController {
  final notifications = <NotificationModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final selectedCategory = 'All'.obs;

  List<String> get categories {
    final values = notifications.map((item) => item.category).toSet().toList()..sort();
    return ['All', ...values];
  }

  List<NotificationModel> get filtered {
    if (selectedCategory.value == 'All') return notifications;
    return notifications
        .where((item) => item.category == selectedCategory.value)
        .toList();
  }

  int get unreadCount => notifications.where((item) => item.isUnread).length;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      isLoading(true);
      errorMessage('');
      final response = await ApiClient.instance.get(ApiList.notifications);
      final list = (response.data['data'] as List? ?? const [])
          .map((item) => NotificationModel.fromJson(item as Map<String, dynamic>))
          .toList();
      notifications.assignAll(list);
    } catch (e) {
      debugPrint('NOTIFICATIONS error: $e');
      errorMessage('could_not_load_notifications'.tr);
    } finally {
      isLoading(false);
    }
  }

  Future<void> markAsRead(String id) async {
    final idx = notifications.indexWhere((n) => n.id == id);
    if (idx != -1 && notifications[idx].isUnread) {
      notifications[idx] = notifications[idx].copyWith(isUnread: false);
    }
    try {
      await ApiClient.instance.post(ApiList.notificationRead(id));
    } catch (e) {
      debugPrint('NOTIFICATIONS markAsRead error: $e');
    }
  }

  Future<void> markAllAsRead() async {
    final updated = notifications.map((n) => n.copyWith(isUnread: false)).toList();
    notifications.assignAll(updated);
    try {
      await ApiClient.instance.post(ApiList.notificationsReadAll);
    } catch (e) {
      debugPrint('NOTIFICATIONS markAllAsRead error: $e');
    }
  }

  void setCategory(String category) => selectedCategory(category);
  String timeLabel(DateTime date) => DateFormat('d MMM, h:mm a').format(date);

  void openNotification(NotificationModel item) {
    markAsRead(item.id);
    if (item.route.isNotEmpty) Get.toNamed(item.route);
  }
}
