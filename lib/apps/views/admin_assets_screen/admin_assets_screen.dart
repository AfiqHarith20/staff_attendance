import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/admin_assets_controller/admin_assets_controller.dart';
import 'package:staff_attendance/apps/models/admin_asset_model.dart';
import 'package:staff_attendance/apps/themes/app_colors.dart';
import 'package:staff_attendance/widgets/app_page_widgets.dart';

const _categoryIcons = <String, IconData>{
  'laptop': Icons.laptop_rounded,
  'phone': Icons.phone_android_rounded,
  'vehicle': Icons.directions_car_rounded,
  'access_card': Icons.credit_card_rounded,
  'furniture': Icons.chair_rounded,
  'equipment': Icons.build_rounded,
  'other': Icons.inventory_2_rounded,
};

const _conditionColors = <String, Color>{
  'new': Color(0xFF16A34A),
  'good': Color(0xFF2563EB),
  'fair': Color(0xFFF59E0B),
  'damaged': Color(0xFFDC2626),
  'written_off': Color(0xFF6B7280),
};

class AdminAssetsScreen extends GetView<AdminAssetsController> {
  const AdminAssetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final text = isDark ? Colors.white : const Color(0xFF0F172A);

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
                  const AppPageHeader(title: 'Asset Management'),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller.searchController,
                    onChanged: (v) => controller.searchQuery.value = v,
                    decoration: InputDecoration(
                      hintText: 'Search assets...',
                      hintStyle: TextStyle(
                          color: text.withOpacity(0.4), fontSize: 13),
                      prefixIcon: Icon(Icons.search_rounded,
                          color: text.withOpacity(0.4)),
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFEFF2F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Filter row
                  Obx(() => SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _FilterChip(
                              label: 'All',
                              selected:
                                  controller.filterAssigned.value == null,
                              isDark: isDark,
                              onTap: () {
                                controller.filterAssigned.value = null;
                                controller.fetchAssets();
                              },
                            ),
                            const SizedBox(width: 6),
                            _FilterChip(
                              label: 'Assigned',
                              selected:
                                  controller.filterAssigned.value == true,
                              isDark: isDark,
                              onTap: () {
                                controller.filterAssigned.value = true;
                                controller.fetchAssets();
                              },
                            ),
                            const SizedBox(width: 6),
                            _FilterChip(
                              label: 'Unassigned',
                              selected:
                                  controller.filterAssigned.value == false,
                              isDark: isDark,
                              onTap: () {
                                controller.filterAssigned.value = false;
                                controller.fetchAssets();
                              },
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary, strokeWidth: 2.5),
                  );
                }
                if (controller.hasError.value) {
                  return _ErrorRetry(
                    isDark: isDark,
                    onRetry: controller.fetchAssets,
                  );
                }
                final list = controller.filtered;
                if (list.isEmpty) {
                  return Center(
                    child: Text(
                      'No assets found.',
                      style: TextStyle(color: text.withOpacity(0.4)),
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: controller.fetchAssets,
                  color: AppColors.primary,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _AssetCard(
                      asset: list[i],
                      isDark: isDark,
                      onUnassign: list[i].isAssigned
                          ? () => controller.unassign(list[i])
                          : null,
                    ),
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? Colors.white
                : (isDark ? Colors.white70 : Colors.black54),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _AssetCard extends StatelessWidget {
  const _AssetCard({
    required this.asset,
    required this.isDark,
    this.onUnassign,
  });

  final AdminAssetModel asset;
  final bool isDark;
  final VoidCallback? onUnassign;

  @override
  Widget build(BuildContext context) {
    final text = isDark ? Colors.white : const Color(0xFF0F172A);
    final sub = text.withOpacity(0.5);
    final icon = _categoryIcons[asset.category] ?? Icons.inventory_2_rounded;
    final condColor =
        _conditionColors[asset.condition] ?? const Color(0xFF6B7280);

    return AppCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asset.name,
                  style: TextStyle(
                    color: text,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                if (asset.code != null || asset.brand != null)
                  Text(
                    [if (asset.code != null) asset.code!, if (asset.brand != null) asset.brand!].join(' · '),
                    style: TextStyle(color: sub, fontSize: 12),
                  ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: condColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        asset.conditionLabel,
                        style: TextStyle(
                          color: condColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (asset.isAssigned) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF185FA5).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          asset.assignedTo!.name,
                          style: const TextStyle(
                            color: Color(0xFF185FA5),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (onUnassign != null)
            IconButton(
              onPressed: onUnassign,
              tooltip: 'Unassign',
              icon: Icon(Icons.link_off_rounded,
                  size: 18, color: Colors.red.withOpacity(0.7)),
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  const _ErrorRetry({required this.isDark, required this.onRetry});

  final bool isDark;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded,
              size: 48, color: Colors.red.withOpacity(0.6)),
          const SizedBox(height: 12),
          Text(
            'Failed to load assets',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
