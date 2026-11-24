import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/signature_requests_controller/signature_requests_controller.dart';
import 'package:staff_attendance/apps/models/signature_request_model.dart';
import 'package:staff_attendance/apps/themes/app_colors.dart';
import 'package:staff_attendance/widgets/app_page_widgets.dart';

const _statusColors = <String, Color>{
  'pending': Color(0xFF2563EB),
  'signed': Color(0xFF16A34A),
  'declined': Color(0xFFDC2626),
  'cancelled': Color(0xFF6B7280),
};

class SignatureRequestsScreen extends GetView<SignatureRequestsController> {
  const SignatureRequestsScreen({super.key});

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
            return _ErrorRetry(isDark: isDark, onRetry: controller.fetchRequests);
          }
          return RefreshIndicator(
            onRefresh: controller.fetchRequests,
            color: AppColors.primary,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                const AppPageHeader(title: 'Signature Requests'),
                const SizedBox(height: 12),
                _PendingBanner(isDark: isDark),
                if (controller.requests.isEmpty)
                  _Empty(isDark: isDark)
                else
                  ...controller.requests.map(
                    (r) => _RequestCard(req: r, isDark: isDark, controller: controller),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _PendingBanner extends GetView<SignatureRequestsController> {
  final bool isDark;
  const _PendingBanner({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final pending = controller.requests.where((r) => r.isPending).length;
      final overdue = controller.requests.where((r) => r.isOverdue).length;
      if (pending == 0) return const SizedBox.shrink();
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: overdue > 0
              ? const Color(0xFFDC2626).withValues(alpha: 0.08)
              : AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: overdue > 0
                ? const Color(0xFFDC2626).withValues(alpha: 0.2)
                : AppColors.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              overdue > 0 ? Icons.warning_amber_rounded : Icons.edit_document,
              color: overdue > 0 ? const Color(0xFFDC2626) : AppColors.primary,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                overdue > 0
                    ? '$overdue document${overdue != 1 ? 's' : ''} overdue · $pending awaiting your signature'
                    : '$pending document${pending != 1 ? 's' : ''} awaiting your signature',
                style: TextStyle(
                  color: overdue > 0 ? const Color(0xFFDC2626) : AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _RequestCard extends StatelessWidget {
  final SignatureRequestModel req;
  final bool isDark;
  final SignatureRequestsController controller;
  const _RequestCard({required this.req, required this.isDark, required this.controller});

  @override
  Widget build(BuildContext context) {
    final card = isDark ? const Color(0xFF1E293B) : Colors.white;
    final border = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final text = isDark ? Colors.white : const Color(0xFF0F172A);
    final muted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final statusColor = req.isOverdue ? const Color(0xFFDC2626) : (_statusColors[req.status] ?? const Color(0xFF6B7280));

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: req.isOverdue ? const Color(0xFFDC2626).withValues(alpha: 0.4) : border,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  req.isSigned ? Icons.check_circle_rounded : Icons.edit_document,
                  color: statusColor, size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(req.title,
                        style: TextStyle(color: text, fontSize: 13, fontWeight: FontWeight.w700)),
                    if (req.description != null)
                      Text(req.description!,
                          style: TextStyle(color: muted, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              AppStatusBadge(
                label: req.isOverdue ? 'Overdue' : (req.status[0].toUpperCase() + req.status.substring(1)),
                color: statusColor,
              ),
            ],
          ),
          if (req.dueDate != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.event_rounded, size: 12, color: req.isOverdue ? const Color(0xFFDC2626) : muted),
                const SizedBox(width: 4),
                Text(
                  'Due ${req.dueDate}',
                  style: TextStyle(
                    color: req.isOverdue ? const Color(0xFFDC2626) : muted,
                    fontSize: 11,
                    fontWeight: req.isOverdue ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
          if (req.isPending) ...[
            const SizedBox(height: 12),
            Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: controller.isActioning.value
                          ? null
                          : () => _showDeclineDialog(context, muted, text),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFDC2626),
                        side: const BorderSide(color: Color(0xFFDC2626)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Decline', style: TextStyle(fontSize: 12)),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: controller.isActioning.value
                          ? null
                          : () => _confirmSign(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: controller.isActioning.value
                          ? const SizedBox(
                              width: 14, height: 14,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Sign', style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  ],
                )),
          ],
          if (req.isSigned && req.signedAt != null) ...[
            const SizedBox(height: 6),
            Text('Signed on ${req.signedAt!.split('T').first}',
                style: const TextStyle(color: Color(0xFF16A34A), fontSize: 11)),
          ],
          if (req.isDeclined && req.declineReason != null) ...[
            const SizedBox(height: 6),
            Text('Declined: ${req.declineReason}',
                style: const TextStyle(color: Color(0xFFDC2626), fontSize: 11)),
          ],
        ],
      ),
    );
  }

  void _confirmSign(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign Document'),
        content: Text('By signing, you confirm that you have read and agree to "${req.title}".'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Get.back();
              controller.sign(req);
            },
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF16A34A)),
            child: const Text('Sign', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeclineDialog(BuildContext context, Color muted, Color text) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Decline Document'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Please provide a reason for declining "${req.title}".',
                style: TextStyle(color: muted, fontSize: 13)),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Reason…',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) return;
              Get.back();
              controller.decline(req, reason);
            },
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
            child: const Text('Decline', style: TextStyle(color: Colors.white)),
          ),
        ],
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
                Icon(Icons.edit_document,
                    size: 40, color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                const SizedBox(height: 12),
                Text('No signature requests',
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
            Text('Could not load signature requests',
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
