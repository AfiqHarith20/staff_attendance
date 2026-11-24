enum AttendanceRecordStatus { present, late, absent, leave, issue }

class AttendanceRecordModel {
  final String id;
  final DateTime date;
  final DateTime? checkInAt;
  final DateTime? checkOutAt;
  final String? checkInLocation;
  final String? checkOutLocation;
  final double checkInDistanceM;
  final double? checkOutDistanceM;
  final double? checkInLatitude;
  final double? checkInLongitude;
  final double? checkOutLatitude;
  final double? checkOutLongitude;
  final AttendanceRecordStatus status;
  final bool isLate;
  final bool isEarlyCheckout;
  final String workingHoursLabel;
  final String? remarks;
  final String auditStatus;

  const AttendanceRecordModel({
    required this.id,
    required this.date,
    required this.checkInAt,
    required this.checkOutAt,
    this.checkInLocation,
    this.checkOutLocation,
    this.checkInDistanceM = 0,
    this.checkOutDistanceM,
    this.checkInLatitude,
    this.checkInLongitude,
    this.checkOutLatitude,
    this.checkOutLongitude,
    required this.status,
    required this.isLate,
    required this.isEarlyCheckout,
    required this.workingHoursLabel,
    this.remarks,
    required this.auditStatus,
  });

  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) {
    return AttendanceRecordModel(
      id: json['id'].toString(),
      date: DateTime.parse(json['date'] as String),
      checkInAt: DateTime.tryParse(json['check_in_at'] as String? ?? '')?.toLocal(),
      checkOutAt: DateTime.tryParse(json['check_out_at'] as String? ?? '')?.toLocal(),
      checkInLocation: json['check_in_location'] as String?,
      checkOutLocation: json['check_out_location'] as String?,
      checkInDistanceM: (json['check_in_distance_m'] as num? ?? 0).toDouble(),
      checkOutDistanceM: (json['check_out_distance_m'] as num?)?.toDouble(),
      checkInLatitude: (json['check_in_latitude'] as num?)?.toDouble(),
      checkInLongitude: (json['check_in_longitude'] as num?)?.toDouble(),
      checkOutLatitude: (json['check_out_latitude'] as num?)?.toDouble(),
      checkOutLongitude: (json['check_out_longitude'] as num?)?.toDouble(),
      status: AttendanceRecordStatus.values.firstWhere(
        (item) => item.name == json['status'],
        orElse: () => AttendanceRecordStatus.present,
      ),
      isLate: json['is_late'] as bool? ?? false,
      isEarlyCheckout: json['is_early_checkout'] as bool? ?? false,
      workingHoursLabel: json['working_hours_label'] as String? ?? '0h 00m',
      remarks: json['remarks'] as String?,
      auditStatus: json['audit_status'] as String? ?? 'Verified',
    );
  }

  // Returns the i18n key so callers can do labelFor(status).tr
  static String labelFor(AttendanceRecordStatus status) {
    switch (status) {
      case AttendanceRecordStatus.present:
        return 'present';
      case AttendanceRecordStatus.late:
        return 'late';
      case AttendanceRecordStatus.absent:
        return 'absent';
      case AttendanceRecordStatus.leave:
        return 'on_leave';
      case AttendanceRecordStatus.issue:
        return 'needs_correction';
    }
  }

  String get statusLabel => labelFor(status);

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
