import 'package:get/get.dart';
import 'package:staff_attendance/api/api_client.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../apps/models/calendar_event_model.dart';

class CalendarController extends GetxController {
  final focusedDay = DateTime.now().obs;
  final selectedDay = DateTime.now().obs;
  final calendarFormat = CalendarFormat.month.obs;
  final isLoading = false.obs;
  final errorMsg = ''.obs;

  // All events keyed by normalised date (no time)
  final _eventMap = <DateTime, List<CalendarEvent>>{}.obs;

  // Active filter — null = show all
  final activeFilter = Rxn<CalendarEventType>();

  // Events for the selected day (filtered)
  List<CalendarEvent> get selectedEvents {
    final events = _eventMap[_normalise(selectedDay.value)] ?? [];
    final filter = activeFilter.value;
    if (filter == null) return events;
    return events.where((e) => e.type == filter).toList();
  }

  // Dot indicators for a given day (used by table_calendar)
  List<CalendarEvent> eventsForDay(DateTime day) =>
      _eventMap[_normalise(day)] ?? [];

  @override
  void onInit() {
    super.onInit();
    _seedMalaysianHolidays();
    fetchEvents();
  }

  // ── Fetch from API ──────────────────────────────────────────────────────
  Future<void> fetchEvents() async {
    try {
      isLoading(true);
      errorMsg('');

      final response = await ApiClient.instance.get(
        '/calendar/events',
        queryParameters: {
          'month': focusedDay.value.month,
          'year': focusedDay.value.year,
        },
      );

      final list = response.data['data'] as List? ?? [];
      final parsed = list
          .map((e) => CalendarEvent.fromJson(e as Map<String, dynamic>))
          .toList();

      _addEvents(parsed);
    } catch (_) {
      // Non-fatal — show seeded holidays at minimum
    } finally {
      isLoading(false);
    }
  }

  void _addEvents(List<CalendarEvent> events) {
    for (final event in events) {
      // Expand multi-day events into each day
      final days = event.isMultiDay
          ? _daysBetween(event.date, event.endDate!)
          : [event.date];
      for (final day in days) {
        final key = _normalise(day);
        final existing = _eventMap[key] ?? const <CalendarEvent>[];
        final alreadyExists = existing.any(
          (item) =>
              item.id == event.id &&
              item.title == event.title &&
              _normalise(item.date) == _normalise(event.date),
        );
        if (alreadyExists) continue;
        _eventMap[key] = [...existing, event];
      }
    }
    _eventMap.refresh();
  }

  // ── Navigation ──────────────────────────────────────────────────────────
  void onDaySelected(DateTime day, DateTime focused) {
    selectedDay(day);
    focusedDay(focused);
  }

  void onPageChanged(DateTime focused) {
    focusedDay(focused);
    fetchEvents(); // reload events for new month
  }

  void goToPreviousMonth() {
    final current = focusedDay.value;
    final previous = DateTime(current.year, current.month - 1, 1);
    focusedDay(previous);
    selectedDay(previous);
    fetchEvents();
  }

  void goToNextMonth() {
    final current = focusedDay.value;
    final next = DateTime(current.year, current.month + 1, 1);
    focusedDay(next);
    selectedDay(next);
    fetchEvents();
  }

  void goToToday() {
    final today = DateTime.now();
    focusedDay(today);
    selectedDay(today);
    fetchEvents();
  }

  void toggleFormat() {
    calendarFormat(
      calendarFormat.value == CalendarFormat.month
          ? CalendarFormat.twoWeeks
          : CalendarFormat.month,
    );
  }

  void setFilter(CalendarEventType? type) {
    activeFilter.value = activeFilter.value == type ? null : type;
  }

  // ── Malaysian public holidays 2026 ──────────────────────────────────────
  // Seeded from official Malaysia government / BKPP 2026 public holiday
  // references, including replacement/additional holidays commonly applied in
  // Peninsular Malaysia / Federal Territories for 2026.
  void _seedMalaysianHolidays() {
    final holidays = [
      ('New Year', DateTime(2026, 1, 1)),
      ('Federal Territory Day', DateTime(2026, 2, 1)),
      ('Thaipusam', DateTime(2026, 2, 1)),
      ('Federal Territory Day / Thaipusam Replacement', DateTime(2026, 2, 2)),
      ('Chinese New Year', DateTime(2026, 2, 17)),
      ('Chinese New Year (2)', DateTime(2026, 2, 18)),
      ('Nuzul Al-Quran', DateTime(2026, 3, 7)),
      ('Hari Raya Aidilfitri Additional Holiday', DateTime(2026, 3, 20)),
      ("Hari Raya Aidilfitri", DateTime(2026, 3, 21)),
      ('Hari Raya Aidilfitri (2)', DateTime(2026, 3, 22)),
      ('Hari Raya Aidilfitri Replacement', DateTime(2026, 3, 23)),
      ('Labour Day', DateTime(2026, 5, 1)),
      ("Hari Raya Aidiladha", DateTime(2026, 5, 27)),
      ('Wesak Day', DateTime(2026, 5, 31)),
      ("Yang di-Pertuan Agong's Birthday", DateTime(2026, 6, 1)),
      ('Replacement Holiday', DateTime(2026, 6, 2)),
      ('Awal Muharram', DateTime(2026, 6, 17)),
      ("Prophet's Birthday", DateTime(2026, 8, 25)),
      ('National Day', DateTime(2026, 8, 31)),
      ('Malaysia Day', DateTime(2026, 9, 16)),
      ('Deepavali', DateTime(2026, 10, 29)),
      ('Deepavali Replacement', DateTime(2026, 11, 9)),
      ('Christmas', DateTime(2026, 12, 25)),
    ];

    _addEvents(
      holidays
          .map(
            (h) => CalendarEvent(
              id: 'ph_${h.$1.toLowerCase().replaceAll(' ', '_')}',
              title: h.$1,
              date: h.$2,
              type: CalendarEventType.publicHoliday,
            ),
          )
          .toList(),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────
  DateTime _normalise(DateTime d) => DateTime.utc(d.year, d.month, d.day);

  List<DateTime> _daysBetween(DateTime start, DateTime end) {
    final days = <DateTime>[];
    var current = start;
    while (!current.isAfter(end)) {
      days.add(current);
      current = current.add(const Duration(days: 1));
    }
    return days;
  }

  // Events count for month summary
  int countType(CalendarEventType type) => _eventMap.values
      .expand((list) => list)
      .where(
        (e) =>
            e.type == type &&
            e.date.month == focusedDay.value.month &&
            e.date.year == focusedDay.value.year,
      )
      .length;
}
