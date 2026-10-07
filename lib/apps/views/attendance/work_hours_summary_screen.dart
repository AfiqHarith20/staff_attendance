import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/work_hours_summary_controller/work_hours_summary_controller.dart';
import 'package:staff_attendance/widgets/app_page_widgets.dart';

class WorkHoursSummaryScreen extends GetView<WorkHoursSummaryController> {
  const WorkHoursSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _Header(title: 'Work Hours Summary', isDark: isDark),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Obx(
                () => SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'Weekly', label: Text('Weekly')),
                    ButtonSegment(value: 'Monthly', label: Text('Monthly')),
                  ],
                  selected: {controller.period.value},
                  onSelectionChanged: (value) =>
                      controller.setPeriod(value.first),
                ),
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                final summary = controller.summary;
                return RefreshIndicator(
                  onRefresh: controller.fetchSummary,
                  color: const Color(0xFF185FA5),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    children: [
                      Row(
                        children: [
                          _MetricTile(
                            label: 'Total',
                            value: '${summary['total_hours'] ?? '0h'}',
                            color: const Color(0xFF185FA5),
                            isDark: isDark,
                          ),
                          const SizedBox(width: 10),
                          _MetricTile(
                            label: 'Overtime',
                            value: '${summary['overtime_hours'] ?? '0h'}',
                            color: const Color(0xFFF59E0B),
                            isDark: isDark,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _MetricTile(
                            label: 'Late mins',
                            value: '${summary['late_minutes'] ?? 0}',
                            color: const Color(0xFFDC2626),
                            isDark: isDark,
                          ),
                          const SizedBox(width: 10),
                          _MetricTile(
                            label: 'Score',
                            value: '${summary['attendance_score'] ?? 0}%',
                            color: const Color(0xFF16A34A),
                            isDark: isDark,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _SectionTitle('Daily breakdown', isDark: isDark),
                      const SizedBox(height: 8),
                      ...controller.daily.map(
                        (item) => _DailyRow(item: item, isDark: isDark),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isDark;
  const _MetricTile({
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: _cardDecoration(isDark),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyRow extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isDark;
  const _DailyRow({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final score = item['score'] as int? ?? 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(isDark),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item['day']}',
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${item['hours']} · OT ${item['overtime']} · Late ${item['late_minutes']}m',
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 44,
            child: Text(
              '$score%',
              textAlign: TextAlign.end,
              style: TextStyle(
                color: score >= 90
                    ? const Color(0xFF16A34A)
                    : const Color(0xFFF59E0B),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final bool isDark;
  const _SectionTitle(this.title, {required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: isDark ? Colors.white : const Color(0xFF0F172A),
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final bool isDark;
  const _Header({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          const AppBackButton(),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _cardDecoration(bool isDark) => BoxDecoration(
  color: isDark ? const Color(0xFF1E293B) : Colors.white,
  borderRadius: BorderRadius.circular(8),
  border: Border.all(
    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
  ),
);
