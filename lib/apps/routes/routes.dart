import 'package:get/get.dart';
import 'package:staff_attendance/apps/bindings/apply_leave_binding.dart';
import 'package:staff_attendance/apps/bindings/apply_overtime_binding.dart';
import 'package:staff_attendance/apps/bindings/approval_inbox_binding.dart';
import 'package:staff_attendance/apps/bindings/attendance_history_binding.dart';
import 'package:staff_attendance/apps/bindings/calendar_binding.dart';
import 'package:staff_attendance/apps/bindings/correction_request_binding.dart';
import 'package:staff_attendance/apps/bindings/document_upload_binding.dart';
import 'package:staff_attendance/apps/bindings/forgot_password_binding.dart';
import 'package:staff_attendance/apps/bindings/help_support_binding.dart';
import 'package:staff_attendance/apps/bindings/my_document_binding.dart';
import 'package:staff_attendance/apps/bindings/notifications_binding.dart';
import 'package:staff_attendance/apps/bindings/payslip_binding.dart';
import 'package:staff_attendance/apps/bindings/remote_work_request_binding.dart';
import 'package:staff_attendance/apps/bindings/shift_schedule_binding.dart';
import 'package:staff_attendance/apps/bindings/submit_claim_binding.dart';
import 'package:staff_attendance/apps/bindings/team_attendance_binding.dart';
import 'package:staff_attendance/apps/bindings/time_off_binding.dart';
import 'package:staff_attendance/apps/bindings/work_hours_summary_binding.dart';
import 'package:staff_attendance/apps/bindings/announcements_binding.dart';
import 'package:staff_attendance/apps/views/approvals/approval_inbox_screen.dart';
import 'package:staff_attendance/apps/views/admin/admin_report_detail_screens.dart';
import 'package:staff_attendance/apps/views/admin/admin_reports_screen.dart';
import 'package:staff_attendance/apps/views/admin/admin_settings_screen.dart';
import 'package:staff_attendance/apps/views/admin/approval_detail_screen.dart';
import 'package:staff_attendance/apps/views/admin/attendance_regularization_review_screen.dart';
import 'package:staff_attendance/apps/views/admin/department_dashboard_screen.dart';
import 'package:staff_attendance/apps/views/admin/employee_management_screen.dart';
import 'package:staff_attendance/apps/views/admin/holiday_calendar_management_screen.dart';
import 'package:staff_attendance/apps/views/admin/live_exceptions_board_screen.dart';
import 'package:staff_attendance/apps/views/admin/payroll_prep_screen.dart';
import 'package:staff_attendance/apps/views/admin/role_access_management_screen.dart';
import 'package:staff_attendance/apps/views/admin/shift_assignment_planner_screen.dart';
import 'package:staff_attendance/apps/views/attendance/attendance_analytics_screen.dart';
import 'package:staff_attendance/apps/views/apply_screen/apply_leave_screen.dart';
import 'package:staff_attendance/apps/views/apply_screen/apply_overtime_screen.dart';
import 'package:staff_attendance/apps/views/auth/forgot_password_screen/forgot_password_screen.dart';
import 'package:staff_attendance/apps/views/auth/login_screen/login_screen.dart';
import 'package:staff_attendance/apps/views/auth/registration_screen/register_screen.dart';
import 'package:staff_attendance/apps/views/announcements_screen/announcements_screen.dart';
import 'package:staff_attendance/apps/views/attendance_detail_screen/attendance_detail_screen.dart';
import 'package:staff_attendance/apps/views/attendance_history_screen/attendance_history_screen.dart';
import 'package:staff_attendance/apps/views/calendar_screen/calendar_screen.dart';
import 'package:staff_attendance/apps/views/correction_request_screen/correction_request_screen.dart';
import 'package:staff_attendance/apps/views/document_upload_screen/document_upload_screen.dart';
import 'package:staff_attendance/apps/views/support/help_support_screen.dart';
import 'package:staff_attendance/apps/views/support/company_policy_screen.dart';
import 'package:staff_attendance/apps/views/support/organisation_info_screen.dart';
import 'package:staff_attendance/apps/views/home/dashboard_screen/dashboard_screen.dart';
import 'package:staff_attendance/apps/views/home/bottom_nav/bottom_nav.dart';
import 'package:staff_attendance/apps/views/home/my_attendance_screen/my_attendance_screen.dart';
import 'package:staff_attendance/apps/views/documents/document_expiry_renewal_screen.dart';
import 'package:staff_attendance/apps/views/requests/leave_balance_detail_screen.dart';
import 'package:staff_attendance/apps/views/my_document_screen/my_document_screen.dart';
import 'package:staff_attendance/apps/views/notifications_screen/notifications_screen.dart';
import 'package:staff_attendance/apps/views/payslip_screen/payslip_screen.dart';
import 'package:staff_attendance/apps/views/requests/request_status_tracker_screen.dart';
import 'package:staff_attendance/apps/views/requests/remote_work_request_screen.dart';
import 'package:staff_attendance/apps/views/shift_schedule_screen/shift_schedule_screen.dart';
import 'package:staff_attendance/apps/views/splash_screen/splash_screen.dart';
import 'package:staff_attendance/apps/views/attendance/team_attendance_screen.dart';
import 'package:staff_attendance/apps/bindings/login_binding.dart';
import 'package:staff_attendance/apps/bindings/register_binding.dart';
import 'package:staff_attendance/apps/bindings/scan_binding.dart';
import 'package:staff_attendance/apps/views/submit_claim_screen/submit_claim_screen.dart';
import 'package:staff_attendance/apps/views/time_off_screen/time_off_screen.dart';
import 'package:staff_attendance/apps/views/attendance/work_hours_summary_screen.dart';

abstract class Routes {
  static const splash = '/splash';
  static const login = '/login';
  static const forgotPassword = '/forgot-password';
  static const register = '/register';
  static const dashboard = '/dashboard';
  static const app = '/app';
  static const scan = '/scan';

  // ── New routes from Other screen ──
  static const calendar = '/calendar';
  static const attendanceHistory = '/attendance-history';
  static const attendanceDetail = '/attendance-detail';
  static const correctionRequest = '/correction-request';
  static const shiftSchedule = '/shift-schedule';
  static const notifications = '/notifications';
  static const workHoursSummary = '/work-hours-summary';
  static const teamAttendance = '/team-attendance';
  static const remoteWorkRequest = '/remote-work-request';
  static const approvalInbox = '/approval-inbox';
  static const helpSupport = '/help-support';
  static const requestStatusTracker = '/request-status-tracker';
  static const attendanceAnalytics = '/attendance-analytics';
  static const leaveBalanceDetail = '/leave-balance-detail';
  static const documentExpiryRenewal = '/document-expiry-renewal';
  static const approvalDetail = '/approval-detail';
  static const liveExceptionsBoard = '/live-exceptions-board';
  static const attendanceRegularizationReview =
      '/attendance-regularization-review';
  static const holidayCalendarManagement = '/holiday-calendar-management';
  static const payrollPrep = '/payroll-prep';
  static const roleAccessManagement = '/role-access-management';
  static const shiftAssignmentPlanner = '/shift-assignment-planner';
  static const timeOff = '/time-off';
  static const applyLeave = '/apply-leave';
  static const applyOvertime = '/apply-overtime';
  static const submitClaim = '/submit-claim';
  static const myDocuments = '/my-documents';
  static const paySlip = '/pay-slip';
  static const documentUpload = '/document-upload';
  static const organisation = '/organisation';
  static const companyPolicy = '/company-policy';
  static const announcements = '/announcements';
  static const adminReports = '/admin-reports';
  static const monthlyAttendanceReport = '/admin-reports/monthly-attendance';
  static const latenessReport = '/admin-reports/lateness';
  static const overtimeSummaryReport = '/admin-reports/overtime-summary';
  static const leaveClaimSummaryReport = '/admin-reports/leave-claim-summary';
  static const adminSettings = '/admin-settings';
  static const employeeManagement = '/employee-management';
  static const departmentDashboard = '/department-dashboard';

  static final list = [
    GetPage(name: splash, page: () => const SplashScreen()),
    // lib/apps/routes/routes.dart
    GetPage(
      name: Routes.login,
      page: () => const LoginScreen(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.register,
      page: () => const RegisterScreen(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: Routes.forgotPassword,
      page: () => const ForgotPasswordScreen(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(name: dashboard, page: () => const DashboardScreen()),
    GetPage(name: app, page: () => const BottomNavScreen()),
    GetPage(name: scan, page: () => const MyAttendanceScreen()),
    GetPage(
      name: Routes.scan,
      page: () => const MyAttendanceScreen(),
      binding: ScanBinding(),
    ),

    // Placeholder pages — replace with real screens later
    GetPage(
      name: Routes.calendar,
      page: () => const CalendarScreen(),
      binding: CalendarBinding(),
    ),
    GetPage(
      name: Routes.attendanceHistory,
      page: () => const AttendanceHistoryScreen(),
      binding: AttendanceHistoryBinding(),
    ),
    GetPage(
      name: Routes.attendanceDetail,
      page: () => const AttendanceDetailScreen(),
    ),
    GetPage(
      name: Routes.correctionRequest,
      page: () => const CorrectionRequestScreen(),
      binding: CorrectionRequestBinding(),
    ),
    GetPage(
      name: Routes.shiftSchedule,
      page: () => const ShiftScheduleScreen(),
      binding: ShiftScheduleBinding(),
    ),
    GetPage(
      name: Routes.notifications,
      page: () => const NotificationsScreen(),
      binding: NotificationsBinding(),
    ),
    GetPage(
      name: Routes.workHoursSummary,
      page: () => const WorkHoursSummaryScreen(),
      binding: WorkHoursSummaryBinding(),
    ),
    GetPage(
      name: Routes.teamAttendance,
      page: () => const TeamAttendanceScreen(),
      binding: TeamAttendanceBinding(),
    ),
    GetPage(
      name: Routes.remoteWorkRequest,
      page: () => const RemoteWorkRequestScreen(),
      binding: RemoteWorkRequestBinding(),
    ),
    GetPage(
      name: Routes.approvalInbox,
      page: () => const ApprovalInboxScreen(),
      binding: ApprovalInboxBinding(),
    ),
    GetPage(
      name: Routes.helpSupport,
      page: () => const HelpSupportScreen(),
      binding: HelpSupportBinding(),
    ),
    GetPage(
      name: Routes.requestStatusTracker,
      page: () => const RequestStatusTrackerScreen(),
    ),
    GetPage(
      name: Routes.attendanceAnalytics,
      page: () => const AttendanceAnalyticsScreen(),
    ),
    GetPage(
      name: Routes.leaveBalanceDetail,
      page: () => const LeaveBalanceDetailScreen(),
    ),
    GetPage(
      name: Routes.documentExpiryRenewal,
      page: () => const DocumentExpiryRenewalScreen(),
    ),
    GetPage(
      name: Routes.approvalDetail,
      page: () => const ApprovalDetailScreen(),
    ),
    GetPage(
      name: Routes.liveExceptionsBoard,
      page: () => const LiveExceptionsBoardScreen(),
    ),
    GetPage(
      name: Routes.attendanceRegularizationReview,
      page: () => const AttendanceRegularizationReviewScreen(),
    ),
    GetPage(
      name: Routes.holidayCalendarManagement,
      page: () => const HolidayCalendarManagementScreen(),
    ),
    GetPage(name: Routes.payrollPrep, page: () => const PayrollPrepScreen()),
    GetPage(
      name: Routes.roleAccessManagement,
      page: () => const RoleAccessManagementScreen(),
    ),
    GetPage(
      name: Routes.shiftAssignmentPlanner,
      page: () => const ShiftAssignmentPlannerScreen(),
    ),
    GetPage(
      name: Routes.timeOff,
      page: () => const TimeOffScreen(),
      binding: TimeOffBinding(),
    ),
    GetPage(
      name: applyLeave,
      page: () => const ApplyLeaveScreen(),
      binding: ApplyLeaveBinding(),
    ),
    GetPage(
      name: applyOvertime,
      page: () => const ApplyOvertimeScreen(),
      binding: ApplyOvertimeBinding(),
    ),
    GetPage(
      name: Routes.submitClaim,
      page: () => const SubmitClaimScreen(),
      binding: SubmitClaimBinding(),
    ),
    GetPage(
      name: Routes.myDocuments,
      page: () => const MyDocumentsScreen(),
      binding: MyDocumentsBinding(),
    ),
    GetPage(
      name: paySlip,
      page: () => const PayslipScreen(),
      binding: PayslipBinding(),
    ),
    GetPage(
      name: documentUpload,
      page: () => const DocumentUploadScreen(),
      binding: DocumentUploadBinding(),
    ),
    GetPage(name: organisation, page: () => const OrganisationInfoScreen()),
    GetPage(name: companyPolicy, page: () => const CompanyPolicyScreen()),
    GetPage(
      name: announcements,
      page: () => const AnnouncementsScreen(),
      binding: AnnouncementsBinding(),
    ),
    GetPage(name: adminReports, page: () => const AdminReportsScreen()),
    GetPage(
      name: monthlyAttendanceReport,
      page: () => const MonthlyAttendanceReportScreen(),
    ),
    GetPage(name: latenessReport, page: () => const LatenessReportScreen()),
    GetPage(
      name: overtimeSummaryReport,
      page: () => const OvertimeSummaryReportScreen(),
    ),
    GetPage(
      name: leaveClaimSummaryReport,
      page: () => const LeaveClaimSummaryReportScreen(),
    ),
    GetPage(name: adminSettings, page: () => const AdminSettingsScreen()),
    GetPage(
      name: employeeManagement,
      page: () => const EmployeeManagementScreen(),
    ),
    GetPage(
      name: departmentDashboard,
      page: () => const DepartmentDashboardScreen(),
    ),
  ];
}
