import 'dart:io';

/// Backend base URL resolution.
///
/// Override at build/run time with `--dart-define=API_BASE_URL=http://...`
/// (needed for a physical device, which can't reach `localhost`/`10.0.2.2`).
class ApiList {
  static const String _override = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_override.isNotEmpty) return _override;
    // Android emulators route host-machine localhost through 10.0.2.2.
    // For a physical device use: --dart-define=API_BASE_URL=http://<LAN-IP>:8000/api
    if (Platform.isAndroid) return 'http://10.0.2.2:8000/api';
    return 'http://localhost:8000/api';
  }

  /// Rewrites a server-returned URL so it resolves on the current device.
  /// The backend always returns URLs with its own host (e.g. localhost:8000),
  /// which is unreachable on Android emulators. Replace the origin to match
  /// whatever host this device actually uses to reach the backend.
  static String normalizeUrl(String url) {
    if (_override.isNotEmpty) return url; // custom host — assume already correct
    if (Platform.isAndroid) {
      return url
          .replaceFirst('http://localhost:', 'http://10.0.2.2:')
          .replaceFirst('https://localhost:', 'https://10.0.2.2:');
    }
    return url;
  }

  // ── Auth ─────────────────────────────────────────────────────────────────
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String changePassword = '/auth/change-password';
  static const String currentUser = '/user';

  // ── Attendance ────────────────────────────────────────────────────────────
  static const String checkIn = '/attendance/checkin';
  static const String checkOut = '/attendance/checkout';
  static const String attendanceToday = '/attendance/today';
  static const String attendanceHistory = '/attendance/history';
  static const String correctionRequests = '/attendance/correction-requests';

  // ── Leave ─────────────────────────────────────────────────────────────────
  static const String leaveBalance = '/leave/balance';
  static const String leaveList = '/leave/my';
  static const String leaveApply = '/leave/apply';
  static String leaveCancel(String id) => '/leave/$id/cancel';

  // ── Overtime & Remote work ────────────────────────────────────────────────
  static const String overtimeList = '/overtime/my';
  static const String overtimeApply = '/overtime/apply';
  static String overtimeCancel(String id) => '/overtime/$id/cancel';
  static const String remoteWorkRequests = '/remote-work-requests';
  static String remoteWorkCancel(String id) => '/remote-work-requests/$id/cancel';

  // ── Claims ────────────────────────────────────────────────────────────────
  static const String claimsList = '/claims/my';
  static const String claimsMileageRates = '/claims/mileage-rates';
  static const String claimsCalculateMileage = '/claims/calculate-mileage';
  static const String claimsSubmit = '/claims/submit';
  static String claimCancel(String id) => '/claims/$id/cancel';

  // ── Documents ────────────────────────────────────────────────────────────
  static const String documents = '/documents';
  static const String documentsUpload = '/documents/upload';

  // ── Payslips ──────────────────────────────────────────────────────────────
  static const String payslips = '/payslips';
  static String payslipAcknowledge(String id) => '/payslips/$id/acknowledge';

  // ── Staff info ────────────────────────────────────────────────────────────
  static const String benefits = '/benefits';
  static const String employmentHistory = '/employment-history';
  static const String shifts = '/shifts';
  static const String workHoursSummary = '/work-hours-summary';
  static const String calendarEvents = '/calendar/events';

  // ── Announcements ─────────────────────────────────────────────────────────
  static const String announcements = '/announcements';
  static String announcementRead(String id) => '/announcements/$id/read';

  // ── Notifications ─────────────────────────────────────────────────────────
  static const String notifications = '/notifications';
  static String notificationRead(String id) => '/notifications/$id/read';
  static const String notificationsReadAll = '/notifications/read-all';

  // ── Dashboard ─────────────────────────────────────────────────────────────
  static const String dashboardBadges = '/staff/dashboard/badges';

  // ── Support ───────────────────────────────────────────────────────────────
  static const String supportIssues = '/support/issues';

  // ── Devices ───────────────────────────────────────────────────────────────
  static const String devices = '/devices';

  // ── My Assets ─────────────────────────────────────────────────────────────
  static const String myAssets = '/my-assets';

  // ── Training Records ──────────────────────────────────────────────────────
  static const String training = '/training';
  static String trainingItem(String id) => '/training/$id';

  // ── Shift Swaps ───────────────────────────────────────────────────────────
  static const String shiftSwaps = '/shift-swaps';
  static String shiftSwapCancel(String id) => '/shift-swaps/$id';

  // ── Performance ───────────────────────────────────────────────────────────
  static const String performance = '/performance';
  static String performanceSelfAssessment(String id) => '/performance/$id/self-assessment';
  static String performanceAcknowledge(String id) => '/performance/$id/acknowledge';

  // ── Job Board ─────────────────────────────────────────────────────────────
  static const String jobs = '/jobs';

  // ── Signature Requests ────────────────────────────────────────────────────
  static const String signatureRequests = '/signature-requests';
  static String signatureSign(String id) => '/signature-requests/$id/sign';
  static String signatureDecline(String id) => '/signature-requests/$id/decline';

  // ── Admin dashboard & analytics ───────────────────────────────────────────
  static const String adminDashboardStats  = '/admin/dashboard/stats';
  static const String adminHrAnalytics     = '/admin/hr-analytics';

  // ── Admin employee directory ──────────────────────────────────────────────
  static const String adminEmployees = '/admin/employees';
  static String adminEmployee(String id) => '/admin/employees/$id';

  // ── Admin announcement management ─────────────────────────────────────────
  static const String adminAnnouncements = '/admin/announcements';
  static String adminAnnouncement(String id) => '/admin/announcements/$id';

  // ── Admin asset management ────────────────────────────────────────────────
  static const String adminAssets = '/admin/assets';
  // Same URL path — distinguished by HTTP verb: POST (assign) vs DELETE (unassign).
  static String adminAssetAssign(String id)   => '/admin/assets/$id/assign';
  static String adminAssetUnassign(String id) => '/admin/assets/$id/assign';

  // ── Admin team leave ──────────────────────────────────────────────────────
  static const String adminTeamLeave = '/admin/team-leave';

  // ── Admin ─────────────────────────────────────────────────────────────────
  static const String qrGenerate = '/qr/generate';
  static const String teamAttendance = '/team-attendance';
  static const String approvalInbox = '/approval-inbox';
  static const String approvalDecision = '/approval-inbox/decision';
  static const String approvalBulkDecision = '/approval-inbox/bulk-decision';
}
