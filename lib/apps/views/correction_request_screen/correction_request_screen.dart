import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:staff_attendance/apps/controllers/correction_request_controller/correction_request_controller.dart';
import 'package:staff_attendance/widgets/app_page_widgets.dart';

class CorrectionRequestScreen extends GetView<CorrectionRequestController> {
  const CorrectionRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Form(
          key: controller.formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            children: [
              Row(
                children: [
                  const AppBackButton(),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Correction Request',
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _Card(
                isDark: isDark,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Request details',
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Obx(
                      () => Material(
                        color: Colors.transparent,
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.event_rounded),
                          title: const Text('Attendance date'),
                          subtitle: Text(
                            DateFormat(
                              'EEEE, d MMM yyyy',
                            ).format(controller.selectedDate.value),
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => controller.pickDate(context),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(
                      () => DropdownButtonFormField<String>(
                        initialValue: controller.requestType.value,
                        items: controller.requestTypes
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) controller.requestType(value);
                        },
                        decoration: _inputDecoration(
                          label: 'Correction type',
                          icon: Icons.tune_rounded,
                          isDark: isDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: controller.checkInController,
                            decoration: _inputDecoration(
                              label: 'Correct check-in',
                              hint: '9:00 AM',
                              icon: Icons.login_rounded,
                              isDark: isDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: controller.checkOutController,
                            decoration: _inputDecoration(
                              label: 'Correct check-out',
                              hint: '6:00 PM',
                              icon: Icons.logout_rounded,
                              isDark: isDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: controller.reasonController,
                      minLines: 4,
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Reason is required';
                        }
                        return null;
                      },
                      decoration: _inputDecoration(
                        label: 'Reason',
                        hint: 'Explain what happened for HR review',
                        icon: Icons.notes_rounded,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Obx(
            () => FilledButton.icon(
              onPressed: controller.isSubmitting.value
                  ? null
                  : controller.submit,
              icon: controller.isSubmitting.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send_rounded),
              label: const Text('Submit request'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: const Color(0xFF185FA5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    required bool isDark,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, size: 20),
      filled: true,
      fillColor: isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFC),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}

class _Card extends StatelessWidget {
  final bool isDark;
  final Widget child;
  const _Card({required this.isDark, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: child,
    );
  }
}
