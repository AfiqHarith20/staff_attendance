import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/remote_work_request_controller/remote_work_request_controller.dart';
import 'package:staff_attendance/widgets/form_widget.dart';

class ApplyRemoteWorkScreen extends GetView<RemoteWorkRequestController> {
  const ApplyRemoteWorkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            appBar(isDark: isDark, title: 'remote_work_request'.tr),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _RemoteHero(isDark: isDark),
                      const SizedBox(height: 16),

                      formSectionCard(
                        isDark: isDark,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sectionLabel(label: 'date_range'.tr, isDark: isDark),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: datePickerTile(
                                    label: 'start_date'.tr,
                                    isDark: isDark,
                                    dateObs: controller.startDate,
                                    onTap: () => controller.pickStartDate(context),
                                    icon: Icons.calendar_today_rounded,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: datePickerTile(
                                    label: 'end_date'.tr,
                                    isDark: isDark,
                                    dateObs: controller.endDate,
                                    onTap: () => controller.pickEndDate(context),
                                    icon: Icons.event_rounded,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      formSectionCard(
                        isDark: isDark,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sectionLabel(label: 'work_location'.tr, isDark: isDark),
                            const SizedBox(height: 10),
                            _LocationSelector(isDark: isDark),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      formSectionCard(
                        isDark: isDark,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sectionLabel(label: 'reason'.tr, isDark: isDark),
                            const SizedBox(height: 10),
                            reasonField(
                              ctrl: controller.reasonController,
                              isDark: isDark,
                              hint: 'remote_reason_hint'.tr,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      noteCard(
                        isDark: isDark,
                        lines: [
                          'remote_approval_note'.tr,
                          'remote_location_note'.tr,
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: submitBar(
        isDark: isDark,
        label: 'submit_remote'.tr,
        color: const Color(0xFF7F77DD),
        onTap: controller.submit,
        isSubmitting: controller.isSubmitting,
      ),
    );
  }
}

class _RemoteHero extends StatelessWidget {
  final bool isDark;
  const _RemoteHero({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF2D1B6B), Color(0xFF0F172A)]
              : const [Color(0xFF7F77DD), Color(0xFF9B8FEE)],
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.home_work_rounded, color: Colors.white, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'remote_work_title'.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'remote_work_subtitle'.tr,
                  style: const TextStyle(color: Color(0xFFDDD9FF), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Location selector ─────────────────────────────────────────────────────────
class _LocationSelector extends GetView<RemoteWorkRequestController> {
  final bool isDark;
  const _LocationSelector({required this.isDark});

  static const _locations = [
    ('Home', 'location_home', Icons.home_rounded, 0xFF16A34A),
    ('Client site', 'location_client_site', Icons.business_rounded, 0xFF185FA5),
    ('Co-working space', 'location_coworking', Icons.desktop_mac_rounded, 0xFF7F77DD),
    ('Other', 'location_other', Icons.more_horiz_rounded, 0xFF64748B),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _locations.map((loc) {
          final isActive = controller.workLocation.value == loc.$1;
          final color = Color(loc.$4);
          return GestureDetector(
            onTap: () => controller.workLocation(loc.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isActive ? color.withValues(alpha: 0.12) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isActive
                      ? color
                      : isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    loc.$3,
                    size: 15,
                    color: isActive
                        ? color
                        : isDark
                        ? const Color(0xFF64748B)
                        : const Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    loc.$2.tr,
                    style: TextStyle(
                      color: isActive
                          ? color
                          : isDark
                          ? const Color(0xFF64748B)
                          : const Color(0xFF94A3B8),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
