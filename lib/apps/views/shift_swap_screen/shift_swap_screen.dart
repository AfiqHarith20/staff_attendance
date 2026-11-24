import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/shift_swap_controller/shift_swap_controller.dart';
import 'package:staff_attendance/apps/models/shift_swap_model.dart';
import 'package:staff_attendance/apps/themes/app_colors.dart';
import 'package:staff_attendance/widgets/app_page_widgets.dart';

const _statusColors = <String, Color>{
  'pending': Color(0xFFF59E0B),
  'approved': Color(0xFF16A34A),
  'rejected': Color(0xFFDC2626),
  'cancelled': Color(0xFF6B7280),
};

class ShiftSwapScreen extends GetView<ShiftSwapController> {
  const ShiftSwapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: bg,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showApplySheet(context, isDark),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.swap_horiz_rounded, color: Colors.white),
        label: const Text('Request Swap', style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5),
            );
          }
          if (controller.hasError.value) {
            return _ErrorRetry(isDark: isDark, onRetry: controller.fetchSwaps);
          }
          return RefreshIndicator(
            onRefresh: controller.fetchSwaps,
            color: AppColors.primary,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: [
                const AppPageHeader(title: 'Shift Swaps'),
                const SizedBox(height: 12),
                if (controller.swaps.isEmpty)
                  _Empty(isDark: isDark)
                else
                  ...controller.swaps.map(
                    (s) => _SwapCard(swap: s, isDark: isDark, controller: controller),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  void _showApplySheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ApplySwapSheet(isDark: isDark),
    );
  }
}

class _SwapCard extends StatelessWidget {
  final ShiftSwapModel swap;
  final bool isDark;
  final ShiftSwapController controller;
  const _SwapCard({required this.swap, required this.isDark, required this.controller});

  @override
  Widget build(BuildContext context) {
    final card = isDark ? const Color(0xFF1E293B) : Colors.white;
    final border = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final text = isDark ? Colors.white : const Color(0xFF0F172A);
    final muted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final statusColor = _statusColors[swap.status] ?? const Color(0xFF6B7280);

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
          Row(
            children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.swap_horiz_rounded, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      swap.isMine
                          ? 'You → ${swap.targetName ?? 'Colleague'}'
                          : '${swap.requesterName ?? 'Colleague'} → You',
                      style: TextStyle(color: text, fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    if (swap.requesterShift != null)
                      Text(
                        '${swap.requesterShift!.date} · ${swap.requesterShift!.title ?? 'Shift'}',
                        style: TextStyle(color: muted, fontSize: 11),
                      ),
                  ],
                ),
              ),
              AppStatusBadge(
                label: swap.status[0].toUpperCase() + swap.status.substring(1),
                color: statusColor,
              ),
            ],
          ),
          if (swap.reason != null) ...[
            const SizedBox(height: 8),
            Text('"${swap.reason}"', style: TextStyle(color: muted, fontSize: 11)),
          ],
          if (swap.adminNote != null) ...[
            const SizedBox(height: 4),
            Text('Admin: ${swap.adminNote}', style: const TextStyle(color: Color(0xFF16A34A), fontSize: 11)),
          ],
          if (swap.isMine && swap.isPending) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Obx(() => TextButton(
                    onPressed: controller.isCancelling.value
                        ? null
                        : () => controller.cancel(swap),
                    child: Text(
                      'Cancel request',
                      style: TextStyle(
                        color: controller.isCancelling.value
                            ? muted
                            : const Color(0xFFDC2626),
                        fontSize: 12,
                      ),
                    ),
                  )),
            ),
          ],
        ],
      ),
    );
  }
}

class _ApplySwapSheet extends GetView<ShiftSwapController> {
  final bool isDark;
  const _ApplySwapSheet({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final text = isDark ? Colors.white : const Color(0xFF0F172A);
    final muted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
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
              Text('Request Shift Swap',
                  style: TextStyle(color: text, fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(
                'Enter the colleague ID you want to swap shifts with. Your manager will review the request.',
                style: TextStyle(color: muted, fontSize: 12),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller.targetIdController,
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                decoration: InputDecoration(
                  labelText: 'Colleague ID *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.reasonController,
                maxLines: 3,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                decoration: InputDecoration(
                  labelText: 'Reason *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 20),
              Obx(() => FilledButton(
                    onPressed: controller.isSubmitting.value ? null : controller.submit,
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
                        : const Text('Submit Request',
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
                Icon(Icons.swap_horiz_rounded,
                    size: 40, color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                const SizedBox(height: 12),
                Text('No shift swap requests',
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
            Text('Could not load shift swaps',
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
