import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import '../../../controllers/scan_controller/scan_controller.dart';
import '../../../routes/routes.dart';
import '../../../../widgets/responsive_page.dart';

class MyAttendanceScreen extends GetView<ScanController> {
  const MyAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ScanController>()) Get.put(ScanController());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: ResponsivePage(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              children: [
                _Header(isDark: isDark),
                const SizedBox(height: 16),
                _MapCard(isDark: isDark),
                const SizedBox(height: 12),
                _StatusCard(isDark: isDark),
                const SizedBox(height: 10),
                _CheckInButton(isDark: isDark),
                const SizedBox(height: 10),
                _InfoHintWidget(isDark: isDark),
                const SizedBox(height: 12),
                _AttendanceActions(isDark: isDark),
                const SizedBox(height: 12),
                _DocumentShortcutCard(isDark: isDark),
                const SizedBox(height: 16),
                _TodayLogs(isDark: isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AttendanceActions extends StatelessWidget {
  final bool isDark;
  const _AttendanceActions({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Get.toNamed(Routes.attendanceHistory),
            icon: const Icon(Icons.history_rounded, size: 18),
            label: const Text('History'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF185FA5),
              side: const BorderSide(color: Color(0xFF185FA5)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Get.toNamed(Routes.correctionRequest),
            icon: const Icon(Icons.edit_calendar_rounded, size: 18),
            label: const Text('Correct'),
            style: OutlinedButton.styleFrom(
              foregroundColor: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
              side: BorderSide(
                color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final bool isDark;
  const _Header({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Attendance',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              DateFormat('EEEE, d MMM yyyy').format(DateTime.now()),
              style: TextStyle(
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                fontSize: 12,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Text(
            'Attendance only',
            style: TextStyle(
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _MapCard extends GetView<ScanController> {
  final bool isDark;
  const _MapCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 170,
        child: Obx(() {
          final hasPos = controller.currentLat.value != 0.0;
          final office = LatLng(controller.officeLat, controller.officeLng);
          final staff = LatLng(
            controller.currentLat.value,
            controller.currentLng.value,
          );
          final inRange = controller.isInRange;

          return Stack(
            children: [
              GoogleMap(
                key: ValueKey(hasPos),
                initialCameraPosition: CameraPosition(
                  target: hasPos ? staff : office,
                  zoom: 16,
                ),
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                compassEnabled: false,
                rotateGesturesEnabled: false,
                tiltGesturesEnabled: false,
                zoomGesturesEnabled: false,
                scrollGesturesEnabled: false,
                circles: {
                  Circle(
                    circleId: const CircleId('office_radius'),
                    center: office,
                    radius: controller.radiusM,
                    fillColor: (inRange
                            ? const Color(0xFF16A34A)
                            : const Color(0xFFDC2626))
                        .withValues(alpha: 0.12),
                    strokeColor: (inRange
                            ? const Color(0xFF16A34A)
                            : const Color(0xFFDC2626))
                        .withValues(alpha: 0.4),
                    strokeWidth: 2,
                  ),
                },
                markers: {
                  Marker(
                    markerId: const MarkerId('office'),
                    position: office,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueAzure,
                    ),
                    infoWindow: const InfoWindow(title: 'Clokk HQ · Cyberjaya'),
                  ),
                  if (hasPos)
                    Marker(
                      markerId: const MarkerId('staff'),
                      position: staff,
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        inRange
                            ? BitmapDescriptor.hueGreen
                            : BitmapDescriptor.hueRed,
                      ),
                      infoWindow: InfoWindow(
                        title: inRange ? 'In Range' : 'Out of Range',
                      ),
                    ),
                },
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.75)
                        : Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Clokk HQ · Cyberjaya',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              if (hasPos)
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: inRange
                          ? const Color(0xFF16A34A).withValues(alpha: 0.85)
                          : const Color(0xFFDC2626).withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Obx(
                      () => Text(
                        '${controller.distanceM.value.toStringAsFixed(0)}m away',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _StatusCard extends GetView<ScanController> {
  final bool isDark;
  const _StatusCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final status = controller.checkInStatus.value;

      final (
        Color accent,
        Color bg,
        Color border,
        IconData icon,
        String title,
        String sub,
      ) = switch (status) {
        CheckInStatus.locating => (
          const Color(0xFF378ADD),
          const Color(0xFF378ADD).withValues(alpha: 0.08),
          const Color(0xFF378ADD).withValues(alpha: 0.2),
          Icons.gps_fixed_rounded,
          'Getting your location…',
          'Please wait',
        ),
        CheckInStatus.inRange => (
          const Color(0xFF16A34A),
          const Color(0xFF16A34A).withValues(alpha: 0.08),
          const Color(0xFF16A34A).withValues(alpha: 0.2),
          Icons.location_on_rounded,
          "You're within range",
          '${controller.distanceM.value.toStringAsFixed(0)}m from office · max ${controller.radiusM.toInt()}m',
        ),
        CheckInStatus.outOfRange => (
          const Color(0xFFDC2626),
          const Color(0xFFDC2626).withValues(alpha: 0.06),
          const Color(0xFFDC2626).withValues(alpha: 0.15),
          Icons.location_off_rounded,
          'Too far from office',
          '${controller.distanceM.value.toStringAsFixed(0)}m away · must be within ${controller.radiusM.toInt()}m',
        ),
        CheckInStatus.success => (
          const Color(0xFF16A34A),
          const Color(0xFF16A34A).withValues(alpha: 0.08),
          const Color(0xFF16A34A).withValues(alpha: 0.2),
          Icons.check_circle_outline_rounded,
          'Check-in successful!',
          controller.checkInMessage.value,
        ),
        CheckInStatus.alreadyIn => (
          const Color(0xFF378ADD),
          const Color(0xFF378ADD).withValues(alpha: 0.08),
          const Color(0xFF378ADD).withValues(alpha: 0.2),
          Icons.info_outline_rounded,
          'Already checked in',
          controller.checkInMessage.value,
        ),
        CheckInStatus.error => (
          const Color(0xFFF59E0B),
          const Color(0xFFF59E0B).withValues(alpha: 0.08),
          const Color(0xFFF59E0B).withValues(alpha: 0.2),
          Icons.warning_amber_rounded,
          'Location unavailable',
          controller.locationError.value,
        ),
        _ => (
          const Color(0xFF94A3B8),
          const Color(0xFF94A3B8).withValues(alpha: 0.08),
          const Color(0xFF94A3B8).withValues(alpha: 0.2),
          Icons.location_searching_rounded,
          'Checking location…',
          '',
        ),
      };

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: status == CheckInStatus.locating
                  ? Padding(
                      padding: const EdgeInsets.all(10),
                      child: CircularProgressIndicator(strokeWidth: 2, color: accent),
                    )
                  : Icon(icon, color: accent, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: accent,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (sub.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      sub,
                      style: TextStyle(
                        color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(
                  () => Switch.adaptive(
                    value: controller.geofenceEnabled.value,
                    onChanged: controller.setGeofenceEnabled,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Geofence',
                  style: TextStyle(
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _CheckInButton extends GetView<ScanController> {
  final bool isDark;
  const _CheckInButton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final status = controller.checkInStatus.value;
      final isLoading = controller.isCheckingIn.value;
      final isDone =
          status == CheckInStatus.success || status == CheckInStatus.alreadyIn;
      final hasTodayCheckInLog = controller.todayLogs.any(
        (log) => log.type == 'checkin',
      );
      final hasCheckedInToday =
          controller.checkedInToday.value && hasTodayCheckInLog;
      final canCheckIn =
          controller.isInRange && !isLoading && !isDone && !hasCheckedInToday;
      final canCheckOut = hasCheckedInToday && !isLoading;

      return SizedBox(
        width: double.infinity,
        height: 54,
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: canCheckIn ? controller.checkIn : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDone
                      ? const Color(0xFF1E293B)
                      : canCheckIn
                      ? const Color(0xFF185FA5)
                      : isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFE2E8F0),
                  disabledBackgroundColor: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFE2E8F0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        isDone ? 'checked_in'.tr : 'check_in_now'.tr,
                        style: TextStyle(
                          color: canCheckIn || isDone
                              ? Colors.white
                              : isDark
                              ? const Color(0xFF475569)
                              : const Color(0xFF94A3B8),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: canCheckOut ? controller.checkOut : null,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: canCheckOut
                        ? const Color(0xFF185FA5)
                        : isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                  ),
                  backgroundColor: isDark
                      ? Colors.white.withValues(alpha: 0.02)
                      : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'check_out'.tr,
                  style: TextStyle(
                    color: canCheckOut
                        ? const Color(0xFF185FA5)
                        : const Color(0xFF94A3B8),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _InfoHintWidget extends StatelessWidget {
  final bool isDark;
  const _InfoHintWidget({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF378ADD).withValues(alpha: 0.08)
            : const Color(0xFFE6F1FB),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            Icons.shield_outlined,
            size: 14,
            color: isDark ? const Color(0xFF378ADD) : const Color(0xFF185FA5),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Location is verified server-side. GPS coordinates are recorded with each attendance event.',
              style: TextStyle(
                color: Color(0xFF185FA5),
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentShortcutCard extends StatelessWidget {
  final bool isDark;
  const _DocumentShortcutCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF185FA5).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.folder_open_rounded, color: Color(0xFF185FA5)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need to upload MC or proof?',
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Use My Documents for uploads, filters, and file history.',
                  style: TextStyle(
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Get.toNamed(Routes.myDocuments),
            child: const Text('Open'),
          ),
        ],
      ),
    );
  }
}

class _TodayLogs extends GetView<ScanController> {
  final bool isDark;
  const _TodayLogs({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Today's log",
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            GestureDetector(
              onTap: controller.fetchTodayLogs,
              child: Text(
                'Refresh',
                style: TextStyle(
                  color: isDark ? const Color(0xFF378ADD) : const Color(0xFF185FA5),
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(() {
          if (controller.isLoadingLogs.value) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (controller.todayLogs.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Text(
                'No attendance activity yet today',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
                  fontSize: 13,
                ),
              ),
            );
          }
          return Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.todayLogs.length,
              separatorBuilder: (_, _) => Divider(
                height: 1,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : const Color(0xFFF1F5F9),
              ),
              itemBuilder: (_, i) {
                final log = controller.todayLogs[i];
                final isCheckIn = log.type == 'checkin';
                final dotColor = isCheckIn
                    ? const Color(0xFF4ADE80)
                    : const Color(0xFFF87171);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isCheckIn ? 'Check-in' : 'Check-out',
                              style: TextStyle(
                                color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${log.timeFormatted} · ${log.distanceFormatted}',
                              style: TextStyle(
                                color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isCheckIn
                              ? const Color(0xFF16A34A).withValues(alpha: 0.12)
                              : const Color(0xFFDC2626).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isCheckIn ? 'In' : 'Out',
                          style: TextStyle(
                            color: isCheckIn
                                ? const Color(0xFF4ADE80)
                                : const Color(0xFFF87171),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }
}
