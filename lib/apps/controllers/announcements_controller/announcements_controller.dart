import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:staff_attendance/api/api_client.dart';
import 'package:staff_attendance/apps/models/announcement_model.dart';

class AnnouncementsController extends GetxController {
  final announcements = <AnnouncementModel>[].obs;
  final isLoading = false.obs;
  final selectedCategory = 'All'.obs;

  List<String> get categories {
    final values = announcements.map((e) => e.category).toSet().toList()..sort();
    return ['All', ...values];
  }

  List<AnnouncementModel> get filtered {
    if (selectedCategory.value == 'All') return announcements;
    return announcements
        .where((item) => item.category == selectedCategory.value)
        .toList();
  }

  List<AnnouncementModel> get pinned =>
      filtered.where((item) => item.isPinned).toList();

  List<AnnouncementModel> get regular =>
      filtered.where((item) => !item.isPinned).toList();

  String formatDate(DateTime date) => DateFormat('d MMM yyyy').format(date);

  @override
  void onInit() {
    super.onInit();
    fetchAnnouncements();
  }

  Future<void> fetchAnnouncements() async {
    try {
      isLoading(true);
      final response = await ApiClient.instance.get('/announcements');
      final list = (response.data['data'] as List? ?? const [])
          .map((item) => AnnouncementModel.fromJson(item as Map<String, dynamic>))
          .toList();
      announcements.assignAll(list);
    } finally {
      isLoading(false);
    }
  }

  void setCategory(String category) => selectedCategory(category);
}
