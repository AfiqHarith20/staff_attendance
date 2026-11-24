import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/job_board_controller/job_board_controller.dart';
import 'package:staff_attendance/apps/models/job_posting_model.dart';
import 'package:staff_attendance/apps/themes/app_colors.dart';
import 'package:staff_attendance/widgets/app_page_widgets.dart';

const _typeColors = <String, Color>{
  'full_time': Color(0xFF2563EB),
  'part_time': Color(0xFF7C3AED),
  'contract': Color(0xFFF59E0B),
  'internship': Color(0xFF16A34A),
};

class JobBoardScreen extends GetView<JobBoardController> {
  const JobBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppPageHeader(title: 'Job Board'),
                  const SizedBox(height: 12),
                  _SearchBar(isDark: isDark),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5),
                  );
                }
                if (controller.hasError.value) {
                  return _ErrorRetry(isDark: isDark, onRetry: controller.fetchJobs);
                }
                final jobs = controller.filtered;
                if (jobs.isEmpty) {
                  return _Empty(isDark: isDark, hasSearch: controller.searchQuery.value.isNotEmpty);
                }
                return RefreshIndicator(
                  onRefresh: controller.fetchJobs,
                  color: AppColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    itemCount: jobs.length,
                    itemBuilder: (_, i) => _JobCard(job: jobs[i], isDark: isDark),
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

class _SearchBar extends GetView<JobBoardController> {
  final bool isDark;
  const _SearchBar({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final fill = isDark ? const Color(0xFF1E293B) : Colors.white;
    final border = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return TextField(
      onChanged: controller.searchQuery,
      decoration: InputDecoration(
        hintText: 'Search roles, departments…',
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 20),
        filled: true,
        fillColor: fill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final JobPostingModel job;
  final bool isDark;
  const _JobCard({required this.job, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final card = isDark ? const Color(0xFF1E293B) : Colors.white;
    final border = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final text = isDark ? Colors.white : const Color(0xFF0F172A);
    final muted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final typeColor = _typeColors[job.employmentType] ?? AppColors.primary;

    return GestureDetector(
      onTap: () => _showDetail(context, isDark),
      child: Container(
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(job.title,
                          style: TextStyle(
                            color: text, fontSize: 14, fontWeight: FontWeight.w700,
                          )),
                      if (job.department != null)
                        Text(job.department!,
                            style: TextStyle(color: muted, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(job.employmentTypeLabel,
                      style: TextStyle(
                        color: typeColor, fontSize: 10, fontWeight: FontWeight.w700,
                      )),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (job.location != null)
                  _MetaChip(
                    icon: Icons.location_on_rounded,
                    label: job.location!,
                    muted: muted,
                  ),
                if (job.headcount != null)
                  _MetaChip(
                    icon: Icons.people_rounded,
                    label: '${job.headcount} opening${job.headcount! != 1 ? 's' : ''}',
                    muted: muted,
                  ),
                if (job.openedAt != null)
                  _MetaChip(
                    icon: Icons.calendar_today_rounded,
                    label: job.openedAt!,
                    muted: muted,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context, bool isDark) {
    final text = isDark ? Colors.white : const Color(0xFF0F172A);
    final muted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final bg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final typeColor = _typeColors[job.employmentType] ?? AppColors.primary;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scroll) => Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
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
              Text(job.title,
                  style: TextStyle(color: text, fontSize: 18, fontWeight: FontWeight.w800)),
              if (job.department != null)
                Text(job.department!,
                    style: TextStyle(color: muted, fontSize: 13)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8, runSpacing: 6,
                children: [
                  _MetaTag(label: job.employmentTypeLabel, color: typeColor),
                  if (job.location != null) _MetaTag(label: job.location!, color: muted),
                  if (job.headcount != null)
                    _MetaTag(label: '${job.headcount} openings', color: muted),
                ],
              ),
              if (job.description != null) ...[
                const SizedBox(height: 20),
                Text('About the role',
                    style: TextStyle(color: text, fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(job.description!, style: TextStyle(color: muted, fontSize: 13, height: 1.5)),
              ],
              if (job.requirements != null) ...[
                const SizedBox(height: 16),
                Text('Requirements',
                    style: TextStyle(color: text, fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(job.requirements!, style: TextStyle(color: muted, fontSize: 13, height: 1.5)),
              ],
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Interested? Contact HR or your direct manager to apply for this internal position.',
                        style: const TextStyle(color: AppColors.primary, fontSize: 12, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color muted;
  const _MetaChip({required this.icon, required this.label, required this.muted});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: muted),
          const SizedBox(width: 3),
          Text(label, style: TextStyle(color: muted, fontSize: 11)),
        ],
      );
}

class _MetaTag extends StatelessWidget {
  final String label;
  final Color color;
  const _MetaTag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
      );
}

class _Empty extends StatelessWidget {
  final bool isDark;
  final bool hasSearch;
  const _Empty({required this.isDark, required this.hasSearch});

  @override
  Widget build(BuildContext context) => AppCard(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 28),
            child: Column(
              children: [
                Icon(Icons.work_outline_rounded,
                    size: 40, color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                const SizedBox(height: 12),
                Text(
                  hasSearch ? 'No results for your search' : 'No open positions right now',
                  style: TextStyle(
                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                    fontSize: 13,
                  ),
                ),
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
            Text('Could not load job board',
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
