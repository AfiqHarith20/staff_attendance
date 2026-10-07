import 'package:dio/dio.dart';

/// Minimal dummy API client used during development when backend is unavailable.
/// Returns a successful login response for `/auth/login` with dummy profile data.
class ApiClient {
  ApiClient._internal();

  static final ApiClient instance = ApiClient._internal();

  /// Simulates a POST request. For `/auth/login` it returns the role that the
  /// backend would normally attach to the authenticated user.
  Future<Response> post(String path, {dynamic data, Options? options}) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 400));

    if (path == '/auth/login') {
      final email = data?['email'] as String? ?? '';
      final role = email.toLowerCase().contains('admin') ? 'admin' : 'staff';
      final token = 'dummy_${role}_token';
      const displayName = 'Ahmad Nizam';

      final resp = {
        'data': {
          'token': token,
          'role': role,
          'user': {
            'name': displayName,
            'email': email.isNotEmpty ? email : 'ahmad@clokk.app',
            'job_title': 'Operations Executive',
            'department': 'Operations',
          },
        },
      };

      return Response(
        data: resp,
        statusCode: 200,
        requestOptions: RequestOptions(path: path),
      );
    }

    if (path == '/auth/forgot-password') {
      return Response(
        data: {
          'data': {'status': 'ok', 'message': 'Password reset link sent'},
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: path),
      );
    }

    if (path == '/attendance/checkin') {
      // simulate successful check-in
      final resp = {
        'data': {'status': 'ok', 'message': 'Checked in successfully'},
      };
      return Response(
        data: resp,
        statusCode: 200,
        requestOptions: RequestOptions(path: path),
      );
    }

    if (path == '/attendance/correction-requests') {
      return Response(
        data: {
          'data': {
            'status': 'submitted',
            'message': 'Correction request submitted',
          },
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: path),
      );
    }

    if (path == '/remote-work-requests') {
      return Response(
        data: {
          'data': {
            'status': 'submitted',
            'message': 'Remote work request submitted',
          },
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: path),
      );
    }

    if (path == '/approval-inbox/decision') {
      return Response(
        data: {
          'data': {'status': 'updated', 'message': 'Approval decision saved'},
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: path),
      );
    }

    if (path == '/support/issues') {
      return Response(
        data: {
          'data': {'status': 'received', 'message': 'Support issue received'},
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: path),
      );
    }

    if (path == '/documents/upload') {
      // simulate uploaded document metadata
      String type = 'mc';
      try {
        if (data is FormData) {
          for (final field in data.fields) {
            if (field.key == 'type') {
              type = field.value;
              break;
            }
          }
        } else if (data is Map<String, dynamic> && data['type'] != null) {
          type = data['type'].toString();
        }
      } catch (_) {}

      final resp = {
        'data': {
          'id': '999',
          'file_name': 'upload.dat',
          'file_path': 'https://example.com/uploads/upload.dat',
          'file_size': 245760,
          'type': type,
          'status': 'pending',
          'uploaded_at': DateTime.now().toIso8601String(),
          'note': 'Uploaded from mobile app',
        },
      };
      return Response(
        data: resp,
        statusCode: 200,
        requestOptions: RequestOptions(path: path),
      );
    }

    // Default dummy response
    return Response(
      data: {'data': null},
      statusCode: 200,
      requestOptions: RequestOptions(path: path),
    );
  }

  /// Simulate a GET request returning dummy data for a few endpoints used
  /// by the app during development.
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (path == '/documents') {
      final resp = {
        'data': [
          {
            'id': '1',
            'file_name': 'mc_jan.pdf',
            'file_path': 'https://example.com/uploads/mc_jan.pdf',
            'file_size': 184320,
            'type': 'mc',
            'status': 'approved',
            'uploaded_at': DateTime(2026, 1, 13).toIso8601String(),
          },
          {
            'id': '2',
            'file_name': 'emergency_leave_support.png',
            'file_path':
                'https://example.com/uploads/emergency_leave_support.png',
            'file_size': 342120,
            'type': 'emergencyLeave',
            'status': 'pending',
            'uploaded_at': DateTime(2026, 6, 18).toIso8601String(),
          },
        ],
      };

      return Response(
        data: resp,
        statusCode: 200,
        requestOptions: RequestOptions(path: path),
      );
    }

    if (path == '/attendance/history') {
      final resp = {
        'data': [
          {
            'id': 'att-1',
            'date': DateTime(2026, 7, 24).toIso8601String(),
            'check_in_at': DateTime(2026, 7, 24, 8, 58).toIso8601String(),
            'check_out_at': DateTime(2026, 7, 24, 18, 4).toIso8601String(),
            'check_in_location': 'Clokk HQ · Cyberjaya',
            'check_out_location': 'Clokk HQ · Cyberjaya',
            'distance_m': 42,
            'status': 'present',
            'is_late': false,
            'is_early_checkout': false,
            'working_hours_label': '9h 06m',
            'remarks': 'Verified within office radius',
            'audit_status': 'Verified',
          },
          {
            'id': 'att-2',
            'date': DateTime(2026, 7, 23).toIso8601String(),
            'check_in_at': DateTime(2026, 7, 23, 9, 22).toIso8601String(),
            'check_out_at': DateTime(2026, 7, 23, 18, 1).toIso8601String(),
            'check_in_location': 'Clokk HQ · Cyberjaya',
            'check_out_location': 'Clokk HQ · Cyberjaya',
            'distance_m': 65,
            'status': 'late',
            'is_late': true,
            'is_early_checkout': false,
            'working_hours_label': '8h 39m',
            'remarks': 'Late check-in recorded',
            'audit_status': 'Verified with late flag',
          },
          {
            'id': 'att-3',
            'date': DateTime(2026, 7, 22).toIso8601String(),
            'check_in_at': DateTime(2026, 7, 22, 9, 3).toIso8601String(),
            'check_out_at': DateTime(2026, 7, 22, 16, 48).toIso8601String(),
            'check_in_location': 'Clokk HQ · Cyberjaya',
            'check_out_location': 'Clokk HQ · Cyberjaya',
            'distance_m': 51,
            'status': 'issue',
            'is_late': false,
            'is_early_checkout': true,
            'working_hours_label': '7h 45m',
            'remarks': 'Early checkout requires manager review',
            'audit_status': 'Pending review',
          },
          {
            'id': 'att-4',
            'date': DateTime(2026, 7, 21).toIso8601String(),
            'check_in_at': null,
            'check_out_at': null,
            'check_in_location': 'Not recorded',
            'check_out_location': 'Not recorded',
            'distance_m': 0,
            'status': 'leave',
            'is_late': false,
            'is_early_checkout': false,
            'working_hours_label': '0h 00m',
            'remarks': 'Annual leave approved',
            'audit_status': 'Approved leave',
          },
        ],
      };

      return Response(
        data: resp,
        statusCode: 200,
        requestOptions: RequestOptions(path: path),
      );
    }

    if (path == '/work-hours-summary') {
      final period = queryParameters?['period'] == 'monthly'
          ? 'monthly'
          : 'weekly';
      final resp = {
        'data': {
          'total_hours': period == 'monthly' ? '162h 20m' : '39h 15m',
          'overtime_hours': period == 'monthly' ? '12h 10m' : '2h 30m',
          'late_minutes': period == 'monthly' ? 48 : 12,
          'absences': period == 'monthly' ? 1 : 0,
          'attendance_score': period == 'monthly' ? 93 : 96,
          'daily': [
            {
              'day': 'Mon',
              'hours': '8h 04m',
              'overtime': '0h',
              'late_minutes': 0,
              'score': 100,
            },
            {
              'day': 'Tue',
              'hours': '8h 22m',
              'overtime': '0h 22m',
              'late_minutes': 0,
              'score': 98,
            },
            {
              'day': 'Wed',
              'hours': '7h 45m',
              'overtime': '0h',
              'late_minutes': 0,
              'score': 88,
            },
            {
              'day': 'Thu',
              'hours': '8h 39m',
              'overtime': '0h 39m',
              'late_minutes': 12,
              'score': 90,
            },
            {
              'day': 'Fri',
              'hours': '8h 25m',
              'overtime': '1h 29m',
              'late_minutes': 0,
              'score': 100,
            },
          ],
        },
      };
      return Response(
        data: resp,
        statusCode: 200,
        requestOptions: RequestOptions(path: path),
      );
    }

    if (path == '/team-attendance') {
      final resp = {
        'data': [
          {
            'id': 'u1',
            'name': 'Ahmad Nizam',
            'initials': 'AN',
            'role': 'Operations',
            'status': 'Present',
            'time': '8:58 AM',
            'location': 'Clokk HQ',
            'distance': '42m',
            'flag': 'Verified',
          },
          {
            'id': 'u2',
            'name': 'Siti Rahmah',
            'initials': 'SR',
            'role': 'Finance',
            'status': 'Late',
            'time': '9:22 AM',
            'location': 'Clokk HQ',
            'distance': '58m',
            'flag': 'Late 22m',
          },
          {
            'id': 'u3',
            'name': 'Daniel Tan',
            'initials': 'DT',
            'role': 'Engineering',
            'status': 'Remote',
            'time': '9:00 AM',
            'location': 'Home office',
            'distance': '12.4km',
            'flag': 'WFH approved',
          },
          {
            'id': 'u4',
            'name': 'Nur Aisyah',
            'initials': 'NA',
            'role': 'HR',
            'status': 'On leave',
            'time': 'Approved',
            'location': 'Away',
            'distance': '-',
            'flag': 'Annual leave',
          },
          {
            'id': 'u5',
            'name': 'Farid Hakim',
            'initials': 'FH',
            'role': 'Sales',
            'status': 'Absent',
            'time': 'No record',
            'location': 'Unknown',
            'distance': '-',
            'flag': 'Missing check-in',
          },
        ],
      };
      return Response(
        data: resp,
        statusCode: 200,
        requestOptions: RequestOptions(path: path),
      );
    }

    if (path == '/approval-inbox') {
      final resp = {
        'data': [
          {
            'id': 'ap1',
            'type': 'Leave',
            'title': 'Annual Leave · Ahmad Nizam',
            'subtitle': '12 Aug 2026 - 14 Aug 2026 · 3 days',
            'submitted': 'Today',
            'status': 'Pending',
            'date_bucket': 'Today',
            'detail':
                'Annual leave request has enough balance and no schedule conflict.',
            'audit': ['Submitted by Ahmad Nizam', 'Routed to HR Admin'],
          },
          {
            'id': 'ap2',
            'type': 'Claim',
            'title': 'Medical Claim · Siti Rahmah',
            'subtitle': 'RM 84.50 · Clinic consultation',
            'submitted': 'Yesterday',
            'status': 'Pending',
            'date_bucket': 'This week',
            'detail': 'Receipt attached and amount is within claim policy.',
            'audit': ['Receipt uploaded', 'Finance review pending'],
          },
          {
            'id': 'ap3',
            'type': 'Correction',
            'title': 'Forgot checkout · Daniel Tan',
            'subtitle': 'Requested checkout 6:02 PM',
            'submitted': '22 Jul',
            'status': 'Pending',
            'date_bucket': 'This week',
            'detail': 'Correction request includes manager note and GPS trace.',
            'audit': [
              'Correction submitted',
              'System flagged missing checkout',
            ],
          },
          {
            'id': 'ap4',
            'type': 'Document',
            'title': 'MC document verification',
            'subtitle': 'emergency_leave_support.png',
            'submitted': '18 Jun',
            'status': 'Pending',
            'date_bucket': 'Older',
            'detail': 'Document needs HR verification before leave conversion.',
            'audit': ['Document uploaded', 'Pending HR verification'],
          },
        ],
      };
      return Response(
        data: resp,
        statusCode: 200,
        requestOptions: RequestOptions(path: path),
      );
    }

    if (path == '/shifts') {
      final resp = {
        'data': [
          {
            'id': 'shift-1',
            'date': DateTime(2026, 7, 20).toIso8601String(),
            'title': 'Morning Shift',
            'time_label': '9:00 AM - 6:00 PM',
            'location': 'Clokk HQ',
            'note': 'Standard office shift',
            'type': 'work',
          },
          {
            'id': 'shift-2',
            'date': DateTime(2026, 7, 21).toIso8601String(),
            'title': 'Annual Leave',
            'time_label': 'Full day',
            'location': 'Away',
            'note': 'Approved leave',
            'type': 'holiday',
          },
          {
            'id': 'shift-3',
            'date': DateTime(2026, 7, 22).toIso8601String(),
            'title': 'Morning Shift',
            'time_label': '9:00 AM - 6:00 PM',
            'location': 'Clokk HQ',
            'note': '',
            'type': 'work',
          },
          {
            'id': 'shift-4',
            'date': DateTime(2026, 7, 23).toIso8601String(),
            'title': 'Remote Work',
            'time_label': '9:00 AM - 6:00 PM',
            'location': 'Remote',
            'note': 'Manager-approved WFH day',
            'type': 'remote',
          },
          {
            'id': 'shift-5',
            'date': DateTime(2026, 7, 24).toIso8601String(),
            'title': 'Morning Shift',
            'time_label': '9:00 AM - 6:00 PM',
            'location': 'Clokk HQ',
            'note': 'Payroll cutoff day',
            'type': 'work',
          },
          {
            'id': 'shift-6',
            'date': DateTime(2026, 7, 25).toIso8601String(),
            'title': 'Rest Day',
            'time_label': 'No shift',
            'location': '',
            'note': 'Weekend',
            'type': 'rest',
          },
        ],
      };
      return Response(
        data: resp,
        statusCode: 200,
        requestOptions: RequestOptions(path: path),
      );
    }

    if (path == '/notifications') {
      final resp = {
        'data': [
          {
            'id': 'n1',
            'title': 'Missing checkout reminder',
            'body': 'You have one attendance record pending checkout review.',
            'category': 'Attendance',
            'created_at': DateTime(2026, 7, 24, 9, 15).toIso8601String(),
            'is_unread': true,
            'route': '/attendance-history',
          },
          {
            'id': 'n2',
            'title': 'July payslip is ready',
            'body': 'Your July 2026 payslip is available for download.',
            'category': 'Payroll',
            'created_at': DateTime(2026, 7, 24, 8, 0).toIso8601String(),
            'is_unread': true,
            'route': '/pay-slip',
          },
          {
            'id': 'n3',
            'title': 'Leave request update',
            'body':
                'Your annual leave request is waiting for manager approval.',
            'category': 'Approvals',
            'created_at': DateTime(2026, 7, 23, 17, 30).toIso8601String(),
            'is_unread': false,
            'route': '/time-off',
          },
          {
            'id': 'n4',
            'title': 'Office maintenance notice',
            'body': 'Level 3 rooms are unavailable this Saturday.',
            'category': 'Announcement',
            'created_at': DateTime(2026, 7, 22, 11, 0).toIso8601String(),
            'is_unread': false,
            'route': '/announcements',
          },
        ],
      };
      return Response(
        data: resp,
        statusCode: 200,
        requestOptions: RequestOptions(path: path),
      );
    }

    if (path == '/claims/my') {
      final resp = {
        'data': [
          {
            'id': 'c1',
            'type': 'medical',
            'amount': 84.50,
            'description': 'Clinic consultation',
            'status': 'pending',
            'claim_date': DateTime(2026, 7, 9).toIso8601String(),
            'submitted_at': DateTime(2026, 7, 10).toIso8601String(),
            'receipt_url': 'https://example.com/claims/receipt_1.pdf',
            'receipt_file_name': 'receipt_1.pdf',
          },
        ],
      };
      return Response(
        data: resp,
        statusCode: 200,
        requestOptions: RequestOptions(path: path),
      );
    }

    if (path == '/announcements') {
      final resp = {
        'data': [
          {
            'id': 'a1',
            'title': 'New leave approval cutoff for payroll',
            'category': 'HR',
            'summary':
                'Leave requests submitted after the 25th will roll into the next payroll cycle.',
            'body':
                'Please submit leave requests before the 25th of each month so approved leave can be reflected in the current payroll cycle. Urgent cases can still be discussed with HR directly.',
            'published_at': DateTime(2026, 7, 23).toIso8601String(),
            'is_pinned': true,
            'is_unread': true,
          },
          {
            'id': 'a2',
            'title': 'Office maintenance on Saturday, 25 July 2026',
            'category': 'Office',
            'summary':
                'Level 3 pantry and meeting rooms will be unavailable during scheduled maintenance.',
            'body':
                'Facilities will carry out maintenance work on Saturday, 25 July 2026 from 9:00 AM to 3:00 PM. Please avoid booking Level 3 rooms during that window.',
            'published_at': DateTime(2026, 7, 22).toIso8601String(),
            'is_pinned': false,
            'is_unread': true,
          },
          {
            'id': 'a3',
            'title': 'Wellness claim reminder',
            'category': 'Finance',
            'summary':
                'June and July wellness claims must be submitted by Wednesday, 31 July 2026.',
            'body':
                'If you are claiming eligible wellness expenses for June or July, please upload receipts by Wednesday, 31 July 2026 to avoid carryover delays.',
            'published_at': DateTime(2026, 7, 19).toIso8601String(),
            'is_pinned': false,
            'is_unread': false,
          },
        ],
      };
      return Response(
        data: resp,
        statusCode: 200,
        requestOptions: RequestOptions(path: path),
      );
    }

    if (path == '/payslips') {
      final resp = {
        'data': [
          {
            'id': 'p1',
            'month_label': 'July 2026',
            'period_label': 'Payroll period: 1 Jul 2026 - 31 Jul 2026',
            'net_pay_label': 'RM 4,850.00',
            'status': 'Ready',
            'file_url': 'https://example.com/payslips/july-2026.pdf',
            'issued_at': DateTime(2026, 7, 24).toIso8601String(),
          },
          {
            'id': 'p2',
            'month_label': 'June 2026',
            'period_label': 'Payroll period: 1 Jun 2026 - 30 Jun 2026',
            'net_pay_label': 'RM 4,850.00',
            'status': 'Ready',
            'file_url': 'https://example.com/payslips/june-2026.pdf',
            'issued_at': DateTime(2026, 6, 24).toIso8601String(),
          },
          {
            'id': 'p3',
            'month_label': 'December 2025',
            'period_label': 'Payroll period: 1 Dec 2025 - 31 Dec 2025',
            'net_pay_label': 'RM 4,700.00',
            'status': 'Ready',
            'file_url': 'https://example.com/payslips/dec-2025.pdf',
            'issued_at': DateTime(2025, 12, 24).toIso8601String(),
          },
        ],
      };
      return Response(
        data: resp,
        statusCode: 200,
        requestOptions: RequestOptions(path: path),
      );
    }

    if (path == '/staff/dashboard/badges') {
      final resp = {
        'data': {
          'pending_leave': 1,
          'pending_documents': 2,
          'unread_announcements': 2,
          'payslip_ready': true,
          'payslip_month': 'Jul',
          'next_holiday_date': '31 Jul',
        },
      };
      return Response(
        data: resp,
        statusCode: 200,
        requestOptions: RequestOptions(path: path),
      );
    }

    if (path == '/qr/generate') {
      final resp = {
        'data': {
          'token': 'dummy_qr_token_12345',
          'expires_at': DateTime.now()
              .add(const Duration(seconds: 30))
              .toIso8601String(),
        },
      };

      return Response(
        data: resp,
        statusCode: 200,
        requestOptions: RequestOptions(path: path),
      );
    }

    return Response(
      data: {'data': null},
      statusCode: 200,
      requestOptions: RequestOptions(path: path),
    );
  }
}
