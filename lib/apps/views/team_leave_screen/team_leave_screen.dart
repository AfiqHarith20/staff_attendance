import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/team_leave_controller/team_leave_controller.dart';
import 'package:staff_attendance/apps/models/team_leave_entry_model.dart';
import 'package:staff_attendance/apps/themes/app_colors.dart';
import 'package:staff_attendance/widgets/app_page_widgets.dart';

const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

const _leaveColors = [
  Color(0xFF185FA5),
  Color(0xFF7F77DD),
  Color(0xFF16A34A),
  Color(0xFFF59E0B),
  Color(0xFFDC2626),
  Color(0xFF0284C7),
];

class TeamLeaveScreen extends GetView<TeamLeaveController> {
  const TeamLeaveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final text = isDark ? Colors.white : const Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Obx(() {
          if (controller.hasError.value) {
            return _ErrorRetry(
              isDark: isDark,
              onRetry: controller.fetchLeaves,
            );
          }

          final month = controller.focusedMonth.value;
          final cells = _buildCells(month);

          return RefreshIndicator(
            onRefresh: controller.fetchLeaves,
            color: AppColors.primary,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                AppPageHeader(title: 'Team Leave Calendar'),
                const SizedBox(height: 12),
                // Month navigator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: controller.previousMonth,
                      icon: const Icon(Icons.chevron_left_rounded),
                      color: text,
                    ),
                    Text(
                      _monthLabel(month),
                      style: TextStyle(
                        color: text,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    IconButton(
                      onPressed: controller.nextMonth,
                      icon: const Icon(Icons.chevron_right_rounded),
                      color: text,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Weekday headers
                Row(
                  children: _weekdays
                      .map(
                        (d) => Expanded(
                          child: Center(
                            child: Text(
                              d,
                              style: TextStyle(
                                color: text.withOpacity(0.4),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 4),
                // Calendar grid
                if (controller.isLoading.value)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary, strokeWidth: 2.5),
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      childAspectRatio: 0.75,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 2,
                    ),
                    itemCount: cells.length,
                    itemBuilder: (_, i) {
                      final day = cells[i];
                      if (day == null) return const SizedBox.shrink();
                      final leaves =
                          controller.leavesOnDay(day);
                      final isToday = _isToday(day);
                      return _DayCell(
                        day: day,
                        leaves: leaves,
                        isToday: isToday,
                        isDark: isDark,
                        onTap: leaves.isNotEmpty
                            ? () => _showLeaveDetails(
                                context, day, leaves, isDark)
                            : null,
                      );
                    },
                  ),
                const SizedBox(height: 20),
                // List of leaves this month
                if (controller.entries.isNotEmpty) ...[
                  Text(
                    'Leaves This Month',
                    style: TextStyle(
                      color: text,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...controller.entries.map(
                    (e) => _LeaveRow(entry: e, isDark: isDark),
                  ),
                ] else if (!controller.isLoading.value)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        'No approved leaves this month.',
                        style: TextStyle(color: text.withOpacity(0.4)),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  List<DateTime?> _buildCells(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    // weekday: 1=Mon..7=Sun
    final leadingBlanks = (firstDay.weekday - 1) % 7;
    final cells = <DateTime?>[
      ...List.filled(leadingBlanks, null),
      ...List.generate(
          daysInMonth, (i) => DateTime(month.year, month.month, i + 1)),
    ];
    return cells;
  }

  String _monthLabel(DateTime m) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[m.month - 1]} ${m.year}';
  }

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  void _showLeaveDetails(
    BuildContext context,
    DateTime day,
    List<TeamLeaveEntryModel> leaves,
    bool isDark,
  ) {
    final sheetBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final text = isDark ? Colors.white : const Color(0xFF0F172A);
    showModalBottomSheet(
      context: context,
      backgroundColor: sheetBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.25,
        maxChildSize: 0.85,
        expand: false,
        builder: (_, scrollController) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                '${day.day} · On Leave (${leaves.length})',
                style: TextStyle(
                  color: text,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                itemCount: leaves.length,
                itemBuilder: (_, idx) {
                  final e = leaves[idx];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: AppColors.primary.withOpacity(0.15),
                          child: Text(
                            e.userName.isNotEmpty
                                ? e.userName[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                e.userName,
                                style: TextStyle(
                                  color: text,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                '${e.type} · ${e.days} day${e.days == 1 ? '' : 's'}',
                                style: TextStyle(
                                  color: text.withOpacity(0.5),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (e.userDepartment != null)
                          Text(
                            e.userDepartment!,
                            style: TextStyle(
                                color: text.withOpacity(0.4), fontSize: 11),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.leaves,
    required this.isToday,
    required this.isDark,
    this.onTap,
  });

  final DateTime day;
  final List<TeamLeaveEntryModel> leaves;
  final bool isToday;
  final bool isDark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = isDark ? Colors.white : const Color(0xFF0F172A);
    final hasLeaves = leaves.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isToday
              ? AppColors.primary.withOpacity(0.15)
              : hasLeaves
                  ? const Color(0xFF7F77DD).withOpacity(0.08)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: isToday
              ? Border.all(color: AppColors.primary, width: 1.5)
              : null,
        ),
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              day.day.toString(),
              style: TextStyle(
                color: isToday ? AppColors.primary : text.withOpacity(0.8),
                fontWeight:
                    isToday ? FontWeight.w700 : FontWeight.w400,
                fontSize: 12,
              ),
            ),
            if (hasLeaves) ...[
              const SizedBox(height: 2),
              Wrap(
                spacing: 1,
                runSpacing: 1,
                children: leaves
                    .take(3)
                    .toList()
                    .asMap()
                    .entries
                    .map(
                      (e) => Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: _leaveColors[
                              e.key % _leaveColors.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LeaveRow extends StatelessWidget {
  const _LeaveRow({required this.entry, required this.isDark});

  final TeamLeaveEntryModel entry;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final text = isDark ? Colors.white : const Color(0xFF0F172A);
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary.withOpacity(0.15),
            child: Text(
              entry.userName.isNotEmpty
                  ? entry.userName[0].toUpperCase()
                  : '?',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.userName,
                  style: TextStyle(
                    color: text,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  '${entry.type} · ${entry.startDate} – ${entry.endDate}',
                  style:
                      TextStyle(color: text.withOpacity(0.5), fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF7F77DD).withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${entry.days}d',
              style: const TextStyle(
                color: Color(0xFF7F77DD),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  const _ErrorRetry({required this.isDark, required this.onRetry});

  final bool isDark;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded,
              size: 48, color: Colors.red.withOpacity(0.6)),
          const SizedBox(height: 12),
          Text(
            'Failed to load team leave',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
