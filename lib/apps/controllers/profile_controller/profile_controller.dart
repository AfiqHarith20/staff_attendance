import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:staff_attendance/apps/controllers/locale_controller/locale_controller.dart';
import 'package:staff_attendance/apps/routes/routes.dart';
import 'package:staff_attendance/core/services/storage_service.dart';
import 'package:staff_attendance/core/services/token_controller.dart';

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

  final _fullName = 'Ahmad Nizam'.obs;
  final _email = 'ahmad@clokk.app'.obs;
  final _phone = '+60 12-345 6789'.obs;
  final _employeeId = 'EMP-0042'.obs;
  final _office = 'Operations · Clokk HQ'.obs;

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final employeeIdController = TextEditingController();
  final officeController = TextEditingController();

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  int get presentCount => 22;
  int get absentCount => 2;
  int get lateCount => 3;
  int get mcCount => 1;

  String get fullName => _fullName.value;
  String get email => _email.value;
  String get phone => _phone.value;
  String get employeeId => _employeeId.value;
  String get office => _office.value;

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
    final role = (_box.read<String>('user_role') ?? 'staff').toLowerCase();
    return role.contains('admin') ? 'admin_owner'.tr : 'staff'.tr;
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
    _fullName.value = _box.read<String>('user_name') ?? 'Ahmad Nizam';
    _email.value = _box.read<String>('user_email') ?? 'ahmad@clokk.app';
    _phone.value = _box.read<String>('user_phone') ?? '+60 12-345 6789';
    _employeeId.value = _box.read<String>('employee_id') ?? 'EMP-0042';
    _office.value = _box.read<String>('office_name') ?? 'Operations · Clokk HQ';
    profileImageBase64.value = _box.read<String>(_profileImageKey);
    _seedProfileControllers();
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
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      title: Text(label),
      trailing: Icon(
        selected ? Icons.check_circle_rounded : Icons.circle_outlined,
        color: selected ? const Color(0xFF185FA5) : const Color(0xFF94A3B8),
      ),
    );
  }

  void changeLanguage(Locale locale) {
    Get.find<LocaleController>().setLocale(locale);
    selectedLanguageCode.value = locale.languageCode;
    if (Get.isBottomSheetOpen ?? false) {
      Get.back();
    }
    Get.snackbar(
      'language'.tr,
      'language_updated'.tr,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
    );
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
                        return Column(
                          children: [
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundColor: const Color(0xFF185FA5),
                                  backgroundImage: imageBytes != null
                                      ? MemoryImage(imageBytes)
                                      : null,
                                  child: imageBytes == null
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
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final bytes = result.files.single.bytes;
    if (bytes == null || bytes.isEmpty) {
      Get.snackbar(
        'profile_details'.tr,
        'image_pick_failed'.tr,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
      );
      return;
    }

    profileImageBase64.value = base64Encode(bytes);
  }

  void removeProfileImage() {
    profileImageBase64.value = null;
  }

  Future<void> saveProfileDetails() async {
    final name = fullNameController.text.trim();
    final mail = emailController.text.trim();
    final phoneNumber = phoneController.text.trim();
    final id = employeeIdController.text.trim();
    final officeName = officeController.text.trim();

    if ([name, mail, phoneNumber, id, officeName].any((e) => e.isEmpty)) {
      Get.snackbar(
        'profile_details'.tr,
        'fill_all_fields'.tr,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
      );
      return;
    }

    if (!mail.contains('@')) {
      Get.snackbar(
        'profile_details'.tr,
        'invalid_email'.tr,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
      );
      return;
    }

    isSavingProfile.value = true;
    await Future.delayed(const Duration(milliseconds: 700));

    _fullName.value = name;
    _email.value = mail;
    _phone.value = phoneNumber;
    _employeeId.value = id;
    _office.value = officeName;

    await _box.write('user_name', name);
    await _box.write('user_email', mail);
    await _box.write('user_phone', phoneNumber);
    await _box.write('employee_id', id);
    await _box.write('office_name', officeName);

    if (profileImageBase64.value == null || profileImageBase64.value!.isEmpty) {
      await _box.remove(_profileImageKey);
    } else {
      await _box.write(_profileImageKey, profileImageBase64.value);
    }

    isSavingProfile.value = false;

    if (Get.isBottomSheetOpen ?? false) {
      Get.back();
    }

    Get.snackbar(
      'profile_details'.tr,
      'profile_updated'.tr,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
    );
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
      Get.snackbar(
        'change_password'.tr,
        'fill_all_fields'.tr,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
      );
      return;
    }

    if (next.length < 6) {
      Get.snackbar(
        'change_password'.tr,
        'password_too_short'.tr,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
      );
      return;
    }

    if (next != confirm) {
      Get.snackbar(
        'change_password'.tr,
        'password_mismatch'.tr,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
      );
      return;
    }

    isUpdatingPassword.value = true;
    await Future.delayed(const Duration(milliseconds: 900));
    isUpdatingPassword.value = false;

    if (Get.isBottomSheetOpen ?? false) {
      Get.back();
    }

    Get.snackbar(
      'change_password'.tr,
      'password_updated'.tr,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
    );
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
      await StorageService.to.clearAuthToken();
      await _box.remove('user_role');

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

  const _ProfileEditField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.fillColor,
    required this.borderColor,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
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
