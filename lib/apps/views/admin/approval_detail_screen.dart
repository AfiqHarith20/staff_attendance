import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/approval_inbox_controller/approval_inbox_controller.dart';
import 'package:staff_attendance/widgets/app_page_widgets.dart';

class ApprovalDetailScreen extends GetView<ApprovalInboxController> {
  const ApprovalDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ApprovalInboxController>()) {
      Get.put(ApprovalInboxController());
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final item = Map<String, dynamic>.from(Get.arguments as Map? ?? const {});
    final status = '${item['status'] ?? 'Pending'}';
    final type = '${item['type'] ?? 'Request'}';
    final id = '${item['id'] ?? ''}';
    final audit = (item['audit'] as List? ?? const [])
        .map((e) => '$e')
        .toList();

    final statusColor = switch (status) {
      'Approved' => const Color(0xFF16A34A),
      'Rejected' => const Color(0xFFDC2626),
      _ => const Color(0xFFF59E0B),
    };

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            const AppPageHeader(title: 'Approval Detail'),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AppStatusBadge(
                        label: type,
                        color: const Color(0xFF185FA5),
                      ),
                      const SizedBox(width: 8),
                      AppStatusBadge(label: status, color: statusColor),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${item['title'] ?? 'Request detail'}',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${item['subtitle'] ?? 'Full approval context will appear here.'}',
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Request detail',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppDetailLine(
                    label: 'Request ID',
                    value: id.isEmpty ? 'N/A' : id,
                  ),
                  AppDetailLine(
                    label: 'Submitted',
                    value: '${item['submitted'] ?? 'Unknown'}',
                  ),
                  AppDetailLine(
                    label: 'Summary',
                    value: '${item['detail'] ?? item['subtitle'] ?? '-'}',
                  ),
                  const AppDetailLine(
                    label: 'Attachment',
                    value: 'Receipt / document attached',
                  ),
                  const AppDetailLine(
                    label: 'Approver',
                    value: 'Manager -> HR -> Final approver',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Audit history',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final entry
                      in audit.isEmpty
                          ? ['Request submitted and awaiting review']
                          : audit)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF185FA5,
                              ).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Icon(
                              Icons.history_rounded,
                              size: 14,
                              color: Color(0xFF185FA5),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              entry,
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12,
                                height: 1.45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: status == 'Pending'
          ? SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _reject(context, id),
                        icon: const Icon(Icons.close_rounded),
                        label: const Text('Reject'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFDC2626),
                          side: const BorderSide(color: Color(0xFFDC2626)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: id.isEmpty
                            ? null
                            : () => controller.decide(id, 'Approved'),
                        icon: const Icon(Icons.check_rounded),
                        label: const Text('Approve'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF16A34A),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  void _reject(BuildContext context, String id) {
    final remarks = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text('Reject request'),
        content: TextField(
          controller: remarks,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Add rejection remarks',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          FilledButton(
            onPressed: id.isEmpty
                ? null
                : () {
                    Get.back();
                    controller.decide(
                      id,
                      'Rejected',
                      remarks: remarks.text.trim(),
                    );
                  },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}
