import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import '../../../controllers/scan_controller/scan_controller.dart';
import '../../../models/document_model.dart';
import '../../../widgets/responsive_page.dart';

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
          child: Column(
            children: [
              _Header(isDark: isDark),
              const SizedBox(height: 12),
              _TabBar(isDark: isDark),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(
                  () => IndexedStack(
                    index: controller.tabIndex.value,
                    children: [
                      _CheckInTab(isDark: isDark),
                      _DocumentsTab(isDark: isDark),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────
// HEADER
// ─────────────────────────────────────
class _Header extends GetView<ScanController> {
  final bool isDark;
  const _Header({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
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
                  color: isDark
                      ? const Color(0xFF64748B)
                      : const Color(0xFF94A3B8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────
// TAB BAR
// ─────────────────────────────────────
class _TabBar extends GetView<ScanController> {
  final bool isDark;
  const _TabBar({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _TabPill(label: 'Check-In', index: 0, isDark: isDark),
            _TabPill(label: 'Documents', index: 1, isDark: isDark),
          ],
        ),
      ),
    );
  }
}

class _TabPill extends GetView<ScanController> {
  final String label;
  final int index;
  final bool isDark;
  const _TabPill({
    required this.label,
    required this.index,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Obx(() {
        final active = controller.tabIndex.value == index;
        return GestureDetector(
          onTap: () => controller.tabIndex(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: active ? const Color(0xFF185FA5) : Colors.transparent,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: active
                    ? Colors.white
                    : isDark
                    ? const Color(0xFF64748B)
                    : const Color(0xFF94A3B8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────
// TAB 1 — CHECK-IN (geo)
// ─────────────────────────────────────
class _CheckInTab extends GetView<ScanController> {
  final bool isDark;
  const _CheckInTab({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _MapCard(isDark: isDark),
          const SizedBox(height: 12),
          _StatusCard(isDark: isDark),
          const SizedBox(height: 10),
          _CheckInButton(isDark: isDark),
          const SizedBox(height: 10),
          _InfoHintWidget(isDark: isDark),
          const SizedBox(height: 16),
          _TodayLogs(isDark: isDark),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ── Map card ──
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
          final officeLat = controller.officeLat;
          final officeLng = controller.officeLng;
          final inRange = controller.isInRange;
          final office = LatLng(officeLat, officeLng);
          final staff = LatLng(
            controller.currentLat.value,
            controller.currentLng.value,
          );

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
                    fillColor:
                        (inRange
                                ? const Color(0xFF16A34A)
                                : const Color(0xFFDC2626))
                            .withOpacity(0.12),
                    strokeColor:
                        (inRange
                                ? const Color(0xFF16A34A)
                                : const Color(0xFFDC2626))
                            .withOpacity(0.4),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black.withOpacity(0.75)
                        : Colors.white.withOpacity(0.9),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: inRange
                          ? const Color(0xFF16A34A).withOpacity(0.85)
                          : const Color(0xFFDC2626).withOpacity(0.85),
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

// ── Status card ──
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
          const Color(0xFF378ADD).withOpacity(0.08),
          const Color(0xFF378ADD).withOpacity(0.2),
          Icons.gps_fixed_rounded,
          'Getting your location…',
          'Please wait',
        ),
        CheckInStatus.inRange => (
          const Color(0xFF16A34A),
          const Color(0xFF16A34A).withOpacity(0.08),
          const Color(0xFF16A34A).withOpacity(0.2),
          Icons.location_on_rounded,
          "You're within range",
          '${controller.distanceM.value.toStringAsFixed(0)}m from office · max ${controller.radiusM.toInt()}m',
        ),
        CheckInStatus.outOfRange => (
          const Color(0xFFDC2626),
          const Color(0xFFDC2626).withOpacity(0.06),
          const Color(0xFFDC2626).withOpacity(0.15),
          Icons.location_off_rounded,
          'Too far from office',
          '${controller.distanceM.value.toStringAsFixed(0)}m away · must be within ${controller.radiusM.toInt()}m',
        ),
        CheckInStatus.success => (
          const Color(0xFF16A34A),
          const Color(0xFF16A34A).withOpacity(0.08),
          const Color(0xFF16A34A).withOpacity(0.2),
          Icons.check_circle_outline_rounded,
          'Check-in successful!',
          controller.checkInMessage.value,
        ),
        CheckInStatus.alreadyIn => (
          const Color(0xFF378ADD),
          const Color(0xFF378ADD).withOpacity(0.08),
          const Color(0xFF378ADD).withOpacity(0.2),
          Icons.info_outline_rounded,
          'Already checked in',
          controller.checkInMessage.value,
        ),
        CheckInStatus.error => (
          const Color(0xFFF59E0B),
          const Color(0xFFF59E0B).withOpacity(0.08),
          const Color(0xFFF59E0B).withOpacity(0.2),
          Icons.warning_amber_rounded,
          'Location unavailable',
          controller.locationError.value,
        ),
        _ => (
          const Color(0xFF94A3B8),
          const Color(0xFF94A3B8).withOpacity(0.08),
          const Color(0xFF94A3B8).withOpacity(0.2),
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
                color: accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: status == CheckInStatus.locating
                  ? Padding(
                      padding: const EdgeInsets.all(10),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: accent,
                      ),
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
                        color: isDark
                            ? const Color(0xFF475569)
                            : const Color(0xFF94A3B8),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Geofence toggle: when off, users can check-in from any location;
            // when on, check-in requires being within office radius.
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(
                  () => Switch.adaptive(
                    value: controller.geofenceEnabled.value,
                    onChanged: (v) => controller.setGeofenceEnabled(v),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Geofence',
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (status == CheckInStatus.error)
              GestureDetector(
                onTap: controller.retryLocation,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Retry',
                    style: TextStyle(
                      color: Color(0xFFF59E0B),
                      fontSize: 11,
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

// ── Check-in button ──
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
      // Check-in and check-out should be mutually exclusive.
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
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color?>((
                    states,
                  ) {
                    // keep subtle background but allow default disabled look
                    return isDark
                        ? Colors.white.withOpacity(0.02)
                        : Colors.white;
                  }),
                  side: MaterialStateProperty.resolveWith<BorderSide?>((
                    states,
                  ) {
                    if (states.contains(MaterialState.disabled)) {
                      return BorderSide(
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                      );
                    }
                    return const BorderSide(color: Color(0xFF185FA5));
                  }),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
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

// ── Info hint ──
class _InfoHintWidget extends GetView<ScanController> {
  final bool isDark;
  const _InfoHintWidget({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF378ADD).withOpacity(0.08)
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
          Expanded(
            child: Text(
              'Location is verified server-side. GPS coordinates are recorded with each check-in.',
              style: TextStyle(
                color: isDark
                    ? const Color(0xFF378ADD)
                    : const Color(0xFF185FA5),
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Today's log ──
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
                  color: isDark
                      ? const Color(0xFF378ADD)
                      : const Color(0xFF185FA5),
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
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Text(
                'No check-in yet today',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFF475569)
                      : const Color(0xFF94A3B8),
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
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.todayLogs.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : const Color(0xFFF1F5F9),
              ),
              itemBuilder: (_, i) {
                final log = controller.todayLogs[i];
                final isCheckIn = log.type == 'checkin';
                final dotColor = isCheckIn
                    ? const Color(0xFF4ADE80)
                    : const Color(0xFFF87171);

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 11,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: dotColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isCheckIn ? 'Check-in' : 'Check-out',
                              style: TextStyle(
                                color: isDark
                                    ? const Color(0xFFE2E8F0)
                                    : const Color(0xFF1E293B),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${log.timeFormatted} · ${log.distanceFormatted}',
                              style: TextStyle(
                                color: isDark
                                    ? const Color(0xFF475569)
                                    : const Color(0xFF94A3B8),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isCheckIn
                              ? const Color(0xFF16A34A).withOpacity(0.12)
                              : const Color(0xFFDC2626).withOpacity(0.1),
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

// ─────────────────────────────────────
// TAB 2 — DOCUMENTS (unchanged)
// ─────────────────────────────────────
class _DocumentsTab extends GetView<ScanController> {
  final bool isDark;
  const _DocumentsTab({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _UploadZone(isDark: isDark),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent documents',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: controller.fetchDocuments,
                child: Text(
                  'Refresh',
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFF378ADD)
                        : const Color(0xFF185FA5),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Obx(() {
            if (controller.isLoadingDocs.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (controller.documents.isEmpty) {
              return _EmptyDocs(isDark: isDark);
            }

            return Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.documents.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: isDark
                      ? Colors.white.withOpacity(0.05)
                      : const Color(0xFFF1F5F9),
                ),
                itemBuilder: (_, index) =>
                    _DocItem(isDark: isDark, doc: controller.documents[index]),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _UploadZone extends GetView<ScanController> {
  final bool isDark;
  const _UploadZone({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final borderColor = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFBFDBFE);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Obx(() {
        final isUploading = controller.isUploading.value;
        final uploadError = controller.uploadError.value;
        final selectedType = controller.selectedType.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF185FA5).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.upload_file_rounded,
                    color: Color(0xFF185FA5),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upload supporting document',
                        style: TextStyle(
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'PDF, JPG or PNG up to 5 MB.',
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFF64748B)
                              : const Color(0xFF64748B),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: DocumentType.values
                  .map(
                    (type) => _TypeChip(
                      label: _typeLabel(type),
                      isDark: isDark,
                      selected: selectedType == type,
                      onTap: () => controller.selectedType(type),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isUploading ? null : controller.pickAndUpload,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF185FA5),
                  disabledBackgroundColor: const Color(
                    0xFF185FA5,
                  ).withOpacity(0.6),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isUploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Choose File and Upload',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            if (uploadError.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                uploadError,
                style: const TextStyle(
                  color: Color(0xFFDC2626),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        );
      }),
    );
  }

  String _typeLabel(DocumentType type) {
    switch (type) {
      case DocumentType.mc:
        return 'Medical cert';
      case DocumentType.emergencyLeave:
        return 'Emergency leave';
      case DocumentType.annualLeave:
        return 'Annual leave';
      case DocumentType.other:
        return 'Other';
    }
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool isDark;
  final bool selected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.isDark,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF185FA5)
              : isDark
              ? const Color(0xFF1E293B)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? const Color(0xFF185FA5)
                : isDark
                ? const Color(0xFF334155)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? Colors.white
                : isDark
                ? const Color(0xFFCBD5E1)
                : const Color(0xFF334155),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _DocItem extends StatelessWidget {
  final bool isDark;
  final DocumentModel doc;

  const _DocItem({required this.isDark, required this.doc});

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('d MMM yyyy, h:mm a').format(doc.uploadedAt);

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF185FA5).withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.description_outlined,
              color: Color(0xFF185FA5),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${doc.typeLabel} · ${doc.fileSizeFormatted}',
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  dateLabel,
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFF64748B)
                        : const Color(0xFF94A3B8),
                    fontSize: 10.5,
                  ),
                ),
                if ((doc.note ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    doc.note!.trim(),
                    style: TextStyle(
                      color: isDark
                          ? const Color(0xFFCBD5E1)
                          : const Color(0xFF475569),
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          _StatusBadge(status: doc.status),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final DocumentStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, String label) = switch (status) {
      DocumentStatus.approved => (
        const Color(0xFF16A34A).withOpacity(0.12),
        const Color(0xFF15803D),
        'Approved',
      ),
      DocumentStatus.rejected => (
        const Color(0xFFDC2626).withOpacity(0.1),
        const Color(0xFFDC2626),
        'Rejected',
      ),
      DocumentStatus.pending => (
        const Color(0xFFF59E0B).withOpacity(0.12),
        const Color(0xFFD97706),
        'Pending',
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _EmptyDocs extends StatelessWidget {
  final bool isDark;

  const _EmptyDocs({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF185FA5).withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.folder_open_rounded,
              color: Color(0xFF185FA5),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'No documents uploaded yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Submit MCs, leave proofs or other supporting files here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
