enum ShiftType { work, rest, holiday, remote }

class ShiftScheduleModel {
  final String id;
  final DateTime date;
  final String title;
  final String timeLabel;
  final String location;
  final String note;
  final ShiftType type;

  const ShiftScheduleModel({
    required this.id,
    required this.date,
    required this.title,
    required this.timeLabel,
    required this.location,
    required this.note,
    required this.type,
  });

  factory ShiftScheduleModel.fromJson(Map<String, dynamic> json) {
    return ShiftScheduleModel(
      id: json['id'].toString(),
      date: DateTime.parse(json['date'] as String),
      title: json['title'] as String? ?? 'Shift',
      timeLabel: json['time_label'] as String? ?? '',
      location: json['location'] as String? ?? '',
      note: json['note'] as String? ?? '',
      type: ShiftType.values.firstWhere(
        (item) => item.name == json['type'],
        orElse: () => ShiftType.work,
      ),
    );
  }

  int get colorValue {
    switch (type) {
      case ShiftType.work:
        return 0xFF185FA5;
      case ShiftType.rest:
        return 0xFF64748B;
      case ShiftType.holiday:
        return 0xFF16A34A;
      case ShiftType.remote:
        return 0xFF7F77DD;
    }
  }
}
