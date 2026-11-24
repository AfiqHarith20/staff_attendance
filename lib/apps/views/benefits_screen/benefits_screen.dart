import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/benefits_controller/benefits_controller.dart';
import 'package:staff_attendance/apps/models/benefit_model.dart';
import 'package:staff_attendance/apps/themes/app_colors.dart';
import 'package:staff_attendance/widgets/app_page_widgets.dart';

class BenefitsScreen extends GetView<BenefitsController> {
  const BenefitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0B1324) : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  const AppBackButton(),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Benefits',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1E293B),
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Entitlements & leave balances',
                          style: TextStyle(
                            color: isDark
                                ? const Color(0xFF8FA3BF)
                                : const Color(0xFF94A3B8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2.5,
                    ),
                  );
                }

                if (controller.hasError.value &&
                    controller.benefits.isEmpty) {
                  return _ErrorRetry(
                    isDark: isDark,
                    onRetry: controller.fetchBenefits,
                  );
                }

                final allItems = controller.benefits;
                if (allItems.isEmpty) {
                  return _EmptyState(isDark: isDark);
                }

                // Aggregate totals across all leave types for summary card.
                final leaveItems = allItems
                    .where((b) => b.category == 'Leave')
                    .toList();
                final totalDays = leaveItems.fold(
                    0, (s, b) => s + b.totalDays);
                final usedDays = leaveItems.fold(
                    0, (s, b) => s + b.usedDays);
                final remainingDays = leaveItems.fold(
                    0, (s, b) => s + b.remainingDays);

                // Group items by category for section headers.
                final grouped = <String, List<BenefitModel>>{};
                for (final b in allItems) {
                  grouped.putIfAbsent(b.category, () => []).add(b);
                }

                return RefreshIndicator(
                  onRefresh: controller.fetchBenefits,
                  color: AppColors.primary,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    children: [
                      // ── Summary banner ─────────────────────────────────
                      if (leaveItems.isNotEmpty)
                        _SummaryCard(
                          totalDays: totalDays,
                          usedDays: usedDays,
                          remainingDays: remainingDays,
                          isDark: isDark,
                        ),

                      // ── Grouped sections ───────────────────────────────
                      for (final entry in grouped.entries) ...[
                        const SizedBox(height: 20),
                        _SectionLabel(
                            label: '${entry.key} entitlements',
                            isDark: isDark),
                        const SizedBox(height: 10),
                        ...entry.value.map(
                          (item) =>
                              _BenefitCard(item: item, isDark: isDark),
                        ),
                      ],
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Summary banner ─────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final int totalDays;
  final int usedDays;
  final int remainingDays;
  final bool isDark;
  const _SummaryCard({
    required this.totalDays,
    required this.usedDays,
    required this.remainingDays,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final usedFraction =
        totalDays > 0 ? (usedDays / totalDays).clamp(0.0, 1.0) : 0.0;
    final pct =
        totalDays > 0 ? (usedFraction * 100).round() : 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1A3556), const Color(0xFF0F2340)]
              : [const Color(0xFF185FA5), const Color(0xFF1A7AC7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.event_available_rounded,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                'Annual leave overview',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '$pct% used',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _SumStat(
                  label: 'Used', value: '$usedDays', isDark: isDark),
              _SumDivider(),
              _SumStat(
                  label: 'Remaining',
                  value: '$remainingDays',
                  isDark: isDark,
                  highlight: true),
              _SumDivider(),
              _SumStat(
                  label: 'Total', value: '$totalDays', isDark: isDark),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: usedFraction,
              minHeight: 7,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor:
                  const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$usedDays of $totalDays days used this period',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _SumStat extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  final bool highlight;
  const _SumStat({
    required this.label,
    required this.value,
    required this.isDark,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: highlight
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.75),
              fontSize: highlight ? 26 : 22,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _SumDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: Colors.white.withValues(alpha: 0.2),
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

// ── Section label ──────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isDark;
  const _SectionLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    );
  }
}

// ── Benefit card ───────────────────────────────────────────────────────────────

class _BenefitCard extends StatelessWidget {
  final BenefitModel item;
  final bool isDark;
  const _BenefitCard({required this.item, required this.isDark});

  static ({IconData icon, Color accent, Color iconBg}) _leaveStyle(
      String type) {
    switch (type.toLowerCase()) {
      case 'annual':
        return (
          icon: Icons.beach_access_rounded,
          accent: const Color(0xFF185FA5),
          iconBg: const Color(0xFFE6F1FB),
        );
      case 'medical':
        return (
          icon: Icons.local_hospital_rounded,
          accent: const Color(0xFFDC2626),
          iconBg: const Color(0xFFFFEDED),
        );
      case 'emergency':
        return (
          icon: Icons.warning_amber_rounded,
          accent: const Color(0xFFF59E0B),
          iconBg: const Color(0xFFFEF9C3),
        );
      case 'hospitalisation':
        return (
          icon: Icons.medication_rounded,
          accent: const Color(0xFF0284C7),
          iconBg: const Color(0xFFE0F2FE),
        );
      case 'maternity':
        return (
          icon: Icons.pregnant_woman_rounded,
          accent: const Color(0xFFDB2777),
          iconBg: const Color(0xFFFCE7F3),
        );
      case 'paternity':
        return (
          icon: Icons.child_friendly_rounded,
          accent: const Color(0xFF16A34A),
          iconBg: const Color(0xFFEAF3DE),
        );
      default:
        return (
          icon: Icons.card_giftcard_rounded,
          accent: const Color(0xFF185FA5),
          iconBg: const Color(0xFFE6F1FB),
        );
    }
  }

  static Color _darken(Color c, bool isDark) {
    if (!isDark) return c;
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness * 0.55).clamp(0.0, 1.0)).toColor();
  }

  @override
  Widget build(BuildContext context) {
    return item.isInsurance
        ? _InsuranceCard(item: item, isDark: isDark)
        : _LeaveCard(item: item, isDark: isDark, darken: _darken, style: _leaveStyle(item.type));
  }
}

class _LeaveCard extends StatelessWidget {
  final BenefitModel item;
  final bool isDark;
  final Color Function(Color, bool) darken;
  final ({IconData icon, Color accent, Color iconBg}) style;
  const _LeaveCard({
    required this.item,
    required this.isDark,
    required this.darken,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    final card = isDark ? const Color(0xFF182338) : Colors.white;
    final border = isDark ? const Color(0xFF23314F) : const Color(0xFFE2E8F0);
    final text = isDark ? Colors.white : const Color(0xFF1E293B);
    final muted = isDark ? const Color(0xFF8FA3BF) : const Color(0xFF64748B);
    final trackColor =
        isDark ? Colors.white.withValues(alpha: 0.07) : const Color(0xFFEFF6FF);

    final s = style;
    final accentDark = darken(s.accent, isDark);
    final iconBg = isDark ? accentDark.withValues(alpha: 0.22) : s.iconBg;

    final total = item.totalDays;
    final used = item.usedDays;
    final remaining = item.remainingDays;
    final fraction = total > 0 ? (used / total).clamp(0.0, 1.0) : 0.0;
    final isExhausted = remaining == 0 && total > 0;
    final accentColor = isExhausted ? const Color(0xFFDC2626) : s.accent;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      clipBehavior: Clip.hardEdge,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: accentColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: iconBg,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Icon(s.icon, color: accentColor, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.displayName,
                                style: TextStyle(
                                  color: text,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                item.category,
                                style: TextStyle(color: muted, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isExhausted
                                ? (isDark
                                    ? const Color(0xFF2A1010)
                                    : const Color(0xFFFFEDED))
                                : iconBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isExhausted ? 'Exhausted' : '$remaining days left',
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.04)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: border),
                      ),
                      child: Row(
                        children: [
                          _StatBox(
                              value: '$used',
                              label: 'Used',
                              color: muted,
                              isDark: isDark),
                          _StatDivider(isDark: isDark),
                          _StatBox(
                              value: '$remaining',
                              label: 'Remaining',
                              color: accentColor,
                              isDark: isDark,
                              bold: true),
                          _StatDivider(isDark: isDark),
                          _StatBox(
                              value: '$total',
                              label: 'Total',
                              color: muted,
                              isDark: isDark),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: LinearProgressIndicator(
                              value: fraction,
                              minHeight: 7,
                              backgroundColor: trackColor,
                              valueColor: AlwaysStoppedAnimation(accentColor),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 32,
                          child: Text(
                            '${(fraction * 100).round()}%',
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Insurance card (different shape — coverage amount, not day counts) ──────────

class _InsuranceCard extends StatelessWidget {
  final BenefitModel item;
  final bool isDark;
  const _InsuranceCard({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final card = isDark ? const Color(0xFF182338) : Colors.white;
    final border = isDark ? const Color(0xFF23314F) : const Color(0xFFE2E8F0);
    final text = isDark ? Colors.white : const Color(0xFF1E293B);
    final muted = isDark ? const Color(0xFF8FA3BF) : const Color(0xFF64748B);

    const accent = Color(0xFF7F77DD);
    final iconBg = isDark
        ? accent.withValues(alpha: 0.18)
        : const Color(0xFFEEEDFE);

    final lapsed = item.hasLapsed == true;
    final accentColor = lapsed ? const Color(0xFFDC2626) : accent;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      clipBehavior: Clip.hardEdge,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: accentColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: iconBg,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Icon(Icons.shield_rounded,
                              color: accentColor, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.displayName,
                                style: TextStyle(
                                  color: text,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (item.provider != null)
                                Text(
                                  item.provider!,
                                  style:
                                      TextStyle(color: muted, fontSize: 11),
                                ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: lapsed
                                ? (isDark
                                    ? const Color(0xFF2A1010)
                                    : const Color(0xFFFFEDED))
                                : iconBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            lapsed ? 'Lapsed' : 'Active',
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Info rows
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.04)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: border),
                      ),
                      child: Column(
                        children: [
                          if (item.coverageLabel != null)
                            _InfoRow(
                              label: 'Coverage',
                              value: item.coverageLabel!,
                              valueColor: accentColor,
                              bold: true,
                              isDark: isDark,
                            ),
                          if (item.policyNo != null) ...[
                            const SizedBox(height: 8),
                            _InfoRow(
                              label: 'Policy No.',
                              value: item.policyNo!,
                              isDark: isDark,
                            ),
                          ],
                          if (item.premiumPaidBy != null) ...[
                            const SizedBox(height: 8),
                            _InfoRow(
                              label: 'Premium by',
                              value: item.premiumPaidBy!,
                              isDark: isDark,
                            ),
                          ],
                          if (item.startsOn != null &&
                              item.endsOn != null) ...[
                            const SizedBox(height: 8),
                            _InfoRow(
                              label: 'Period',
                              value: '${item.startsOn} → ${item.endsOn}',
                              isDark: isDark,
                            ),
                          ],
                          if (item.dependentsCovered != null &&
                              item.dependentsCovered! > 0) ...[
                            const SizedBox(height: 8),
                            _InfoRow(
                              label: 'Dependents',
                              value: '${item.dependentsCovered} covered',
                              isDark: isDark,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  final Color? valueColor;
  final bool bold;
  const _InfoRow({
    required this.label,
    required this.value,
    required this.isDark,
    this.valueColor,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final muted = isDark ? const Color(0xFF8FA3BF) : const Color(0xFF64748B);
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(color: muted, fontSize: 12)),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? textColor,
            fontSize: 12,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ── Stat box inside benefit card ───────────────────────────────────────────────

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final bool isDark;
  final bool bold;
  const _StatBox({
    required this.value,
    required this.label,
    required this.color,
    required this.isDark,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: bold ? 20 : 18,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: isDark
                  ? const Color(0xFF64748B)
                  : const Color(0xFF94A3B8),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  final bool isDark;
  const _StatDivider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      color: isDark
          ? Colors.white.withValues(alpha: 0.08)
          : const Color(0xFFE2E8F0),
    );
  }
}

// ── Error state ────────────────────────────────────────────────────────────────

class _ErrorRetry extends StatelessWidget {
  final bool isDark;
  final VoidCallback onRetry;
  const _ErrorRetry({required this.isDark, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final muted =
        isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_rounded,
              size: 48,
              color: isDark
                  ? const Color(0xFF334155)
                  : const Color(0xFFCBD5E1)),
          const SizedBox(height: 12),
          Text('Could not load benefits',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              )),
          const SizedBox(height: 4),
          Text('Check your connection and try again.',
              style: TextStyle(color: muted, fontSize: 13)),
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

// ── Empty state ────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.card_giftcard_rounded,
              size: 48,
              color: isDark
                  ? const Color(0xFF334155)
                  : const Color(0xFFCBD5E1)),
          const SizedBox(height: 12),
          Text(
            'No benefits on record',
            style: TextStyle(
              color: isDark
                  ? const Color(0xFF64748B)
                  : const Color(0xFF94A3B8),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
