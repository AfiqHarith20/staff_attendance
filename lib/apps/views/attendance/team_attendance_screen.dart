import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/team_attendance_controller/team_attendance_controller.dart';
import 'package:staff_attendance/widgets/app_page_widgets.dart';

class TeamAttendanceScreen extends GetView<TeamAttendanceController> {
  final bool showBackButton;
  const TeamAttendanceScreen({super.key, this.showBackButton = true});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<TeamAttendanceController>()) {
      Get.put(TeamAttendanceController());
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: AppPageHeader(
                title: 'Team Attendance',
                showBackButton: showBackButton,
                actions: [
                  IconButton(
                    tooltip: 'Export',
                    onPressed: controller.exportReport,
                    icon: const Icon(Icons.ios_share_rounded),
                  ),
                ],
              ),
            ),
            const _SearchBar(),
            _TeamFilters(isDark: isDark),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                return NotificationListener<ScrollUpdateNotification>(
                  onNotification: (notification) {
                    if ((notification.scrollDelta ?? 0) > 4) {
                      controller.collapseFilters();
                    }
                    return false;
                  },
                  child: RefreshIndicator(
                    onRefresh: controller.fetchTeam,
                    color: const Color(0xFF185FA5),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      children: [
                        _TeamHero(isDark: isDark),
                        const SizedBox(height: 16),
                        _StaffListHeader(isDark: isDark),
                        const SizedBox(height: 10),
                        if (controller.filtered.isEmpty)
                          _EmptyTeamState(isDark: isDark)
                        else
                          ...controller.filtered.map(
                            (item) => _MemberCard(item: item, isDark: isDark),
                          ),
                      ],
                    ),
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

class _SearchBar extends GetView<TeamAttendanceController> {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: AppSearchField(
        onChanged: controller.setSearchQuery,
        hintText: 'Search staff or department',
      ),
    );
  }
}

class _TeamFilters extends GetView<TeamAttendanceController> {
  final bool isDark;
  const _TeamFilters({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final muted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: _teamCardDecoration(isDark),
      child: Obx(() {
        final activeCount = controller.activeFilterCount;
        final expanded = controller.filtersExpanded.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: controller.toggleFilters,
              borderRadius: BorderRadius.circular(12),
              child: Row(
                children: [
                  Icon(
                    Icons.tune_rounded,
                    size: 18,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activeCount == 0
                              ? 'Filters'
                              : 'Filters · $activeCount active',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        if (!expanded) ...[
                          const SizedBox(height: 2),
                          Text(
                            controller.filterSummary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: muted,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (expanded)
                    TextButton(
                      onPressed: activeCount == 0
                          ? null
                          : controller.clearFilters,
                      child: const Text('Reset'),
                    ),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: const Icon(Icons.keyboard_arrow_down_rounded),
                  ),
                ],
              ),
            ),
            AnimatedCrossFade(
              firstChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  _FilterSectionLabel(label: 'Attendance status', color: muted),
                  const SizedBox(height: 8),
                  _FilterChipRow(
                    values: controller.statuses,
                    selected: controller.selectedStatus.value,
                    onChanged: controller.setStatus,
                    countFor: controller.count,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 14),
                  _FilterSectionLabel(label: 'Department', color: muted),
                  const SizedBox(height: 8),
                  _FilterChipRow(
                    values: controller.departments,
                    selected: controller.selectedDepartment.value,
                    onChanged: controller.setDepartment,
                    isDark: isDark,
                    filledWhenSelected: false,
                  ),
                ],
              ),
              secondChild: const SizedBox(width: double.infinity),
              crossFadeState: expanded
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 180),
              firstCurve: Curves.easeOutCubic,
              secondCurve: Curves.easeOutCubic,
              sizeCurve: Curves.easeOutCubic,
            ),
          ],
        );
      }),
    );
  }
}

class _FilterSectionLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _FilterSectionLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        color: color,
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.7,
      ),
    );
  }
}

class _FilterChipRow extends StatelessWidget {
  final List<String> values;
  final String selected;
  final ValueChanged<String> onChanged;
  final int Function(String value)? countFor;
  final bool isDark;
  final bool filledWhenSelected;

  const _FilterChipRow({
    required this.values,
    required this.selected,
    required this.onChanged,
    required this.isDark,
    this.countFor,
    this.filledWhenSelected = true,
  });

  @override
  Widget build(BuildContext context) {
    final selectedColor = filledWhenSelected
        ? const Color(0xFF185FA5)
        : isDark
        ? const Color(0xFF1A3556)
        : const Color(0xFFE6F1FB);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: values.map((value) {
          final active = selected == value;
          final count = countFor == null || value == 'All'
              ? null
              : countFor!(value);
          final label = count == null ? value : '$value $count';
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              selected: active,
              selectedColor: selectedColor,
              label: Text(label),
              onSelected: (_) => onChanged(value),
              avatar: active
                  ? Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: filledWhenSelected
                          ? Colors.white
                          : const Color(0xFF185FA5),
                    )
                  : null,
              labelStyle: TextStyle(
                color: active && filledWhenSelected
                    ? Colors.white
                    : active
                    ? isDark
                          ? const Color(0xFFE6F1FB)
                          : const Color(0xFF185FA5)
                    : isDark
                    ? const Color(0xFFCBD5E1)
                    : const Color(0xFF475569),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TeamHero extends GetView<TeamAttendanceController> {
  final bool isDark;
  const _TeamHero({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final total = controller.members.length;
    final activeToday =
        controller.count('Present') +
        controller.count('Late') +
        controller.count('Remote');
    final exceptions = controller.count('Late') + controller.count('Absent');
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF123F6B), Color(0xFF0F172A)]
              : const [Color(0xFF185FA5), Color(0xFF4DA3E8)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF185FA5).withValues(alpha: 0.22),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.groups_rounded, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today team status',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Live attendance visibility for managers',
                      style: TextStyle(color: Color(0xFFDCEEFF), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _HeroMetric(label: 'Active now', value: '$activeToday'),
              _HeroMetric(label: 'Total staff', value: '$total'),
              _HeroMetric(
                label: 'Exceptions',
                value: '$exceptions',
                isLast: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;
  const _HeroMetric({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(right: isLast ? 0 : 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.78),
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StaffListHeader extends GetView<TeamAttendanceController> {
  final bool isDark;
  const _StaffListHeader({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Staff today',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Obx(
          () => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF185FA5).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '${controller.filtered.length} shown',
              style: const TextStyle(
                color: Color(0xFF185FA5),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyTeamState extends StatelessWidget {
  final bool isDark;
  const _EmptyTeamState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(
            Icons.search_off_rounded,
            color: Color(0xFF94A3B8),
            size: 34,
          ),
          const SizedBox(height: 10),
          Text(
            'No staff match these filters',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Try clearing a filter or searching another department.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isDark;
  const _MemberCard({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor('${item['status']}');
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showMemberDetail(context, color),
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            padding: const EdgeInsets.all(14),
            decoration: _teamCardDecoration(isDark),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      '${item['initials']}',
                      style: TextStyle(
                        color: color,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${item['name']}',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          AppStatusBadge(
                            label: '${item['status']}',
                            color: color,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _InfoPill(
                            icon: Icons.business_rounded,
                            label: '${item['role']}',
                            isDark: isDark,
                          ),
                          _InfoPill(
                            icon: Icons.schedule_rounded,
                            label: '${item['time']}',
                            isDark: isDark,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 15,
                            color: color,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${item['location']} · ${item['distance']}',
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            '${item['flag']}',
                            style: TextStyle(
                              color: color,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMemberDetail(BuildContext context, Color color) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.14),
                  child: Text(
                    '${item['initials']}',
                    style: TextStyle(color: color, fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${item['name']}',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                AppStatusBadge(label: '${item['status']}', color: color),
              ],
            ),
            const SizedBox(height: 16),
            AppDetailLine(label: 'Department', value: '${item['role']}'),
            AppDetailLine(label: 'Status', value: '${item['status']}'),
            AppDetailLine(label: 'Check-in', value: '${item['time']}'),
            AppDetailLine(label: 'GPS location', value: '${item['location']}'),
            AppDetailLine(
              label: 'Distance from office',
              value: '${item['distance']}',
            ),
            AppDetailLine(label: 'Audit flag', value: '${item['flag']}'),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.map_rounded),
              label: const Text('View map / audit trail'),
              style: FilledButton.styleFrom(backgroundColor: color),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Present':
        return const Color(0xFF16A34A);
      case 'Late':
        return const Color(0xFFF59E0B);
      case 'On leave':
        return const Color(0xFF185FA5);
      case 'Remote':
        return const Color(0xFF7F77DD);
      default:
        return const Color(0xFFDC2626);
    }
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;

  const _InfoPill({
    required this.icon,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _teamCardDecoration(bool isDark) => BoxDecoration(
  color: isDark ? const Color(0xFF1E293B) : Colors.white,
  borderRadius: BorderRadius.circular(18),
  border: Border.all(
    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
  ),
);
