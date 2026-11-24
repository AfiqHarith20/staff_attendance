import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:get/get.dart';
import 'package:staff_attendance/api/api_client.dart';
import 'package:staff_attendance/apps/routes/api_routes.dart';
import 'package:staff_attendance/widgets/app_toast.dart';

class TeamAttendanceController extends GetxController {
  final isLoading = false.obs;
  final errorMessage = Rxn<String>();
  final selectedStatus = 'All'.obs;
  final selectedDepartment = 'All'.obs;
  final filtersExpanded = false.obs;
  final searchQuery = ''.obs;
  final members = <Map<String, dynamic>>[].obs;

  final statuses = const [
    'All',
    'Present',
    'Late',
    'On leave',
    'Remote',
    'Absent',
  ];

  List<Map<String, dynamic>> get filtered {
    return members.where((item) {
      final statusOk =
          selectedStatus.value == 'All' ||
          item['status'] == selectedStatus.value;
      final departmentOk =
          selectedDepartment.value == 'All' ||
          item['role'] == selectedDepartment.value;
      final query = searchQuery.value;
      final text = '${item['name']} ${item['role']} ${item['status']}'
          .toLowerCase();
      final searchOk = query.isEmpty || text.contains(query);
      return statusOk && departmentOk && searchOk;
    }).toList();
  }

  List<String> get departments {
    final values = members.map((item) => '${item['role']}').toSet().toList()
      ..sort();
    return ['All', ...values];
  }

  int count(String status) =>
      members.where((item) => item['status'] == status).length;

  int get activeFilterCount {
    var total = 0;
    if (selectedStatus.value != 'All') total++;
    if (selectedDepartment.value != 'All') total++;
    return total;
  }

  String get filterSummary {
    final parts = <String>[
      if (selectedStatus.value != 'All') selectedStatus.value,
      if (selectedDepartment.value != 'All') selectedDepartment.value,
    ];
    return parts.isEmpty ? 'All team members' : parts.join(' · ');
  }

  @override
  void onInit() {
    super.onInit();
    fetchTeam();
  }

  Future<void> fetchTeam() async {
    try {
      isLoading(true);
      errorMessage(null);
      final response = await ApiClient.instance.get(ApiList.teamAttendance);
      members.assignAll(
        (response.data['data'] as List? ?? const [])
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList(),
      );
    } on DioException catch (e) {
      debugPrint('TEAM_ATTENDANCE error: $e');
      errorMessage(e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout ||
              e.type == DioExceptionType.sendTimeout
          ? 'Connection timed out. Please check your network and try again.'
          : ApiClient.extractError(e, fallback: 'Failed to load team attendance.'));
    } catch (e) {
      debugPrint('TEAM_ATTENDANCE unexpected error: $e');
      errorMessage('Something went wrong. Tap to retry.');
    } finally {
      isLoading(false);
    }
  }

  void setStatus(String value) => selectedStatus(value);
  void setDepartment(String value) => selectedDepartment(value);
  void setSearchQuery(String value) => searchQuery(value.trim().toLowerCase());
  void toggleFilters() => filtersExpanded.toggle();
  void collapseFilters() => filtersExpanded(false);

  void clearFilters() {
    selectedStatus('All');
    selectedDepartment('All');
  }

  void exportReport() {
    AppToast.pending(
      'Export started',
      'Today team attendance CSV is being prepared.',
    );
  }
}
