import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:staff_attendance/api/api_client.dart';
import 'package:staff_attendance/apps/models/notification_model.dart';

class NotificationsController extends GetxController {
  final notifications = <NotificationModel>[].obs;
  final isLoading = false.obs;
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
      final response = await ApiClient.instance.get('/notifications');
      final list = (response.data['data'] as List? ?? const [])
          .map((item) => NotificationModel.fromJson(item as Map<String, dynamic>))
          .toList();
      notifications.assignAll(list);
    } finally {
      isLoading(false);
    }
  }

  void setCategory(String category) => selectedCategory(category);
  String timeLabel(DateTime date) => DateFormat('d MMM, h:mm a').format(date);

  void openNotification(NotificationModel item) {
    if (item.route.isNotEmpty) Get.toNamed(item.route);
  }
}
