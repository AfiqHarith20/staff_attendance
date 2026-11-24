class AttendanceCounts {
  final int present;
  final int late;
  final int onLeave;
  final int absent;
  final int remote;

  const AttendanceCounts({
    required this.present,
    required this.late,
    required this.onLeave,
    required this.absent,
    required this.remote,
  });

  int get total => present + late + onLeave + absent + remote;

  factory AttendanceCounts.fromJson(Map<String, dynamic> json) =>
      AttendanceCounts(
        present: (json['Present'] as num?)?.toInt() ?? 0,
        late: (json['Late'] as num?)?.toInt() ?? 0,
        onLeave: (json['On leave'] as num?)?.toInt() ?? 0,
        absent: (json['Absent'] as num?)?.toInt() ?? 0,
        remote: (json['Remote'] as num?)?.toInt() ?? 0,
      );
}

class DeptAttendance {
  final String department;
  final int total;
  final AttendanceCounts counts;

  const DeptAttendance({
    required this.department,
    required this.total,
    required this.counts,
  });

  factory DeptAttendance.fromJson(Map<String, dynamic> json) => DeptAttendance(
        department: json['department'] as String? ?? '',
        total: (json['total'] as num?)?.toInt() ?? 0,
        counts: AttendanceCounts.fromJson(
          json['counts'] as Map<String, dynamic>? ?? {},
        ),
      );
}

class ExceptionItem {
  final int id;
  final String name;
  final String? dept;
  final String kind;
  final String detail;

  const ExceptionItem({
    required this.id,
    required this.name,
    this.dept,
    required this.kind,
    required this.detail,
  });

  factory ExceptionItem.fromJson(Map<String, dynamic> json) => ExceptionItem(
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: json['name'] as String? ?? '',
        dept: json['dept'] as String?,
        kind: json['kind'] as String? ?? '',
        detail: json['detail'] as String? ?? '',
      );
}

class AdminDashboardModel {
  final String date;
  final int headcount;
  final int pendingApprovals;
  final AttendanceCounts attendance;
  final List<DeptAttendance> byDepartment;
  final List<ExceptionItem> exceptions;

  const AdminDashboardModel({
    required this.date,
    required this.headcount,
    required this.pendingApprovals,
    required this.attendance,
    required this.byDepartment,
    required this.exceptions,
  });

  factory AdminDashboardModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final exc = data['exceptions'] as Map<String, dynamic>? ?? {};
    return AdminDashboardModel(
      date: data['date'] as String? ?? '',
      headcount: (data['headcount'] as num?)?.toInt() ?? 0,
      pendingApprovals: (data['pending_approvals'] as num?)?.toInt() ?? 0,
      attendance: AttendanceCounts.fromJson(
        data['attendance'] as Map<String, dynamic>? ?? {},
      ),
      byDepartment: (data['by_department'] as List<dynamic>? ?? [])
          .map((e) => DeptAttendance.fromJson(e as Map<String, dynamic>))
          .toList(),
      exceptions: (exc['items'] as List<dynamic>? ?? [])
          .map((e) => ExceptionItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
