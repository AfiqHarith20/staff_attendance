import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/performance_controller/performance_controller.dart';
import 'package:staff_attendance/apps/models/performance_review_model.dart';
import 'package:staff_attendance/apps/themes/app_colors.dart';
import 'package:staff_attendance/widgets/app_page_widgets.dart';

const _statusColors = <String, Color>{
  'draft': Color(0xFF6B7280),
  'self_assessment': Color(0xFF2563EB),
  'manager_review': Color(0xFFF59E0B),
  'acknowledged': Color(0xFF7C3AED),
  'closed': Color(0xFF16A34A),
};

const _goalStatusColors = <String, Color>{
  'in_progress': Color(0xFF2563EB),
  'achieved': Color(0xFF16A34A),
  'partially_achieved': Color(0xFFF59E0B),
  'not_achieved': Color(0xFFDC2626),
  'cancelled': Color(0xFF6B7280),
};

class PerformanceScreen extends GetView<PerformanceController> {
  const PerformanceScreen({super.key});

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
              child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5),
            );
          }
          if (controller.hasError.value) {
            return _ErrorRetry(isDark: isDark, onRetry: controller.fetchReviews);
          }
          return RefreshIndicator(
            onRefresh: controller.fetchReviews,
            color: AppColors.primary,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                const AppPageHeader(title: 'Performance'),
                const SizedBox(height: 12),
                if (controller.reviews.isEmpty)
                  _Empty(isDark: isDark)
                else
                  ...controller.reviews.map(
                    (r) => _ReviewCard(review: r, isDark: isDark, controller: controller),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final PerformanceReviewModel review;
  final bool isDark;
  final PerformanceController controller;
  const _ReviewCard({required this.review, required this.isDark, required this.controller});

  @override
  Widget build(BuildContext context) {
    final card = isDark ? const Color(0xFF1E293B) : Colors.white;
    final border = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final text = isDark ? Colors.white : const Color(0xFF0F172A);
    final muted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final statusColor = _statusColors[review.status] ?? const Color(0xFF6B7280);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        review.cycle,
                        style: TextStyle(color: text, fontSize: 15, fontWeight: FontWeight.w800),
                      ),
                    ),
                    AppStatusBadge(label: review.statusLabel, color: statusColor),
                  ],
                ),
                if (review.period != null) ...[
                  const SizedBox(height: 2),
                  Text(review.period!, style: TextStyle(color: muted, fontSize: 12)),
                ],
                if (review.reviewerName != null) ...[
                  const SizedBox(height: 4),
                  Text('Reviewer: ${review.reviewerName}',
                      style: TextStyle(color: muted, fontSize: 12)),
                ],
              ],
            ),
          ),
          // Rating row (if reviewed)
          if (review.managerRating != null || review.selfRating != null)
            Container(
              margin: const EdgeInsets.fromLTRB(14, 0, 14, 0),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  if (review.selfRating != null)
                    Expanded(
                      child: _RatingCell(
                        label: 'Self',
                        rating: review.selfRating!,
                        ratingLabel: review.selfRatingLabel ?? '',
                        muted: muted,
                        text: text,
                      ),
                    ),
                  if (review.managerRating != null) ...[
                    Container(width: 1, height: 30, color: border),
                    Expanded(
                      child: _RatingCell(
                        label: 'Manager',
                        rating: review.managerRating!,
                        ratingLabel: review.managerRatingLabel ?? '',
                        muted: muted,
                        text: text,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          // Goals summary
          if (review.goals.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: Row(
                children: [
                  Text('Goals (${review.goals.length})',
                      style: TextStyle(
                        color: text, fontSize: 13, fontWeight: FontWeight.w700,
                      )),
                ],
              ),
            ),
            ...review.goals.map((g) => Padding(
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 0),
                  child: Row(
                    children: [
                      Container(
                        width: 6, height: 6,
                        decoration: BoxDecoration(
                          color: _goalStatusColors[g.status] ?? const Color(0xFF6B7280),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(g.title,
                            style: TextStyle(color: muted, fontSize: 12)),
                      ),
                      Text(g.statusLabel,
                          style: TextStyle(
                            color: _goalStatusColors[g.status] ?? muted,
                            fontSize: 10, fontWeight: FontWeight.w600,
                          )),
                    ],
                  ),
                )),
          ],
          // Action buttons
          if (review.canSelfAssess || review.canAcknowledge)
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (review.canSelfAssess)
                    FilledButton(
                      onPressed: () {
                        controller.initSelfAssessment(review);
                        _showSelfAssessSheet(context, review, isDark);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Self-assess',
                          style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  if (review.canAcknowledge)
                    FilledButton(
                      onPressed: () => controller.acknowledge(review.id),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF7C3AED),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Acknowledge',
                          style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                ],
              ),
            )
          else
            const SizedBox(height: 14),
        ],
      ),
    );
  }

  void _showSelfAssessSheet(
    BuildContext context,
    PerformanceReviewModel review,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SelfAssessSheet(review: review, isDark: isDark),
    );
  }
}

class _RatingCell extends StatelessWidget {
  final String label;
  final int rating;
  final String ratingLabel;
  final Color muted;
  final Color text;
  const _RatingCell({
    required this.label,
    required this.rating,
    required this.ratingLabel,
    required this.muted,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(color: muted, fontSize: 10)),
          const SizedBox(height: 2),
          Text('$rating / 5',
              style: TextStyle(
                color: text, fontSize: 16, fontWeight: FontWeight.w800,
              )),
          Text(ratingLabel,
              textAlign: TextAlign.center,
              style: TextStyle(color: muted, fontSize: 10)),
        ],
      ),
    );
  }
}

class _SelfAssessSheet extends GetView<PerformanceController> {
  final PerformanceReviewModel review;
  final bool isDark;
  const _SelfAssessSheet({required this.review, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final text = isDark ? Colors.white : const Color(0xFF0F172A);
    final muted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scroll) => Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.fromLTRB(
          16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Form(
          key: controller.formKey,
          child: ListView(
            controller: scroll,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: muted.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Self-Assessment',
                  style: TextStyle(color: text, fontSize: 17, fontWeight: FontWeight.w800)),
              Text(review.cycle,
                  style: TextStyle(color: muted, fontSize: 12)),
              const SizedBox(height: 20),
              Text('Your Rating *',
                  style: TextStyle(color: text, fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(5, (i) {
                      final r = i + 1;
                      final selected = controller.selectedRating.value == r;
                      return GestureDetector(
                        onTap: () => controller.selectedRating.value = r,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primary
                                : AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$r',
                            style: TextStyle(
                              color: selected ? Colors.white : AppColors.primary,
                              fontSize: 18, fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      );
                    }),
                  )),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller.commentController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Comments',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              if (review.goals.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('Goal Progress',
                    style: TextStyle(color: text, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ...review.goals.map((g) => Obx(() {
                      final currentStatus = controller.goalStatuses[g.id] ?? g.status;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(g.title,
                                style: TextStyle(color: text, fontSize: 12, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  'in_progress',
                                  'achieved',
                                  'partially_achieved',
                                  'not_achieved',
                                ].map((s) {
                                  final isSelected = currentStatus == s;
                                  final color = _goalStatusColors[s] ?? muted;
                                  return GestureDetector(
                                    onTap: () => controller.goalStatuses[g.id] = s,
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 6),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? color.withValues(alpha: 0.15)
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: isSelected ? color : muted.withValues(alpha: 0.3),
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        s.replaceAll('_', ' '),
                                        style: TextStyle(
                                          color: isSelected ? color : muted,
                                          fontSize: 10,
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      );
                    })),
              ],
              const SizedBox(height: 20),
              Obx(() => FilledButton(
                    onPressed: controller.isSubmitting.value
                        ? null
                        : () => controller.submitSelfAssessment(review.id),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: controller.isSubmitting.value
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Submit Assessment',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final bool isDark;
  const _Empty({required this.isDark});

  @override
  Widget build(BuildContext context) => AppCard(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 28),
            child: Column(
              children: [
                Icon(Icons.insert_chart_rounded,
                    size: 40, color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                const SizedBox(height: 12),
                Text('No performance reviews yet',
                    style: TextStyle(
                      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                      fontSize: 13,
                    )),
              ],
            ),
          ),
        ),
      );
}

class _ErrorRetry extends StatelessWidget {
  final bool isDark;
  final VoidCallback onRetry;
  const _ErrorRetry({required this.isDark, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded,
                size: 48, color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
            const SizedBox(height: 12),
            Text('Could not load performance',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  fontSize: 15, fontWeight: FontWeight.w700,
                )),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Retry'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      );
}
