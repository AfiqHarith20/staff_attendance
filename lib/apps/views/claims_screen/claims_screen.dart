import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:staff_attendance/apps/controllers/claims_controller/claims_controller.dart';
import 'package:staff_attendance/apps/models/claim_model.dart';
import 'package:staff_attendance/apps/routes/routes.dart';

class ClaimsScreen extends GetView<ClaimsController> {
  const ClaimsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(isDark),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.requests.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF16A34A)),
                  );
                }
                if (controller.errorMsg.value != null && controller.requests.isEmpty) {
                  return _ErrorState(isDark: isDark, msg: controller.errorMsg.value!);
                }
                return RefreshIndicator(
                  onRefresh: controller.fetchAll,
                  color: const Color(0xFF16A34A),
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            _SummaryRow(isDark: isDark),
                            const SizedBox(height: 8),
                            _StatusFilters(isDark: isDark),
                            _CategoryFilters(isDark: isDark),
                            const SizedBox(height: 4),
                          ],
                        ),
                      ),
                      Obx(() {
                        final list = controller.filtered;
                        if (list.isEmpty) {
                          return SliverFillRemaining(
                            child: _EmptyState(isDark: isDark),
                          );
                        }
                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (ctx, i) => _ClaimCard(
                              claim: list[i],
                              isDark: isDark,
                            ),
                            childCount: list.length,
                          ),
                        );
                      }),
                      const SliverToBoxAdapter(child: SizedBox(height: 80)),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(Routes.submitClaim),
        backgroundColor: const Color(0xFF16A34A),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'apply_claim'.tr,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildAppBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: Get.back,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          Expanded(
            child: Text(
              'claims'.tr,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Summary row ───────────────────────────────────────────────────────────────
class _SummaryRow extends GetView<ClaimsController> {
  final bool isDark;
  const _SummaryRow({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          _SummaryCard(
            isDark: isDark,
            label: 'total',
            value: '${controller.requests.length}',
            color: const Color(0xFF64748B),
            flex: 2,
          ),
          const SizedBox(width: 8),
          _SummaryCard(
            isDark: isDark,
            label: 'pending',
            value: 'RM ${controller.totalPendingAmount.toStringAsFixed(0)}',
            color: const Color(0xFFF59E0B),
            flex: 3,
          ),
          const SizedBox(width: 8),
          _SummaryCard(
            isDark: isDark,
            label: 'approved',
            value: 'RM ${controller.totalApprovedAmount.toStringAsFixed(0)}',
            color: const Color(0xFF16A34A),
            flex: 3,
          ),
        ],
      ),
    ));
  }
}

class _SummaryCard extends StatelessWidget {
  final bool isDark;
  final String label;
  final String value;
  final Color color;
  final int flex;

  const _SummaryCard({
    required this.isDark,
    required this.label,
    required this.value,
    required this.color,
    required this.flex,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.tr.toUpperCase(),
              style: TextStyle(
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Status filters ────────────────────────────────────────────────────────────
class _StatusFilters extends GetView<ClaimsController> {
  final bool isDark;
  const _StatusFilters({required this.isDark});

  static const _statuses = ['all', 'pending', 'approved', 'rejected'];

  @override
  Widget build(BuildContext context) {
    return Obx(() => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(
        children: _statuses.map((s) {
          final active = controller.selectedStatus.value == s;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => controller.selectedStatus(s),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: active
                      ? const Color(0xFF16A34A)
                      : isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: active
                        ? const Color(0xFF16A34A)
                        : isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Text(
                  s == 'all' ? 'all'.tr : s.tr,
                  style: TextStyle(
                    color: active
                        ? Colors.white
                        : isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ));
  }
}

// ── Category filters ──────────────────────────────────────────────────────────
class _CategoryFilters extends GetView<ClaimsController> {
  final bool isDark;
  const _CategoryFilters({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Obx(() => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      child: Row(
        children: [
          _catChip('all', 'all'.tr),
          _catChip('general', 'claim_category_general'.tr),
          _catChip('travel', 'claim_category_travel'.tr),
        ],
      ),
    ));
  }

  Widget _catChip(String key, String label) {
    final active = controller.selectedCategory.value == key;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => controller.selectedCategory(key),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: active
                ? const Color(0xFF185FA5).withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: active
                  ? const Color(0xFF185FA5)
                  : isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: active
                  ? const Color(0xFF185FA5)
                  : isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Claim card ────────────────────────────────────────────────────────────────
class _ClaimCard extends StatelessWidget {
  final ClaimModel claim;
  final bool isDark;
  const _ClaimCard({required this.claim, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final typeColor = Color(claim.typeColor);
    final statusColor = Color(claim.statusColor);

    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        padding: const EdgeInsets.all(14),
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
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                claim.isMileage
                    ? Icons.directions_car_rounded
                    : claim.category == ClaimCategory.travel
                    ? Icons.flight_rounded
                    : Icons.receipt_long_rounded,
                color: typeColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          claim.typeKey.tr,
                          style: TextStyle(
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        claim.amountFormatted,
                        style: TextStyle(
                          color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        DateFormat('d MMM yyyy').format(claim.claimDate),
                        style: TextStyle(
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          fontSize: 11,
                        ),
                      ),
                      if (claim.isMileage && claim.distanceKm != null) ...[
                        Text(
                          ' · ${claim.distanceKm!.toStringAsFixed(1)} km',
                          style: TextStyle(
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            fontSize: 11,
                          ),
                        ),
                      ],
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          claim.statusKey.tr,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (claim.description != null && claim.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      claim.description!,
                      style: TextStyle(
                        color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final typeColor = Color(claim.typeColor);
    final statusColor = Color(claim.statusColor);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.65,
        maxChildSize: 0.9,
        builder: (_, scroll) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: ListView(
                controller: scroll,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          claim.isMileage ? Icons.directions_car_rounded : Icons.receipt_long_rounded,
                          color: typeColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              claim.typeKey.tr,
                              style: TextStyle(
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              claim.amountFormatted,
                              style: TextStyle(
                                color: typeColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          claim.statusKey.tr,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _detailRow(isDark, 'date'.tr, DateFormat('d MMMM yyyy').format(claim.claimDate)),
                  _detailRow(isDark, 'submitted'.tr, DateFormat('d MMM yyyy · h:mm a').format(claim.submittedAt)),
                  if (claim.isMileage && claim.distanceKm != null)
                    _detailRow(isDark, 'distance_km'.tr, '${claim.distanceKm!.toStringAsFixed(1)} km'),
                  if (claim.vehicleType != null)
                    _detailRow(isDark, 'vehicle_type'.tr,
                        claim.vehicleType == 'car' ? 'vehicle_car'.tr : 'vehicle_motorbike'.tr),
                  if (claim.travelFrom != null)
                    _detailRow(isDark, 'travel_from'.tr, claim.travelFrom!),
                  if (claim.travelTo != null)
                    _detailRow(isDark, 'travel_to'.tr, claim.travelTo!),
                  if (claim.travelPurpose != null)
                    _detailRow(isDark, 'travel_purpose'.tr, claim.travelPurpose!),
                  if (claim.description != null && claim.description!.isNotEmpty)
                    _detailRow(isDark, 'reason'.tr, claim.description!),
                  if (claim.receiptFileName != null)
                    _detailRow(isDark, 'documents'.tr, claim.receiptFileName!),
                  if (claim.approvedBy != null)
                    _detailRow(isDark, 'approved_by'.tr, claim.approvedBy!),
                  if (claim.rejectionNote != null)
                    _detailRow(isDark, 'rejection_note'.tr, claim.rejectionNote!,
                        valueColor: const Color(0xFFDC2626)),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'close'.tr,
                        style: TextStyle(
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(bool isDark, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ??
                    (isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B)),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEAF3DE),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: Color(0xFF16A34A),
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'no_claims'.tr,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'no_claims_hint'.tr,
            style: TextStyle(
              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final bool isDark;
  final String msg;
  const _ErrorState({required this.isDark, required this.msg});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          msg,
          style: TextStyle(
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
