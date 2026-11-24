import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/my_assets_controller/my_assets_controller.dart';
import 'package:staff_attendance/apps/models/asset_model.dart';
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

class MyAssetsScreen extends GetView<MyAssetsController> {
  const MyAssetsScreen({super.key});

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
            return _ErrorRetry(isDark: isDark, onRetry: controller.fetchAssets);
          }
          return RefreshIndicator(
            onRefresh: controller.fetchAssets,
            color: AppColors.primary,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                const AppPageHeader(title: 'My Assets'),
                const SizedBox(height: 12),
                if (controller.assets.isEmpty)
                  _Empty(isDark: isDark)
                else
                  ...controller.assets.map((a) => _AssetCard(asset: a, isDark: isDark)),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _AssetCard extends StatelessWidget {
  final AssetModel asset;
  final bool isDark;
  const _AssetCard({required this.asset, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final card = isDark ? const Color(0xFF1E293B) : Colors.white;
    final border = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final text = isDark ? Colors.white : const Color(0xFF0F172A);
    final muted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final icon = _categoryIcons[asset.category] ?? Icons.inventory_2_rounded;
    final conditionColor = _conditionColors[asset.condition] ?? const Color(0xFF6B7280);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asset.name,
                  style: TextStyle(
                    color: text, fontSize: 14, fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  asset.categoryLabel,
                  style: TextStyle(color: muted, fontSize: 11),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if (asset.brand != null || asset.modelNo != null)
                      _InfoChip(
                        label: [asset.brand, asset.modelNo].where((s) => s != null).join(' · '),
                        color: muted,
                      ),
                    if (asset.serialNo != null)
                      _InfoChip(label: 'S/N: ${asset.serialNo}', color: muted),
                    if (asset.code != null)
                      _InfoChip(label: asset.code!, color: muted),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: conditionColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  asset.conditionLabel,
                  style: TextStyle(
                    color: conditionColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (asset.assignedOn != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Since ${asset.assignedOn}',
                  style: TextStyle(color: muted, fontSize: 10),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;
  const _InfoChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(label, style: TextStyle(color: color, fontSize: 11));
  }
}

class _Empty extends StatelessWidget {
  final bool isDark;
  const _Empty({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 28),
          child: Column(
            children: [
              Icon(Icons.inventory_2_rounded,
                  size: 40, color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
              const SizedBox(height: 12),
              Text(
                'No assets assigned to you',
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
}

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
          Icon(Icons.cloud_off_rounded,
              size: 48, color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
          const SizedBox(height: 12),
          Text('Could not load assets',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                fontSize: 15, fontWeight: FontWeight.w700,
              )),
          const SizedBox(height: 4),
          const Text('Check your connection and try again.',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
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
}
