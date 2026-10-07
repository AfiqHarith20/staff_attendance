enum CalendarEventType {
  leaveApproved,
  leavePending,
  leaveRejected,
  companyEvent,
  publicHoliday,
  birthday,
}

class CalendarEvent {
  final String id;
  final String title;
  final String? subtitle;
  final DateTime date;
  final DateTime? endDate; // for multi-day events
  final CalendarEventType type;

  const CalendarEvent({
    required this.id,
    required this.title,
    this.subtitle,
    required this.date,
    this.endDate,
    required this.type,
  });

  factory CalendarEvent.fromJson(Map<String, dynamic> j) => CalendarEvent(
    id: j['id'].toString(),
    title: j['title'] as String,
    subtitle: j['subtitle'] as String?,
    date: DateTime.parse(j['date'] as String),
    endDate: j['end_date'] != null
        ? DateTime.parse(j['end_date'] as String)
        : null,
    type: CalendarEventType.values.firstWhere(
      (e) => e.name == j['type'],
      orElse: () => CalendarEventType.companyEvent,
    ),
  );

  // Color per type
  static const Map<CalendarEventType, int> colors = {
    CalendarEventType.leaveApproved: 0xFF16A34A,
    CalendarEventType.leavePending: 0xFFF59E0B,
    CalendarEventType.leaveRejected: 0xFFDC2626,
    CalendarEventType.companyEvent: 0xFF185FA5,
    CalendarEventType.publicHoliday: 0xFF7F77DD,
    CalendarEventType.birthday: 0xFFD85A30,
  };

  static const Map<CalendarEventType, String> _labels = {
    CalendarEventType.leaveApproved: 'Leave',
    CalendarEventType.leavePending: 'Pending',
    CalendarEventType.leaveRejected: 'Rejected',
    CalendarEventType.companyEvent: 'Event',
    CalendarEventType.publicHoliday: 'Holiday',
    CalendarEventType.birthday: 'Birthday',
  };

  int get colorValue => colors[type]!;
  String get typeLabel => _labels[type]!;
  bool get isMultiDay => endDate != null && !endDate!.isAtSameMomentAs(date);
}
