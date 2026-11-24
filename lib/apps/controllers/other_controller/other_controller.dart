import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:staff_attendance/api/api_client.dart';
import 'package:staff_attendance/apps/routes/api_routes.dart';

class OtherController extends GetxController {
  // ── Feature permissions (set by web admin per user) ──
  final _isAdmin = false.obs;
  final _permissions = <String>[].obs;

  List<String> get permissions => _permissions;

  // is_admin = true means ALL permissions, regardless of permissions[].
  bool hasPermission(String key) =>
      _isAdmin.value || _permissions.contains(key);

  void _loadPermissions() {
    _isAdmin(GetStorage().read<bool>('is_admin') ?? false);
    final raw = GetStorage().read('user_permissions');
    final list = raw is List
        ? raw.map((e) => e.toString()).toList()
        : <String>[];
    _permissions.assignAll(list);
  }

  /// Called after a foreground refresh updates storage with new values
  /// from GET /api/user so the UI reacts without a full reload.
  void refreshPermissions() => _loadPermissions();

  // ── Badge counts ──
  final pendingRequests = 0.obs;   // all request types (leave, OT, correction, claims…)
  final pendingApprovals = 0.obs;  // non-zero for admin accounts only
  final pendingDocuments = 0.obs;
  final unreadAnnouncements = 0.obs;
  final unreadNotifications = 0.obs;
  final payslipReady = false.obs;
  final payslipMonth = ''.obs;
  final nextHoliday = ''.obs; // e.g. "5 Apr"
  final selectedCategory = 'All'.obs;
  final searchQuery = ''.obs;

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadPermissions();
    fetchBadgeCounts();
  }

  Future<void> fetchBadgeCounts() async {
    try {
      isLoading(true);
      final response = await ApiClient.instance.get(ApiList.dashboardBadges);
      final data = response.data['data'] as Map<String, dynamic>;

      pendingRequests(data['my_pending_requests'] as int? ?? 0);
      pendingApprovals(data['pending_approvals'] as int? ?? 0);
      pendingDocuments(data['pending_documents'] as int? ?? 0);
      unreadAnnouncements(data['unread_announcements'] as int? ?? 0);
      unreadNotifications(data['unread_notifications'] as int? ?? 0);
      payslipReady(data['payslip_ready'] as bool? ?? false);
      payslipMonth(data['payslip_month'] as String? ?? '');
      nextHoliday(data['next_holiday_date'] as String? ?? '');
    } catch (_) {
      // non-blocking — badges just won't show
    } finally {
      isLoading(false);
    }
  }

  void setCategory(String value) => selectedCategory(value);
  void setSearchQuery(String value) => searchQuery(value.trim().toLowerCase());
}
