import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/work_hours_summary_controller/work_hours_summary_controller.dart';
import 'package:staff_attendance/apps/themes/app_colors.dart';
import 'package:staff_attendance/widgets/app_page_widgets.dart';

class WorkHoursSummaryScreen extends GetView<WorkHoursSummaryController> {
  const WorkHoursSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0B1324) : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  const AppBackButton(),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'work_hours_summary'.tr,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  // Period toggle chips
                  Obx(() => _PeriodChips(
                    selected: controller.period.value,
                    isDark: isDark,
                    onSelect: controller.setPeriod,
                  )),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── Period navigator ─────────────────────────────────────────────
            Obx(() => _PeriodNavigator(
              label: controller.periodLabel,
              canGoNext: controller.canGoNext,
              isDark: isDark,
              onPrev: controller.goPrevious,
              onNext: controller.goNext,
            )),
            const SizedBox(height: 14),

            // ── Content ──────────────────────────────────────────────────────
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

                if (controller.hasError.value && controller.summary.isEmpty) {
                  return _ErrorRetry(
                    isDark: isDark,
                    onRetry: controller.fetchSummary,
                  );
                }

                final summary = controller.summary;
                final daily = controller.daily;
                final totalHours = WorkHoursSummaryController.parseHours(
                    summary['total_hours']);
                final otHours = WorkHoursSummaryController.parseHours(
                    summary['overtime_hours']);
                final lateMin = (summary['late_minutes'] ?? 0) as num;
                final score =
                    (summary['attendance_score'] ?? 0) as num;

                return RefreshIndicator(
                  onRefresh: controller.fetchSummary,
                  color: AppColors.primary,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    children: [
                      // ── Metric cards ───────────────────────────────────────
                      Row(
                        children: [
                          _MetricCard(
                            icon: Icons.schedule_rounded,
                            iconBg: isDark
                                ? const Color(0xFF1A3556)
                                : const Color(0xFFE6F1FB),
                            iconColor: AppColors.primary,
                            label: 'Total hours',
                            value: '${summary['total_hours'] ?? '—'}',
                            sub: _hoursBar(totalHours, 40, isDark,
                                AppColors.primary),
                            isDark: isDark,
                          ),
                          const SizedBox(width: 10),
                          _MetricCard(
                            icon: Icons.emoji_events_rounded,
                            iconBg: isDark
                                ? const Color(0xFF0A2A18)
                                : const Color(0xFFDCFCE7),
                            iconColor: _scoreColor(score.toInt()),
                            label: 'Score',
                            value: '$score%',
                            sub: _scoreRing(score.toDouble(), isDark),
                            isDark: isDark,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _MetricCard(
                            icon: Icons.bolt_rounded,
                            iconBg: isDark
                                ? const Color(0xFF2A1F0A)
                                : const Color(0xFFFEF9C3),
                            iconColor: const Color(0xFFF59E0B),
                            label: 'Overtime',
                            value: '${summary['overtime_hours'] ?? '0h'}',
                            sub: _hoursBar(
                                otHours, 4, isDark, const Color(0xFFF59E0B)),
                            isDark: isDark,
                          ),
                          const SizedBox(width: 10),
                          _MetricCard(
                            icon: Icons.timer_off_rounded,
                            iconBg: isDark
                                ? const Color(0xFF2A1010)
                                : const Color(0xFFFFEDED),
                            iconColor: const Color(0xFFDC2626),
                            label: 'Late',
                            value: '${lateMin}m',
                            sub: null,
                            isDark: isDark,
                          ),
                        ],
                      ),

                      if (daily.isNotEmpty) ...[
                        const SizedBox(height: 20),

                        // ── Bar chart ────────────────────────────────────────
                        _DailyBarChart(daily: daily, isDark: isDark),

                        const SizedBox(height: 20),

                        // ── Daily breakdown ──────────────────────────────────
                        _SectionLabel(
                            label: 'Daily breakdown', isDark: isDark),
                        const SizedBox(height: 10),
                        ...daily.map(
                          (item) => _DailyRow(item: item, isDark: isDark),
                        ),
                      ] else ...[
                        const SizedBox(height: 40),
                        _EmptyState(isDark: isDark),
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

  // Thin linear bar used inside metric cards.
  Widget _hoursBar(double hours, double max, bool isDark, Color color) {
    final fraction = (hours / math.max(max, 1)).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 4,
            backgroundColor: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFE2E8F0),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'of ${max.toStringAsFixed(0)}h target',
          style: TextStyle(
            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  // Mini donut ring for the score card.
  Widget _scoreRing(double score, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: SizedBox(
        width: 44,
        height: 44,
        child: CustomPaint(
          painter: _RingPainter(
            progress: score / 100,
            color: _scoreColor(score.toInt()),
            trackColor: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFE2E8F0),
          ),
          child: Center(
            child: Text(
              '${score.toInt()}',
              style: TextStyle(
                color: _scoreColor(score.toInt()),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Color _scoreColor(int score) {
    if (score >= 90) return const Color(0xFF16A34A);
    if (score >= 70) return const Color(0xFFF59E0B);
    return const Color(0xFFDC2626);
  }
}

// ── Period chips ───────────────────────────────────────────────────────────────

class _PeriodChips extends StatelessWidget {
  final String selected;
  final bool isDark;
  final ValueChanged<String> onSelect;
  const _PeriodChips({
    required this.selected,
    required this.isDark,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF182338) : const Color(0xFFE6F1FB),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ['Weekly', 'Monthly'].map((p) {
          final isSelected = p == selected;
          return GestureDetector(
            onTap: () => onSelect(p),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                p,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : (isDark
                          ? const Color(0xFF8FA3BF)
                          : const Color(0xFF64748B)),
                  fontSize: 12,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Period navigator ───────────────────────────────────────────────────────────

class _PeriodNavigator extends StatelessWidget {
  final String label;
  final bool canGoNext;
  final bool isDark;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  const _PeriodNavigator({
    required this.label,
    required this.canGoNext,
    required this.isDark,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final text = isDark ? Colors.white : const Color(0xFF1E293B);
    final subtle =
        isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final iconActive =
        isDark ? const Color(0xFF8FA3BF) : const Color(0xFF64748B);
    final iconDisabled =
        isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF182338) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: subtle),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: onPrev,
              icon: Icon(Icons.chevron_left_rounded,
                  color: iconActive, size: 22),
              splashRadius: 18,
              padding: EdgeInsets.zero,
              constraints:
                  const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: text,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              onPressed: canGoNext ? onNext : null,
              icon: Icon(
                Icons.chevron_right_rounded,
                color: canGoNext ? iconActive : iconDisabled,
                size: 22,
              ),
              splashRadius: 18,
              padding: EdgeInsets.zero,
              constraints:
                  const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Metric card ────────────────────────────────────────────────────────────────

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String value;
  final Widget? sub;
  final bool isDark;
  const _MetricCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.sub,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final card = isDark ? const Color(0xFF182338) : Colors.white;
    final border =
        isDark ? const Color(0xFF23314F) : const Color(0xFFE2E8F0);
    final text = isDark ? Colors.white : const Color(0xFF1E293B);
    final muted =
        isDark ? const Color(0xFF8FA3BF) : const Color(0xFF64748B);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(icon, size: 16, color: iconColor),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                color: text,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
            if (sub != null) sub!,
          ],
        ),
      ),
    );
  }
}

// ── Bar chart ──────────────────────────────────────────────────────────────────

class _DailyBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> daily;
  final bool isDark;
  const _DailyBarChart({required this.daily, required this.isDark});

  @override
  Widget build(BuildContext context) {
    const maxBarH = 72.0;
    const targetH = 8.0; // standard workday in hours

    final hours = daily
        .map((d) => WorkHoursSummaryController.parseHours(d['hours']))
        .toList();
    final maxH = hours.isEmpty ? targetH : math.max(hours.reduce(math.max), targetH);

    final card = isDark ? const Color(0xFF182338) : Colors.white;
    final border = isDark ? const Color(0xFF23314F) : const Color(0xFFE2E8F0);
    final muted =
        isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
    final trackColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : const Color(0xFFE2E8F0);
    final targetColor = isDark
        ? Colors.white.withValues(alpha: 0.15)
        : const Color(0xFFCBD5E1);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HOURS PER DAY',
            style: TextStyle(
              color: muted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: maxBarH + 22, // bars + day label
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(daily.length, (i) {
                final item = daily[i];
                final h = hours[i];
                final barFraction =
                    (h / math.max(maxH, 1)).clamp(0.0, 1.0);
                final targetFraction =
                    (targetH / math.max(maxH, 1)).clamp(0.0, 1.0);
                final barH = (barFraction * maxBarH);
                final targetLineY = maxBarH * (1 - targetFraction);
                final score = (item['score'] as num?)?.toInt() ?? 0;
                final barColor = score >= 90
                    ? const Color(0xFF16A34A)
                    : score >= 70
                        ? const Color(0xFFF59E0B)
                        : h == 0
                            ? trackColor
                            : const Color(0xFFDC2626);
                // Day abbreviation – first 3 chars of whatever 'day' is
                final dayStr = '${item['day'] ?? ''}';
                final dayLabel = dayStr.length >= 3
                    ? dayStr.substring(0, 3)
                    : dayStr;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              // Track
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: trackColor,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                              // Target line
                              Positioned(
                                top: targetLineY,
                                left: 0,
                                right: 0,
                                child: Container(
                                  height: 1,
                                  color: targetColor,
                                ),
                              ),
                              // Filled bar
                              if (h > 0)
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  height: barH,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: barColor,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          dayLabel,
                          style: TextStyle(
                            color: muted,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 16,
                height: 1.5,
                color: targetColor,
              ),
              const SizedBox(width: 6),
              Text(
                '${targetH.toInt()}h target',
                style: TextStyle(color: muted, fontSize: 10),
              ),
              const SizedBox(width: 14),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 4),
              Text('≥90%', style: TextStyle(color: muted, fontSize: 10)),
              const SizedBox(width: 10),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 4),
              Text('70–89%', style: TextStyle(color: muted, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Daily row ──────────────────────────────────────────────────────────────────

class _DailyRow extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isDark;
  const _DailyRow({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final score = (item['score'] as num?)?.toInt() ?? 0;
    final hours = WorkHoursSummaryController.parseHours(item['hours']);
    final ot = WorkHoursSummaryController.parseHours(item['overtime']);
    final lateMin = (item['late_minutes'] as num?)?.toInt() ?? 0;
    final checkIn = item['check_in'] as String?;
    final checkOut = item['check_out'] as String?;
    final absent = hours == 0 && checkIn == null;

    final card = isDark ? const Color(0xFF182338) : Colors.white;
    final border = isDark ? const Color(0xFF23314F) : const Color(0xFFE2E8F0);
    final text = isDark ? Colors.white : const Color(0xFF1E293B);
    final muted =
        isDark ? const Color(0xFF8FA3BF) : const Color(0xFF64748B);
    final trackColor = isDark
        ? Colors.white.withValues(alpha: 0.07)
        : const Color(0xFFE2E8F0);

    final scoreColor = score >= 90
        ? const Color(0xFF16A34A)
        : score >= 70
            ? const Color(0xFFF59E0B)
            : const Color(0xFFDC2626);
    final scoreBg = score >= 90
        ? (isDark ? const Color(0xFF0A2A18) : const Color(0xFFDCFCE7))
        : score >= 70
            ? (isDark ? const Color(0xFF2A1F0A) : const Color(0xFFFEF9C3))
            : (isDark ? const Color(0xFF2A1010) : const Color(0xFFFFEDED));

    final hourFraction = (hours / 8).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: absent
              ? (isDark
                  ? const Color(0xFF2A1010)
                  : const Color(0xFFFFEDED))
              : border,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Day & date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item['day'] ?? ''}',
                      style: TextStyle(
                        color: absent
                            ? const Color(0xFFDC2626)
                            : text,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    if (item['date'] != null) ...[
                      const SizedBox(height: 1),
                      Text(
                        '${item['date']}',
                        style:
                            TextStyle(color: muted, fontSize: 11),
                      ),
                    ],
                  ],
                ),
              ),

              // Check-in → check-out
              if (checkIn != null) ...[
                Icon(Icons.login_rounded,
                    size: 12, color: const Color(0xFF16A34A)),
                const SizedBox(width: 3),
                Text(
                  checkIn,
                  style: TextStyle(
                    color: muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (checkOut != null) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text('→',
                        style: TextStyle(color: muted, fontSize: 10)),
                  ),
                  Text(
                    checkOut,
                    style: TextStyle(
                      color: muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(width: 10),
              ],

              // Score badge
              if (!absent)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: scoreBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$score%',
                    style: TextStyle(
                      color: scoreColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF2A1010)
                        : const Color(0xFFFFEDED),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Absent',
                    style: TextStyle(
                      color: Color(0xFFDC2626),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),

          if (!absent) ...[
            const SizedBox(height: 10),
            // Hours bar
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: hourFraction,
                      minHeight: 5,
                      backgroundColor: trackColor,
                      valueColor: AlwaysStoppedAnimation(scoreColor),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${item['hours'] ?? '0h'}',
                  style: TextStyle(
                    color: text,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            // OT / late chips
            if (ot > 0 || lateMin > 0) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  if (ot > 0)
                    _Chip(
                      label:
                          'OT ${item['overtime'] ?? ''}',
                      color: const Color(0xFFF59E0B),
                      bg: isDark
                          ? const Color(0xFF2A1F0A)
                          : const Color(0xFFFEF9C3),
                    ),
                  if (ot > 0 && lateMin > 0)
                    const SizedBox(width: 6),
                  if (lateMin > 0)
                    _Chip(
                      label: 'Late ${lateMin}m',
                      color: const Color(0xFFDC2626),
                      bg: isDark
                          ? const Color(0xFF2A1010)
                          : const Color(0xFFFFEDED),
                    ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;
  const _Chip({required this.label, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
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

// ── Error / retry state ────────────────────────────────────────────────────────

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
          Text(
            'Could not load data',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1E293B),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Check your connection and try again.',
            style: TextStyle(color: muted, fontSize: 13),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Retry'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
        children: [
          Icon(
            Icons.bar_chart_rounded,
            size: 48,
            color: isDark
                ? const Color(0xFF334155)
                : const Color(0xFFCBD5E1),
          ),
          const SizedBox(height: 12),
          Text(
            'No data for this period',
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

// ── Score ring painter ─────────────────────────────────────────────────────────

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;
  const _RingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = (size.shortestSide / 2) - 3;
    const stroke = 4.0;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    paint.color = trackColor;
    canvas.drawCircle(Offset(cx, cy), r, paint);

    paint.color = color;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}
