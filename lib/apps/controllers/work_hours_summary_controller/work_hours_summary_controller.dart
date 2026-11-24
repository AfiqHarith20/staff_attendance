import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:staff_attendance/api/api_client.dart';
import 'package:staff_attendance/apps/routes/api_routes.dart';
import 'package:staff_attendance/widgets/app_toast.dart';

class WorkHoursSummaryController extends GetxController {
  final isLoading = false.obs;
  final hasError = false.obs;
  final period = 'Weekly'.obs;
  final periodOffset = 0.obs; // 0 = current, -1 = previous, etc.
  final summary = <String, dynamic>{}.obs;
  final daily = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchSummary();
  }

  // ── Period label shown in the navigator ────────────────────────────────────

  String get periodLabel {
    if (periodOffset.value == 0) {
      return period.value == 'Weekly' ? 'This Week' : 'This Month';
    }
    final now = DateTime.now();
    if (period.value == 'Weekly') {
      final monday = _weekStart(now, periodOffset.value);
      final sunday = monday.add(const Duration(days: 6));
      return '${DateFormat('d MMM').format(monday)} – ${DateFormat('d MMM yyyy').format(sunday)}';
    } else {
      final m = DateTime(now.year, now.month + periodOffset.value, 1);
      return DateFormat('MMMM yyyy').format(m);
    }
  }

  bool get canGoNext => periodOffset.value < 0;

  // ── Navigation ─────────────────────────────────────────────────────────────

  void goPrevious() {
    periodOffset(periodOffset.value - 1);
    fetchSummary();
  }

  void goNext() {
    if (!canGoNext) return;
    periodOffset(periodOffset.value + 1);
    fetchSummary();
  }

  Future<void> fetchSummary() async {
    try {
      isLoading(true);
      hasError(false);
      final params = <String, dynamic>{
        'period': period.value.toLowerCase(),
      };
      if (periodOffset.value != 0) {
        params['start_date'] = _startDate;
      }
      final response = await ApiClient.instance.get(
        ApiList.workHoursSummary,
        queryParameters: params,
      );
      final data = response.data['data'] as Map<String, dynamic>? ?? {};
      summary.assignAll(data);
      daily.assignAll(
        (data['daily'] as List? ?? const [])
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList(),
      );
    } on DioException catch (e) {
      hasError(true);
      AppToast.failed(
        'Failed to load',
        ApiClient.extractError(e, fallback: 'Could not fetch work hours. Pull down to retry.'),
      );
    } catch (_) {
      hasError(true);
    } finally {
      isLoading(false);
    }
  }

  void setPeriod(String value) {
    period(value);
    periodOffset(0);
    fetchSummary();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String get _startDate {
    final now = DateTime.now();
    if (period.value == 'Weekly') {
      final monday = _weekStart(now, periodOffset.value);
      return monday.toIso8601String().split('T').first;
    } else {
      final m = DateTime(now.year, now.month + periodOffset.value, 1);
      return m.toIso8601String().split('T').first;
    }
  }

  DateTime _weekStart(DateTime now, int offset) {
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return monday.subtract(Duration(days: offset.abs() * 7));
  }

  // Parses "7h 30m", "8h", "45m", or a raw number into fractional hours.
  static double parseHours(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    final s = value.toString();
    double total = 0;
    final h = RegExp(r'(\d+)h').firstMatch(s);
    final m = RegExp(r'(\d+)m').firstMatch(s);
    if (h != null) total += double.parse(h.group(1)!);
    if (m != null) total += double.parse(m.group(1)!) / 60;
    return total;
  }
}
