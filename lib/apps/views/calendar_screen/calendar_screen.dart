import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:staff_attendance/widgets/app_page_widgets.dart';

import '../../../../apps/controllers/calendar_controller/calendar_controller.dart';
import '../../../../apps/models/calendar_event_model.dart';

// ── Screen ───────────────────────────────────────────────────────────────────
class CalendarScreen extends GetView<CalendarController> {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _AppBar(isDark: isDark),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.fetchEvents,
                color: const Color(0xFF185FA5),
                child: CustomScrollView(
                  slivers: [
                    // ── Calendar ──
                    SliverToBoxAdapter(child: _CalendarCard(isDark: isDark)),

                    // ── Month summary chips ──
                    SliverToBoxAdapter(child: _MonthSummary(isDark: isDark)),

                    // ── Filter chips ──
                    SliverToBoxAdapter(child: _FilterChips(isDark: isDark)),

                    // ── Selected day events ──
                    SliverToBoxAdapter(
                      child: _SelectedDayHeader(isDark: isDark),
                    ),

                    // ── Event list ──
                    _EventList(isDark: isDark),

                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────
// APP BAR
// ─────────────────────────────────────
class _AppBar extends GetView<CalendarController> {
  final bool isDark;
  const _AppBar({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          const AppBackButton(),
          const SizedBox(width: 12),
          Expanded(
            child: Obx(
              () => Text(
                DateFormat('MMMM yyyy').format(controller.focusedDay.value),
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _MonthNavButton(
            isDark: isDark,
            icon: Icons.chevron_left_rounded,
            onTap: controller.goToPreviousMonth,
          ),
          const SizedBox(width: 6),
          _MonthNavButton(
            isDark: isDark,
            icon: Icons.chevron_right_rounded,
            onTap: controller.goToNextMonth,
          ),
          const SizedBox(width: 8),
          // Toggle month/2-week
          Obx(
            () => GestureDetector(
              onTap: controller.toggleFormat,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Text(
                  controller.calendarFormat.value == CalendarFormat.month
                      ? 'Month'
                      : '2 Weeks',
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────
// CALENDAR CARD
// ─────────────────────────────────────
class _CalendarCard extends GetView<CalendarController> {
  final bool isDark;
  const _CalendarCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF185FA5).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.swipe_rounded,
                      size: 14,
                      color: Color(0xFF185FA5),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Swipe or use arrows',
                      style: TextStyle(
                        color: Color(0xFF185FA5),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: controller.goToToday,
                icon: const Icon(Icons.today_rounded, size: 16),
                label: const Text('Today'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF185FA5),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Obx(
            () => TableCalendar<CalendarEvent>(
              firstDay: DateTime(2024, 1, 1),
              lastDay: DateTime(2027, 12, 31),
              focusedDay: controller.focusedDay.value,
              calendarFormat: controller.calendarFormat.value,
              selectedDayPredicate: (day) =>
                  isSameDay(controller.selectedDay.value, day),
              eventLoader: controller.eventsForDay,
              onDaySelected: controller.onDaySelected,
              onPageChanged: controller.onPageChanged,
              onFormatChanged: (f) => controller.calendarFormat(f),
              startingDayOfWeek: StartingDayOfWeek.monday,
              headerVisible: false, // we use custom header
              daysOfWeekHeight: 28,
              rowHeight: 46,

              calendarStyle: CalendarStyle(
                // Today
                todayDecoration: BoxDecoration(
                  color: const Color(0xFF185FA5).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF185FA5),
                  fontWeight: FontWeight.w700,
                ),
                // Selected
                selectedDecoration: BoxDecoration(
                  color: Color(0xFF185FA5),
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
                defaultTextStyle: TextStyle(
                  color: isDark
                      ? const Color(0xFFE2E8F0)
                      : const Color(0xFF1E293B),
                  fontSize: 13,
                ),
                weekendTextStyle: TextStyle(
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                  fontSize: 13,
                ),
                outsideTextStyle: TextStyle(
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFCBD5E1),
                  fontSize: 13,
                ),
                markerDecoration: const BoxDecoration(shape: BoxShape.circle),
                markersMaxCount: 4,
                markerSize: 5,
                markerMargin: const EdgeInsets.symmetric(horizontal: 1),
                cellMargin: const EdgeInsets.all(4),
              ),

              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  if (events.isEmpty) return null;
                  final seen = <CalendarEventType>{};
                  final dots = <Widget>[];
                  for (final e in events) {
                    if (seen.contains(e.type)) continue;
                    seen.add(e.type);
                    dots.add(
                      Container(
                        width: 5,
                        height: 5,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          color: Color(e.colorValue),
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                    if (dots.length >= 4) break;
                  }
                  return Positioned(
                    bottom: 2,
                    child: Row(mainAxisSize: MainAxisSize.min, children: dots),
                  );
                },
                dowBuilder: (context, day) {
                  final text = DateFormat.E().format(day).substring(0, 1);
                  final isWeekend =
                      day.weekday == DateTime.saturday ||
                      day.weekday == DateTime.sunday;
                  return Center(
                    child: Text(
                      text,
                      style: TextStyle(
                        color: isWeekend
                            ? isDark
                                  ? const Color(0xFF64748B)
                                  : const Color(0xFF94A3B8)
                            : isDark
                            ? const Color(0xFF475569)
                            : const Color(0xFF94A3B8),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthNavButton extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final VoidCallback onTap;

  const _MonthNavButton({
    required this.isDark,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────
// MONTH SUMMARY
// ─────────────────────────────────────
class _MonthSummary extends GetView<CalendarController> {
  final bool isDark;
  const _MonthSummary({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Row(
          children: [
            _SummaryChip(
              label: 'Leave',
              count: controller.countType(CalendarEventType.leaveApproved),
              color: const Color(0xFF16A34A),
              isDark: isDark,
            ),
            const SizedBox(width: 8),
            _SummaryChip(
              label: 'Holidays',
              count: controller.countType(CalendarEventType.publicHoliday),
              color: const Color(0xFF7F77DD),
              isDark: isDark,
            ),
            const SizedBox(width: 8),
            _SummaryChip(
              label: 'Events',
              count: controller.countType(CalendarEventType.companyEvent),
              color: const Color(0xFF185FA5),
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final bool isDark;
  const _SummaryChip({
    required this.label,
    required this.count,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            '$count $label',
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────
// FILTER CHIPS
// ─────────────────────────────────────
class _FilterChips extends GetView<CalendarController> {
  final bool isDark;
  const _FilterChips({required this.isDark});

  static const filters = [
    (null, 'All'),
    (CalendarEventType.leaveApproved, 'My Leave'),
    (CalendarEventType.leavePending, 'Pending'),
    (CalendarEventType.publicHoliday, 'Holidays'),
    (CalendarEventType.companyEvent, 'Events'),
    (CalendarEventType.birthday, 'Birthdays'),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final active = controller.activeFilter.value;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Row(
          children: filters.map((f) {
            final isActive = active == f.$1;
            final color = _filterColor(f.$1);
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => controller.setFilter(f.$1),
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? color : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isActive
                          ? color
                          : isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Text(
                    f.$2,
                    style: TextStyle(
                      color: isActive
                          ? Colors.white
                          : isDark
                          ? const Color(0xFF64748B)
                          : const Color(0xFF94A3B8),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  Color _filterColor(CalendarEventType? type) {
    if (type == null) return const Color(0xFF185FA5);
    return Color(CalendarEvent.colors[type] ?? 0xFF185FA5);
  }
}

// ─────────────────────────────────────
// SELECTED DAY HEADER
// ─────────────────────────────────────
class _SelectedDayHeader extends GetView<CalendarController> {
  final bool isDark;
  const _SelectedDayHeader({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final day = controller.selectedDay.value;
      final events = controller.selectedEvents;
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('EEE, d MMM').format(day),
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (events.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF185FA5).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${events.length} ${events.length == 1 ? 'event' : 'events'}',
                  style: const TextStyle(
                    color: Color(0xFF378ADD),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}

// ─────────────────────────────────────
// EVENT LIST
// ─────────────────────────────────────
class _EventList extends GetView<CalendarController> {
  final bool isDark;
  const _EventList({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final events = controller.selectedEvents;
      final loading = controller.isLoading.value;

      if (loading) {
        return const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          ),
        );
      }

      if (events.isEmpty) {
        return SliverToBoxAdapter(child: _EmptyDay(isDark: isDark));
      }

      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, i) => _EventCard(event: events[i], isDark: isDark),
          childCount: events.length,
        ),
      );
    });
  }
}

// ─────────────────────────────────────
// EVENT CARD
// ─────────────────────────────────────
class _EventCard extends StatelessWidget {
  final CalendarEvent event;
  final bool isDark;
  const _EventCard({required this.event, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = Color(event.colorValue);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          // Color accent bar
          Container(
            width: 4,
            height: 72,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                bottomLeft: Radius.circular(14),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Icon
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_iconFor(event.type), color: color, size: 18),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        event.typeLabel,
                        style: TextStyle(
                          color: color,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.05,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  event.title,
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFFE2E8F0)
                        : const Color(0xFF1E293B),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (event.subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    event.subtitle!,
                    style: TextStyle(
                      color: isDark
                          ? const Color(0xFF475569)
                          : const Color(0xFF94A3B8),
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (event.isMultiDay) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${DateFormat('d MMM').format(event.date)} – '
                    '${DateFormat('d MMM').format(event.endDate!)}',
                    style: TextStyle(
                      color: isDark
                          ? const Color(0xFF475569)
                          : const Color(0xFF94A3B8),
                      fontSize: 10,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  IconData _iconFor(CalendarEventType type) {
    switch (type) {
      case CalendarEventType.leaveApproved:
        return Icons.beach_access_rounded;
      case CalendarEventType.leavePending:
        return Icons.hourglass_top_rounded;
      case CalendarEventType.leaveRejected:
        return Icons.cancel_outlined;
      case CalendarEventType.companyEvent:
        return Icons.groups_rounded;
      case CalendarEventType.publicHoliday:
        return Icons.flag_rounded;
      case CalendarEventType.birthday:
        return Icons.cake_rounded;
    }
  }
}

// ─────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────
class _EmptyDay extends StatelessWidget {
  final bool isDark;
  const _EmptyDay({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Column(
        children: [
          Icon(
            Icons.event_available_rounded,
            size: 48,
            color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
          ),
          const SizedBox(height: 12),
          Text(
            'No events on this day',
            style: TextStyle(
              color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap any date to see events',
            style: TextStyle(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
