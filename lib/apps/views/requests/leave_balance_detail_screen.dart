import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:staff_attendance/apps/controllers/leave_balance_controller/leave_balance_controller.dart';
import 'package:staff_attendance/apps/models/leave_model.dart';
import 'package:staff_attendance/apps/themes/app_colors.dart';
import 'package:staff_attendance/widgets/app_page_widgets.dart';

class LeaveBalanceDetailScreen extends GetView<LeaveBalanceController> {
  const LeaveBalanceDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2.5,
              ),
            );
          }

          if (controller.hasError.value) {
            return _ErrorRetry(isDark: isDark, onRetry: controller.fetchAll);
          }

          return RefreshIndicator(
            onRefresh: controller.fetchAll,
            color: AppColors.primary,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                const AppPageHeader(title: 'Leave Balance Detail'),
                const SizedBox(height: 12),
                _InfoBanner(isDark: isDark),
                const SizedBox(height: 14),
                _BalanceCard(
                  label: 'Annual Leave',
                  icon: Icons.beach_access_rounded,
                  accent: const Color(0xFF185FA5),
                  total: controller.balance.value.annualTotal,
                  used: controller.balance.value.annualUsed,
                  remaining: controller.balance.value.annualLeft,
                  pending: controller.pendingCountFor(LeaveType.annual),
                  isDark: isDark,
                ),
                _BalanceCard(
                  label: 'Medical Leave',
                  icon: Icons.local_hospital_rounded,
                  accent: const Color(0xFFDC2626),
                  total: controller.balance.value.medicalTotal,
                  used: controller.balance.value.medicalUsed,
                  remaining: controller.balance.value.medicalLeft,
                  pending: controller.pendingCountFor(LeaveType.medical),
                  isDark: isDark,
                ),
                _BalanceCard(
                  label: 'Emergency Leave',
                  icon: Icons.warning_amber_rounded,
                  accent: const Color(0xFFF59E0B),
                  total: controller.balance.value.emergencyTotal,
                  used: controller.balance.value.emergencyUsed,
                  remaining: controller.balance.value.emergencyLeft,
                  pending: controller.pendingCountFor(LeaveType.emergency),
                  isDark: isDark,
                ),
                _UnpaidCard(
                  pending: controller.pendingCountFor(LeaveType.unpaid),
                  isDark: isDark,
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Recent leave activity',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                _RecentLeaveList(
                  leaves: controller.recentLeaves,
                  isDark: isDark,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ── Info banner ──────────────────────────────────────────────────────────────

class _InfoBanner extends StatelessWidget {
  final bool isDark;
  const _InfoBanner({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFF185FA5).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.summarize_rounded, color: Color(0xFF185FA5)),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Entitlement, remaining days, pending requests, and recent leave usage in one clear summary.',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Balance card ─────────────────────────────────────────────────────────────

class _BalanceCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color accent;
  final int total;
  final int used;
  final int remaining;
  final int pending;
  final bool isDark;

  const _BalanceCard({
    required this.label,
    required this.icon,
    required this.accent,
    required this.total,
    required this.used,
    required this.remaining,
    required this.pending,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final card = isDark ? const Color(0xFF1E293B) : Colors.white;
    final border = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final text = isDark ? Colors.white : const Color(0xFF0F172A);
    final muted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final trackBg = isDark
        ? Colors.white.withValues(alpha: 0.07)
        : const Color(0xFFEFF6FF);
    final iconBg = isDark
        ? accent.withValues(alpha: 0.18)
        : accent.withValues(alpha: 0.10);
    final fraction = total > 0 ? (used / total).clamp(0.0, 1.0) : 0.0;
    final isExhausted = remaining == 0 && total > 0;
    final accentColor = isExhausted ? const Color(0xFFDC2626) : accent;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accentColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: text,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (pending > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAEEDA),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$pending pending',
                    style: const TextStyle(
                      color: Color(0xFF854F0B),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Stat row
          Row(
            children: [
              _Stat(value: '$used', label: 'Used', color: muted),
              const SizedBox(width: 16),
              _Stat(
                value: '$remaining',
                label: 'Remaining',
                color: accentColor,
                large: true,
              ),
              const SizedBox(width: 16),
              _Stat(value: '$total', label: 'Total', color: muted),
            ],
          ),
          const SizedBox(height: 10),
          // Progress bar
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: fraction,
                    minHeight: 6,
                    backgroundColor: trackBg,
                    valueColor: AlwaysStoppedAnimation(accentColor),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isExhausted
                    ? 'Exhausted'
                    : '${(fraction * 100).round()}% used',
                style: TextStyle(
                  color: accentColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Unpaid leave card (no fixed quota — show pending count only) ─────────────

class _UnpaidCard extends StatelessWidget {
  final int pending;
  final bool isDark;
  const _UnpaidCard({required this.pending, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final card = isDark ? const Color(0xFF1E293B) : Colors.white;
    final border = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final text = isDark ? Colors.white : const Color(0xFF0F172A);
    final muted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final iconBg = isDark
        ? const Color(0xFF7F77DD).withValues(alpha: 0.18)
        : const Color(0xFFEEEDFE);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.money_off_rounded,
                color: Color(0xFF7F77DD), size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Unpaid Leave',
                  style: TextStyle(
                    color: text,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Flexible — approved case by case',
                  style: TextStyle(color: muted, fontSize: 11),
                ),
              ],
            ),
          ),
          if (pending > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFAEEDA),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$pending pending',
                style: const TextStyle(
                  color: Color(0xFF854F0B),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Recent leave list ─────────────────────────────────────────────────────────

class _RecentLeaveList extends StatelessWidget {
  final List<LeaveModel> leaves;
  final bool isDark;
  const _RecentLeaveList({required this.leaves, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (leaves.isEmpty) {
      return AppCard(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'No leave requests this year',
              style: TextStyle(
                color: isDark
                    ? const Color(0xFF64748B)
                    : const Color(0xFF94A3B8),
                fontSize: 13,
              ),
            ),
          ),
        ),
      );
    }

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < leaves.length; i++) ...[
            _LeaveRow(item: leaves[i], isDark: isDark),
            if (i != leaves.length - 1)
              Divider(
                height: 1,
                indent: 14,
                endIndent: 14,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : const Color(0xFFF1F5F9),
              ),
          ],
        ],
      ),
    );
  }
}

class _LeaveRow extends StatelessWidget {
  final LeaveModel item;
  final bool isDark;
  const _LeaveRow({required this.item, required this.isDark});

  static final _dateFmt = DateFormat('d MMM yyyy');

  @override
  Widget build(BuildContext context) {
    final text = isDark ? Colors.white : const Color(0xFF0F172A);
    final muted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final accent = Color(item.typeColor);
    final statusColor = Color(item.statusColor);

    final dateRange = item.startDate == item.endDate
        ? _dateFmt.format(item.startDate)
        : '${_dateFmt.format(item.startDate)} – ${_dateFmt.format(item.endDate)}';

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.typeLabel.tr,
                  style: TextStyle(
                    color: text,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dateRange,
                  style: TextStyle(color: muted, fontSize: 11),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppStatusBadge(label: item.statusLabel.tr, color: statusColor),
              const SizedBox(height: 4),
              Text(
                '${item.totalDays} day${item.totalDays != 1 ? 's' : ''}',
                style: TextStyle(
                  color: muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Stat widget ───────────────────────────────────────────────────────────────

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final bool large;
  const _Stat({
    required this.value,
    required this.label,
    required this.color,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: large ? 22 : 18,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: color.withValues(alpha: 0.6),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ── Error state ───────────────────────────────────────────────────────────────

class _ErrorRetry extends StatelessWidget {
  final bool isDark;
  final VoidCallback onRetry;
  const _ErrorRetry({required this.isDark, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off_rounded,
            size: 48,
            color: isDark
                ? const Color(0xFF334155)
                : const Color(0xFFCBD5E1),
          ),
          const SizedBox(height: 12),
          Text(
            'Could not load leave balance',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1E293B),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Check your connection and try again.',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Retry'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}
