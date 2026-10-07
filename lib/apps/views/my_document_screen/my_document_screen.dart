import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/my_document_controller/my_document_controller.dart';
import 'package:staff_attendance/widgets/app_page_widgets.dart';

import '../../../../apps/routes/routes.dart';

class MyDocumentsScreen extends GetView<MyDocumentsController> {
  const MyDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _AppBar(isDark: isDark),
            _DocumentHero(isDark: isDark),
            _TabRow(isDark: isDark),
            _StatusFilters(isDark: isDark),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                return RefreshIndicator(
                  onRefresh: controller.fetchAll,
                  color: const Color(0xFF185FA5),
                  child: _DocList(isDark: isDark),
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final uploaded = await Get.toNamed(Routes.documentUpload);
          if (uploaded == true) {
            controller.fetchAll();
          }
        },
        backgroundColor: const Color(0xFF185FA5),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Upload document',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// ── App bar ───────────────────────────────────────────────────────────────────
class _AppBar extends GetView<MyDocumentsController> {
  final bool isDark;
  const _AppBar({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          const AppBackButton(),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'My Documents',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
              ),
            ),
          ),
          // Pending badge
          Obx(() {
            final p = controller.countPending();
            if (p == 0) return const SizedBox.shrink();
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                '$p pending',
                style: const TextStyle(
                  color: Color(0xFFF59E0B),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _DocumentHero extends GetView<MyDocumentsController> {
  final bool isDark;
  const _DocumentHero({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [Color(0xFF123F6B), Color(0xFF111827)]
                : const [Color(0xFF185FA5), Color(0xFF4DA3E8)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF185FA5).withValues(alpha: 0.18),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.folder_copy_rounded, color: Colors.white, size: 24),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Document center',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Uploads, claim receipts and approval status in one place.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.82),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _HeroStat(
                  label: 'Documents',
                  value: '${controller.documentCount}',
                ),
                _HeroStat(label: 'Claims', value: '${controller.claimCount}'),
                _HeroStat(
                  label: 'Approved',
                  value: '${controller.approvedCount}',
                  isLast: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _HeroStat({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(right: isLast ? 0 : 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.78),
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tab row ───────────────────────────────────────────────────────────────────
class _TabRow extends GetView<MyDocumentsController> {
  final bool isDark;
  const _TabRow({required this.isDark});

  static const _tabs = [
    (DocTab.all, 'All'),
    (DocTab.documents, 'Documents'),
    (DocTab.claims, 'Claims'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Obx(
        () => Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: _tabs.map((t) {
              final isActive = controller.activeTab.value == t.$1;
              return Expanded(
                child: GestureDetector(
                  onTap: () => controller.setTab(t.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF185FA5)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Text(
                      t.$2,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isActive
                            ? Colors.white
                            : isDark
                            ? const Color(0xFF64748B)
                            : const Color(0xFF94A3B8),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ── Status filter chips ───────────────────────────────────────────────────────
class _StatusFilters extends GetView<MyDocumentsController> {
  final bool isDark;
  const _StatusFilters({required this.isDark});

  static const _statuses = [
    ('pending', 'Pending', 0xFFF59E0B),
    ('approved', 'Approved', 0xFF16A34A),
    ('rejected', 'Rejected', 0xFFDC2626),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Row(
          children: [
            // All chip
            _buildChip(null, 'All statuses', 0xFF185FA5),
            ..._statuses.map((s) => _buildChip(s.$1, s.$2, s.$3)),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String? status, String label, int colorVal) {
    final isActive = controller.activeStatus.value == status;
    final color = Color(colorVal);
    return GestureDetector(
      onTap: () => controller.setStatus(status),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? color
                : isDark
                ? const Color(0xFF334155)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive
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
  }
}

// ── Document list ─────────────────────────────────────────────────────────────
class _DocList extends GetView<MyDocumentsController> {
  final bool isDark;
  const _DocList({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list = controller.filtered;
      if (list.isEmpty) return _EmptyState(isDark: isDark);
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
        itemCount: list.length,
        itemBuilder: (_, i) => _DocCard(item: list[i], isDark: isDark),
      );
    });
  }
}

// ── Doc card ──────────────────────────────────────────────────────────────────
class _DocCard extends GetView<MyDocumentsController> {
  final DocItem item;
  final bool isDark;
  const _DocCard({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final typeColor = Color(item.typeColor);
    final statusColor = Color(item.statusColor);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openDetailSheet(context, typeColor, statusColor),
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        item.isClaim
                            ? Icons.receipt_long_rounded
                            : Icons.description_rounded,
                        color: typeColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: TextStyle(
                              color: isDark
                                  ? const Color(0xFFE2E8F0)
                                  : const Color(0xFF1E293B),
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.subtitle,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    _StatusPill(label: item.statusLabel, color: statusColor),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _MetaPill(
                      icon: Icons.access_time_rounded,
                      label: item.dateLabel,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    _MetaPill(
                      icon: item.isClaim
                          ? Icons.payments_rounded
                          : Icons.upload_file_rounded,
                      label: item.isClaim ? 'Claim receipt' : 'Uploaded file',
                      isDark: isDark,
                    ),
                    const Spacer(),
                    Icon(
                      item.fileUrl == null
                          ? Icons.info_outline_rounded
                          : Icons.open_in_new_rounded,
                      size: 16,
                      color: item.fileUrl == null
                          ? const Color(0xFF94A3B8)
                          : typeColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openDetailSheet(
    BuildContext context,
    Color typeColor,
    Color statusColor,
  ) {
    Get.bottomSheet(
      SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF111827) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      item.isClaim
                          ? Icons.receipt_long_rounded
                          : Icons.description_rounded,
                      color: typeColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.title,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _DetailRow(
                title: 'Category',
                value: item.subtitle,
                isDark: isDark,
              ),
              const SizedBox(height: 10),
              _DetailRow(
                title: 'Submitted',
                value: item.dateLabel,
                isDark: isDark,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    'Status',
                    style: TextStyle(
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item.statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: Get.back,
                      icon: const Icon(Icons.close_rounded, size: 18),
                      label: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: item.fileUrl == null
                          ? null
                          : () => controller.openFile(item.fileUrl),
                      icon: const Icon(Icons.open_in_new_rounded, size: 18),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF185FA5),
                      ),
                      label: Text(item.isClaim ? 'Open receipt' : 'Open file'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  const _MetaPill({
    required this.icon,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String title;
  final String value;
  final bool isDark;

  const _DetailRow({
    required this.title,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            fontSize: 12,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.folder_open_rounded,
            size: 52,
            color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
          ),
          const SizedBox(height: 14),
          Text(
            'No documents found',
            style: TextStyle(
              color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your uploads and claims will appear here',
            style: TextStyle(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
