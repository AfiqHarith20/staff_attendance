enum AttendanceRecordStatus { present, late, absent, leave, issue }

class AttendanceRecordModel {
  final String id;
  final DateTime date;
  final DateTime? checkInAt;
  final DateTime? checkOutAt;
  final String checkInLocation;
  final String checkOutLocation;
  final double distanceM;
  final AttendanceRecordStatus status;
  final bool isLate;
  final bool isEarlyCheckout;
  final String workingHoursLabel;
  final String remarks;
  final String auditStatus;

  const AttendanceRecordModel({
    required this.id,
    required this.date,
    required this.checkInAt,
    required this.checkOutAt,
    required this.checkInLocation,
    required this.checkOutLocation,
    required this.distanceM,
    required this.status,
    required this.isLate,
    required this.isEarlyCheckout,
    required this.workingHoursLabel,
    required this.remarks,
    required this.auditStatus,
  });

  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) {
    return AttendanceRecordModel(
      id: json['id'].toString(),
      date: DateTime.parse(json['date'] as String),
      checkInAt: DateTime.tryParse(json['check_in_at'] as String? ?? ''),
      checkOutAt: DateTime.tryParse(json['check_out_at'] as String? ?? ''),
      checkInLocation: json['check_in_location'] as String? ?? 'Not recorded',
      checkOutLocation: json['check_out_location'] as String? ?? 'Not recorded',
      distanceM: (json['distance_m'] as num? ?? 0).toDouble(),
      status: AttendanceRecordStatus.values.firstWhere(
        (item) => item.name == json['status'],
        orElse: () => AttendanceRecordStatus.present,
      ),
      isLate: json['is_late'] as bool? ?? false,
      isEarlyCheckout: json['is_early_checkout'] as bool? ?? false,
      workingHoursLabel: json['working_hours_label'] as String? ?? '0h 00m',
      remarks: json['remarks'] as String? ?? '',
      auditStatus: json['audit_status'] as String? ?? 'Verified',
    );
  }

  String get statusLabel {
    switch (status) {
      case AttendanceRecordStatus.present:
        return 'Present';
      case AttendanceRecordStatus.late:
        return 'Late';
      case AttendanceRecordStatus.absent:
        return 'Absent';
      case AttendanceRecordStatus.leave:
        return 'On leave';
      case AttendanceRecordStatus.issue:
        return 'Needs correction';
    }
  }

  int get statusColorValue {
    switch (status) {
      case AttendanceRecordStatus.present:
        return 0xFF16A34A;
      case AttendanceRecordStatus.late:
        return 0xFFF59E0B;
      case AttendanceRecordStatus.absent:
        return 0xFFDC2626;
      case AttendanceRecordStatus.leave:
        return 0xFF185FA5;
      case AttendanceRecordStatus.issue:
        return 0xFF7F77DD;
    }
  }
}
