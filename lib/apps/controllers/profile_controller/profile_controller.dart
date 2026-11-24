import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart' hide Response;
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:get_storage/get_storage.dart';
import 'package:staff_attendance/api/api_client.dart';
import 'package:staff_attendance/apps/controllers/locale_controller/locale_controller.dart';
import 'package:staff_attendance/apps/routes/api_routes.dart';
import 'package:staff_attendance/apps/routes/routes.dart';
import 'package:staff_attendance/core/services/device_service.dart';
import 'package:staff_attendance/core/services/storage_service.dart';
import 'package:staff_attendance/core/services/token_controller.dart';
import 'package:staff_attendance/widgets/app_toast.dart';

class ProfileController extends GetxController {
  static const _notificationsKey = 'profile_notifications_enabled';
  static const _profileImageKey = 'profile_image_base64';

  final _box = GetStorage();

  final notificationsEnabled = true.obs;
  final selectedLanguageCode = 'en'.obs;
  final isUpdatingPassword = false.obs;
  final isSavingProfile = false.obs;
  final obscureCurrentPassword = true.obs;
  final obscureNewPassword = true.obs;
  final obscureConfirmPassword = true.obs;
  final profileImageBase64 = RxnString();
  // Path of a newly picked avatar file, cleared after upload.
  // May be null on Android SAF (content:// URI) — use _pendingAvatarBytes fallback.
  final _pendingAvatarPath = RxnString();
  final _pendingAvatarName = RxnString();
  // Network URL from the server (populated on login and after PATCH /user).
  final avatarUrl = RxnString();

  final _fullName = '—'.obs;
  final _email = '—'.obs;
  final _phone = '—'.obs;
  final _employeeId = '—'.obs;
  final _office = '—'.obs;
  final _department = '—'.obs;
  final _managerName = '—'.obs;
  final _jobTitle = '—'.obs;
  final _employmentType = '—'.obs;
  final _joinedOn = '—'.obs;
  final _emergencyContactName = '—'.obs;
  final _emergencyContactPhone = '—'.obs;
  final _emergencyContactRelation = '—'.obs;
  final _bankName = '—'.obs;
  final _bankAccountMasked = '—'.obs;
  final _payrollCycle = '—'.obs;
  final _lastLogin = '—'.obs;
  final _activeDevice = '—'.obs;
  final biometricLoginEnabled = false.obs;

  final presentCount = 0.obs;
  final absentCount = 0.obs;
  final lateCount = 0.obs;
  final mcCount = 0.obs;

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final employeeIdController = TextEditingController();
  final officeController = TextEditingController();

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String get fullName => _fullName.value;
  String get email => _email.value;
  String get phone => _phone.value;
  String get employeeId => _employeeId.value;
  String get office => _office.value;
  String get department => _department.value;
  String get managerName => _managerName.value;
  String get jobTitle => _jobTitle.value;
  String get employmentType => _employmentType.value;
  String get joinedOn => _joinedOn.value;
  String get emergencyContactName => _emergencyContactName.value;
  String get emergencyContactPhone => _emergencyContactPhone.value;
  String get emergencyContactRelation => _emergencyContactRelation.value;
  String get bankName => _bankName.value;
  String get bankAccountMasked => _bankAccountMasked.value;
  String get payrollCycle => _payrollCycle.value;
  String get lastLogin => _lastLogin.value;
  String get activeDevice => _activeDevice.value;

  Uint8List? get profileImageBytes {
    final encoded = profileImageBase64.value;
    if (encoded == null || encoded.isEmpty) return null;
    try {
      return base64Decode(encoded);
    } catch (_) {
      return null;
    }
  }

  String get roleLabel {
    final raw = _box.read<String>('user_role') ?? '';
    switch (raw.toLowerCase()) {
      case 'admin':
        return 'Admin';
      case 'super_admin':
        return 'Super Admin';
      case 'owner':
        return 'Owner';
      case 'hr':
        return 'HR';
      case 'manager':
        return 'Manager';
      case 'staff':
        return 'staff'.tr;
      default:
        return raw.isNotEmpty ? raw : 'staff'.tr;
    }
  }

  String get currentLanguageLabel =>
      selectedLanguageCode.value == 'my' ? 'malay'.tr : 'english'.tr;

  String get initials {
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) return 'NA';
    if (parts.length == 1) {
      final name = parts.first;
      return name.length >= 2
          ? name.substring(0, 2).toUpperCase()
          : name.toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  void onInit() {
    super.onInit();
    notificationsEnabled.value = _box.read<bool>(_notificationsKey) ?? true;
    selectedLanguageCode.value = Get.locale?.languageCode ?? 'en';
    _fullName.value = _box.read<String>('user_name') ?? '—';
    _email.value = _box.read<String>('user_email') ?? '—';
    _phone.value = _box.read<String>('user_phone') ?? '—';
    _employeeId.value = _box.read<String>('employee_no') ??
        _box.read<String>('employee_id') ?? '—';
    _office.value = _box.read<String>('office_name') ?? '—';
    _department.value = _box.read<String>('department_name') ?? '—';
    _managerName.value = _box.read<String>('manager_name') ?? '—';
    _jobTitle.value = _box.read<String>('job_title') ?? '—';
    _joinedOn.value = _box.read<String>('joined_on') ?? '—';
    biometricLoginEnabled.value =
        _box.read<bool>('biometric_login_enabled') ?? false;
    profileImageBase64.value = _box.read<String>(_profileImageKey);
    final stored = _box.read<String>('avatar_url');
    avatarUrl.value = stored != null ? ApiList.normalizeUrl(stored) : null;
    _seedProfileControllers();
    _fetchProfile();
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    employeeIdController.dispose();
    officeController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void _seedProfileControllers() {
    fullNameController.text = fullName;
    emailController.text = email;
    phoneController.text = phone;
    employeeIdController.text = employeeId;
    officeController.text = office;
  }

  void toggleNotifications(bool value) {
    notificationsEnabled.value = value;
    _box.write(_notificationsKey, value);
  }

  void toggleBiometricLogin(bool value) {
    biometricLoginEnabled.value = value;
    _box.write('biometric_login_enabled', value);
  }

  void openSessionSheet() {
    final isDark = Get.isDarkMode;
    Get.bottomSheet(
      SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF111827) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Session & Security',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Material(
                color: Colors.transparent,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.phone_iphone_rounded),
                  title: Text(activeDevice),
                  subtitle: Text('Last login: $lastLogin'),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.verified_user_outlined),
                  title: const Text('Sign out other devices'),
                  subtitle: const Text(
                    'End other active sessions for this account',
                  ),
                  onTap: () {
                    if (Get.isBottomSheetOpen ?? false) Get.back();
                    AppToast.success(
                      'Session & Security',
                      'Other sessions have been signed out.',
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void openLanguageSheet() {
    final isDark = Get.isDarkMode;

    Get.bottomSheet(
      SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF111827) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'change_language'.tr,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              _languageTile(
                label: 'english'.tr,
                value: 'en',
                onTap: () => changeLanguage(const Locale('en', 'US')),
              ),
              _languageTile(
                label: 'malay'.tr,
                value: 'my',
                onTap: () => changeLanguage(const Locale('my', 'MY')),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _languageTile({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    final selected = selectedLanguageCode.value == value;
    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        onTap: onTap,
        title: Text(label),
        trailing: Icon(
          selected ? Icons.check_circle_rounded : Icons.circle_outlined,
          color: selected ? const Color(0xFF185FA5) : const Color(0xFF94A3B8),
        ),
      ),
    );
  }

  void changeLanguage(Locale locale) {
    Get.find<LocaleController>().setLocale(locale);
    selectedLanguageCode.value = locale.languageCode;
    if (Get.isBottomSheetOpen ?? false) {
      Get.back();
    }
    AppToast.success('language'.tr, 'language_updated'.tr);
  }

  void openEditProfileSheet() {
    _seedProfileControllers();

    Get.bottomSheet(
      Builder(
        builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final background = isDark ? const Color(0xFF111827) : Colors.white;
          final border = isDark
              ? const Color(0xFF334155)
              : const Color(0xFFE2E8F0);
          final fieldFill = isDark
              ? const Color(0xFF0F172A)
              : const Color(0xFFF8FAFC);
          final muted = isDark
              ? const Color(0xFF94A3B8)
              : const Color(0xFF64748B);

          return SafeArea(
            top: false,
            child: Container(
              decoration: BoxDecoration(
                color: background,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  20,
                  14,
                  20,
                  24 + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: border,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'profile_details'.tr,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'profile_details_helper'.tr,
                      style: TextStyle(color: muted, fontSize: 13, height: 1.4),
                    ),
                    const SizedBox(height: 18),
                    Center(
                      child: Obx(() {
                        final imageBytes = profileImageBytes;
                        final url = avatarUrl.value;
                        final hasNetwork = url != null && url.isNotEmpty;

                        ImageProvider? bgImage;
                        if (imageBytes != null) {
                          bgImage = MemoryImage(imageBytes);
                        } else if (hasNetwork) {
                          bgImage = NetworkImage(url);
                        }

                        return Column(
                          children: [
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundColor: const Color(0xFF185FA5),
                                  backgroundImage: bgImage,
                                  onBackgroundImageError: bgImage != null
                                      ? (_, _) {}
                                      : null,
                                  child: bgImage == null
                                      ? Text(
                                          initials,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 22,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        )
                                      : null,
                                ),
                                Material(
                                  color: const Color(0xFF185FA5),
                                  shape: const CircleBorder(),
                                  child: InkWell(
                                    customBorder: const CircleBorder(),
                                    onTap: pickProfileImage,
                                    child: const Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Icon(
                                        Icons.camera_alt_rounded,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 8,
                              children: [
                                TextButton.icon(
                                  onPressed: pickProfileImage,
                                  icon: const Icon(
                                    Icons.photo_library_outlined,
                                  ),
                                  label: Text('change_photo'.tr),
                                ),
                                if (imageBytes != null)
                                  TextButton(
                                    onPressed: removeProfileImage,
                                    child: Text('remove_photo'.tr),
                                  ),
                              ],
                            ),
                          ],
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    _ProfileEditField(
                      controller: fullNameController,
                      label: 'full_name'.tr,
                      icon: Icons.person_outline_rounded,
                      fillColor: fieldFill,
                      borderColor: border,
                    ),
                    const SizedBox(height: 12),
                    _ProfileEditField(
                      controller: emailController,
                      label: 'email_address'.tr,
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      fillColor: fieldFill,
                      borderColor: border,
                      readOnly: true,
                    ),
                    const SizedBox(height: 12),
                    _ProfileEditField(
                      controller: phoneController,
                      label: 'phone'.tr,
                      icon: Icons.phone_iphone_rounded,
                      keyboardType: TextInputType.phone,
                      fillColor: fieldFill,
                      borderColor: border,
                    ),
                    const SizedBox(height: 12),
                    _ProfileEditField(
                      controller: employeeIdController,
                      label: 'employee_id'.tr,
                      icon: Icons.badge_outlined,
                      fillColor: fieldFill,
                      borderColor: border,
                    ),
                    const SizedBox(height: 12),
                    _ProfileEditField(
                      controller: officeController,
                      label: 'office'.tr,
                      icon: Icons.apartment_outlined,
                      fillColor: fieldFill,
                      borderColor: border,
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              if (Get.isBottomSheetOpen ?? false) {
                                Get.back();
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              side: BorderSide(color: border),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text('cancel'.tr),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Obx(
                            () => FilledButton(
                              onPressed: isSavingProfile.value
                                  ? null
                                  : saveProfileDetails,
                              style: FilledButton.styleFrom(
                                minimumSize: const Size.fromHeight(48),
                                backgroundColor: const Color(0xFF185FA5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: isSavingProfile.value
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text('save_changes'.tr),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  Future<void> pickProfileImage() async {
    final status = await Permission.photos.request();
    if (status.isPermanentlyDenied) {
      openAppSettings();
      return;
    }

    final file = await FilePicker.pickFile(
      type: FileType.image,
    );

    if (file == null) return;

    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      AppToast.failed('profile_details'.tr, 'image_pick_failed'.tr);
      return;
    }

    // Keep bytes for immediate display.
    profileImageBase64.value = base64Encode(bytes);
    // On Android SAF, file.path may be null (content:// URI).
    // Store the filename so MultipartFile.fromBytes can set it correctly.
    _pendingAvatarPath.value = file.path;
    _pendingAvatarName.value = file.name;
  }

  void removeProfileImage() {
    profileImageBase64.value = null;
    _pendingAvatarPath.value = null;
    _pendingAvatarName.value = null;
  }

  // ── Fetch profile from GET /user ───────────────────────────────────────────
  Future<void> _fetchProfile() async {
    try {
      final res = await ApiClient.instance.get(ApiList.currentUser);
      final d = res.data['data'] as Map<String, dynamic>;

      // ── Core identity ──────────────────────────────────────────────────────
      _fullName.value = d['name'] as String? ?? _fullName.value;
      _email.value = d['email'] as String? ?? _email.value;
      _phone.value = d['phone'] as String? ?? _phone.value;
      _employeeId.value = d['employee_no'] as String? ?? _employeeId.value;
      _jobTitle.value = d['job_title'] as String? ?? _jobTitle.value;
      _department.value = d['department'] as String? ?? _department.value;
      if (d['joined_on'] != null) {
        final raw = d['joined_on'] as String;
        final dt = DateTime.tryParse(raw)?.toLocal();
        _joinedOn.value =
            dt != null ? DateFormat('d MMM yyyy').format(dt) : raw;
      }

      // ── New fields ─────────────────────────────────────────────────────────
      _office.value = d['office_name'] as String? ?? _office.value;
      _managerName.value = d['manager_name'] as String? ?? _managerName.value;
      _employmentType.value =
          d['employment_type'] as String? ?? _employmentType.value;
      _emergencyContactName.value =
          d['emergency_contact_name'] as String? ?? _emergencyContactName.value;
      _emergencyContactPhone.value =
          d['emergency_contact_phone'] as String? ?? _emergencyContactPhone.value;
      _emergencyContactRelation.value =
          d['emergency_contact_relation'] as String? ?? _emergencyContactRelation.value;
      _bankName.value = d['bank_name'] as String? ?? _bankName.value;
      _bankAccountMasked.value =
          d['bank_account_masked'] as String? ?? _bankAccountMasked.value;
      _payrollCycle.value =
          d['payroll_cycle'] as String? ?? _payrollCycle.value;
      _activeDevice.value =
          d['active_device'] as String? ?? _activeDevice.value;

      // ── last_login_at: ISO 8601 → "24 Jul 2026, 8:14 AM" ─────────────────
      final rawLogin = d['last_login_at'] as String?;
      if (rawLogin != null) {
        final dt = DateTime.tryParse(rawLogin)?.toLocal();
        if (dt != null) {
          _lastLogin.value = DateFormat('d MMM yyyy, h:mm a').format(dt);
        }
      }

      // ── Attendance stats ───────────────────────────────────────────────────
      final stats = d['stats'] as Map<String, dynamic>?;
      if (stats != null) {
        presentCount.value = (stats['present'] as num?)?.toInt() ?? 0;
        absentCount.value = (stats['absent'] as num?)?.toInt() ?? 0;
        lateCount.value = (stats['late'] as num?)?.toInt() ?? 0;
        mcCount.value = (stats['mc'] as num?)?.toInt() ?? 0;
      }

      // ── Avatar ─────────────────────────────────────────────────────────────
      if (d['avatar_url'] != null) {
        final url = ApiList.normalizeUrl(d['avatar_url'] as String);
        avatarUrl.value = url;
        _box.write('avatar_url', url);
      }

      // Persist core fields so next cold start shows fresh values.
      await _box.write('user_name', _fullName.value);
      await _box.write('user_phone', _phone.value);
      await _box.write('employee_no', _employeeId.value);
      await _box.write('job_title', _jobTitle.value);
      await _box.write('department_name', _department.value);
      await _box.write('office_name', _office.value);
      await _box.write('manager_name', _managerName.value);

      _seedProfileControllers();
    } catch (_) {
      // Non-blocking — cached values remain.
    }
  }

  Future<void> saveProfileDetails() async {
    final name = fullNameController.text.trim();
    final phoneNumber = phoneController.text.trim();

    if (name.isEmpty) {
      AppToast.failed('profile_details'.tr, 'fill_all_fields'.tr);
      return;
    }

    isSavingProfile.value = true;
    try {
      dynamic payload;
      Options? options;
      final avatarPath = _pendingAvatarPath.value;
      final avatarBytes = profileImageBytes; // decoded from base64
      final avatarName = _pendingAvatarName.value ?? 'avatar.jpg';

      final hasNewAvatar = avatarPath != null || avatarBytes != null;
      if (hasNewAvatar) {
        // Build multipart file: prefer file path (direct disk read by Dio);
        // fall back to in-memory bytes for Android SAF where path is null (BUG-03).
        final MultipartFile avatarFile;
        if (avatarPath != null) {
          avatarFile = await MultipartFile.fromFile(avatarPath, filename: avatarName);
        } else {
          avatarFile = MultipartFile.fromBytes(avatarBytes!, filename: avatarName);
        }
        payload = FormData.fromMap({
          'name': name,
          if (phoneNumber.isNotEmpty) 'phone': phoneNumber,
          'avatar': avatarFile,
        });
        options = Options(headers: {'Content-Type': 'multipart/form-data'});
      } else {
        payload = {
          'name': name,
          if (phoneNumber.isNotEmpty) 'phone': phoneNumber,
        };
      }

      final res = await ApiClient.instance.patch(
        ApiList.currentUser,
        data: payload,
        options: options,
      );

      final d = res.data['data'] as Map<String, dynamic>;
      _fullName.value = d['name'] as String? ?? name;
      _phone.value = d['phone'] as String? ?? phoneNumber;
      if (d['avatar_url'] != null) {
        final url = ApiList.normalizeUrl(d['avatar_url'] as String);
        avatarUrl.value = url;
        await _box.write('avatar_url', url);
      }
      _pendingAvatarPath.value = null;
      _pendingAvatarName.value = null;

      await _box.write('user_name', _fullName.value);
      await _box.write('user_phone', _phone.value);

      // Also persist local-only fields.
      final id = employeeIdController.text.trim();
      final officeName = officeController.text.trim();
      if (id.isNotEmpty) await _box.write('employee_id', id);
      if (officeName.isNotEmpty) await _box.write('office_name', officeName);
      _employeeId.value = id.isNotEmpty ? id : _employeeId.value;
      _office.value = officeName.isNotEmpty ? officeName : _office.value;

      if (profileImageBase64.value != null) {
        await _box.write(_profileImageKey, profileImageBase64.value);
      } else {
        await _box.remove(_profileImageKey);
      }

      if (Get.isBottomSheetOpen ?? false) Get.back();
      AppToast.success('profile_details'.tr, 'profile_updated'.tr);
    } on DioException catch (e) {
      AppToast.failed(
        'profile_details'.tr,
        ApiClient.extractError(e, fallback: 'submission_failed'.tr),
      );
    } finally {
      isSavingProfile.value = false;
    }
  }

  void openChangePasswordSheet() {
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
    obscureCurrentPassword.value = true;
    obscureNewPassword.value = true;
    obscureConfirmPassword.value = true;

    Get.bottomSheet(
      Builder(
        builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final background = isDark ? const Color(0xFF111827) : Colors.white;
          final border = isDark
              ? const Color(0xFF334155)
              : const Color(0xFFE2E8F0);
          final fieldFill = isDark
              ? const Color(0xFF0F172A)
              : const Color(0xFFF8FAFC);
          final muted = isDark
              ? const Color(0xFF94A3B8)
              : const Color(0xFF64748B);

          return SafeArea(
            top: false,
            child: Container(
              decoration: BoxDecoration(
                color: background,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  20,
                  14,
                  20,
                  24 + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: border,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF185FA5).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.lock_reset_rounded,
                        color: Color(0xFF185FA5),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'change_password'.tr,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'change_password_helper'.tr,
                      style: TextStyle(color: muted, fontSize: 13, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF185FA5).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(
                            0xFF185FA5,
                          ).withValues(alpha: 0.14),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.shield_outlined,
                            size: 18,
                            color: Color(0xFF185FA5),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'password_sheet_hint'.tr,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Obx(
                      () => _PasswordField(
                        controller: currentPasswordController,
                        label: 'current_password'.tr,
                        icon: Icons.lock_outline_rounded,
                        obscureText: obscureCurrentPassword.value,
                        onToggleVisibility: () =>
                            obscureCurrentPassword.toggle(),
                        fillColor: fieldFill,
                        borderColor: border,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(
                      () => _PasswordField(
                        controller: newPasswordController,
                        label: 'new_password'.tr,
                        icon: Icons.key_rounded,
                        obscureText: obscureNewPassword.value,
                        onToggleVisibility: () => obscureNewPassword.toggle(),
                        fillColor: fieldFill,
                        borderColor: border,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(
                      () => _PasswordField(
                        controller: confirmPasswordController,
                        label: 'confirm_new_password'.tr,
                        icon: Icons.verified_user_outlined,
                        obscureText: obscureConfirmPassword.value,
                        onToggleVisibility: () =>
                            obscureConfirmPassword.toggle(),
                        fillColor: fieldFill,
                        borderColor: border,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              if (Get.isBottomSheetOpen ?? false) {
                                Get.back();
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              side: BorderSide(color: border),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text('cancel'.tr),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Obx(
                            () => FilledButton(
                              onPressed: isUpdatingPassword.value
                                  ? null
                                  : submitPasswordChange,
                              style: FilledButton.styleFrom(
                                minimumSize: const Size.fromHeight(48),
                                backgroundColor: const Color(0xFF185FA5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: isUpdatingPassword.value
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text('update_password'.tr),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  Future<void> submitPasswordChange() async {
    final current = currentPasswordController.text.trim();
    final next = newPasswordController.text.trim();
    final confirm = confirmPasswordController.text.trim();

    if (current.isEmpty || next.isEmpty || confirm.isEmpty) {
      AppToast.failed('change_password'.tr, 'fill_all_fields'.tr);
      return;
    }

    if (next.length < 8) {
      AppToast.failed('change_password'.tr, 'password_too_short'.tr);
      return;
    }

    if (next != confirm) {
      AppToast.failed('change_password'.tr, 'password_mismatch'.tr);
      return;
    }

    isUpdatingPassword.value = true;
    try {
      await ApiClient.instance.post(
        ApiList.changePassword,
        data: {
          'current_password': current,
          'password': next,
          'password_confirmation': confirm,
        },
      );
      if (Get.isBottomSheetOpen ?? false) Get.back();
      AppToast.success('change_password'.tr, 'password_updated'.tr);
    } on DioException catch (e) {
      AppToast.failed(
        'change_password'.tr,
        ApiClient.extractError(e, fallback: 'submission_failed'.tr),
      );
    } finally {
      isUpdatingPassword.value = false;
    }
  }

  void confirmLogout() {
    Get.dialog(
      AlertDialog(
        title: Text('confirm_logout'.tr),
        content: Text('confirm_logout_message'.tr),
        actions: [
          TextButton(onPressed: Get.back, child: Text('cancel'.tr)),
          FilledButton(onPressed: logout, child: Text('sign_out'.tr)),
        ],
      ),
    );
  }

  Future<void> logout() async {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      // Deregister push token BEFORE revoking auth (needs a valid Bearer token).
      await DeviceService.unregister();

      // Revoke the Sanctum token server-side (fire-and-forget: continue even
      // if the server is unreachable so the user is never stuck logged in).
      try {
        await ApiClient.instance.post(ApiList.logout);
      } catch (_) {}

      await StorageService.to.clearAuthToken();

      // Clear all user-specific profile data so the next user on this device
      // starts with a clean slate. Device-level prefs (remember_me,
      // saved_email, saved_password, mock_mode) are intentionally kept.
      for (final key in const [
        'user_role',
        'is_admin',
        'user_permissions',
        'user_name',
        'user_email',
        'job_title',
        'department_name',
        'employee_no',
        'user_phone',
        'joined_on',
        'avatar_url',
        'profile_image_base64',
        'office_name',
        'manager_name',
        'profile_notifications_enabled',
        'biometric_login_enabled',
      ]) {
        await _box.remove(key);
      }

      if (Get.isRegistered<TokenController>()) {
        final tokenController = Get.find<TokenController>();
        tokenController.clearToken();
        try {
          Get.delete<TokenController>(force: true);
        } catch (_) {}
      }
    } finally {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      Get.offAllNamed(Routes.login);
    }
  }
}

class _ProfileEditField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final Color fillColor;
  final Color borderColor;
  final TextInputType? keyboardType;
  final bool readOnly;

  const _ProfileEditField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.fillColor,
    required this.borderColor,
    this.keyboardType,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: fillColor,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF185FA5), width: 1.4),
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final VoidCallback onToggleVisibility;
  final Color fillColor;
  final Color borderColor;

  const _PasswordField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.obscureText,
    required this.onToggleVisibility,
    required this.fillColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      obscuringCharacter: '•',
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: fillColor,
        prefixIcon: Icon(icon, size: 20),
        suffixIcon: IconButton(
          onPressed: onToggleVisibility,
          icon: Icon(
            obscureText
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF185FA5), width: 1.4),
        ),
      ),
    );
  }
}
