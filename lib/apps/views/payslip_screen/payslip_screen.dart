import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/payslip_controller/payslip_controller.dart';
import 'package:staff_attendance/apps/models/payslip_model.dart';
import 'package:staff_attendance/widgets/app_page_widgets.dart';
import 'package:staff_attendance/widgets/app_toast.dart';
import 'package:url_launcher/url_launcher.dart';

class PayslipScreen extends GetView<PayslipController> {
  const PayslipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _Header(isDark: isDark),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.errorMessage.isNotEmpty &&
                    controller.payslips.isEmpty) {
                  return _PayslipErrorState(
                    isDark: isDark,
                    message: controller.errorMessage.value,
                    onRetry: controller.fetchPayslips,
                  );
                }
                final items = controller.filtered;
                if (items.isEmpty) {
                  return _PayslipEmptyState(isDark: isDark);
                }
                return RefreshIndicator(
                  onRefresh: controller.fetchPayslips,
                  color: const Color(0xFF185FA5),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: items
                        .map((item) => _PayslipCard(item: item, isDark: isDark))
                        .toList(),
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

class _Header extends GetView<PayslipController> {
  final bool isDark;
  const _Header({required this.isDark});

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
              'payslip'.tr,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Obx(
            () => GestureDetector(
              onTap: () => _showYearPicker(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${controller.selectedYear.value}',
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.expand_more_rounded,
                      size: 14,
                      color: isDark
                          ? const Color(0xFF64748B)
                          : const Color(0xFF94A3B8),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showYearPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            children: controller.availableYears.map((year) {
              return Material(
                color: Colors.transparent,
                child: ListTile(
                  title: Text(
                    '$year',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  trailing: controller.selectedYear.value == year
                      ? const Icon(
                          Icons.check_rounded,
                          color: Color(0xFF185FA5),
                        )
                      : null,
                  onTap: () {
                    controller.setYear(year);
                    Get.back();
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _PayslipCard extends GetView<PayslipController> {
  final PayslipModel item;
  final bool isDark;
  const _PayslipCard({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.monthLabel,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.status,
                  style: const TextStyle(
                    color: Color(0xFF16A34A),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            item.periodLabel,
            style: TextStyle(
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MetaTile(
                  label: 'net_pay'.tr,
                  value: item.netPayLabel,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetaTile(
                  label: 'issued'.tr,
                  value: controller.formatIssued(item.issuedAt),
                  isDark: isDark,
                ),
              ),
            ],
          ),
          if (item.hasBreakdown) ...[
            const SizedBox(height: 14),
            _StatutoryBreakdown(item: item, isDark: isDark),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _openPayslip(item.fileUrl),
              icon: const Icon(Icons.download_rounded, size: 18),
              label: Text('preview_download'.tr),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF185FA5),
                side: const BorderSide(color: Color(0xFF185FA5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openPayslip(String fileUrl) async {
    final uri = Uri.tryParse(fileUrl);
    if (uri == null) {
      AppToast.failed('unavailable'.tr, 'payslip_open_error'.tr);
      return;
    }
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      AppToast.failed('unavailable'.tr, 'payslip_open_error'.tr);
    }
  }
}

class _StatutoryBreakdown extends StatelessWidget {
  final PayslipModel item;
  final bool isDark;
  const _StatutoryBreakdown({required this.item, required this.isDark});

  String _rm(double value) => 'RM ${value.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final labelColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final valueColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final rows = <(String, String)>[
      ('gross_pay'.tr, _rm(item.grossPay)),
      ('epf_employee'.tr, '- ${_rm(item.epfEmployee)}'),
      ('socso_employee'.tr, '- ${_rm(item.socsoEmployee)}'),
      ('eis_employee'.tr, '- ${_rm(item.eisEmployee)}'),
      ('pcb_income_tax'.tr, '- ${_rm(item.pcb)}'),
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'statutory_deductions'.tr,
            style: TextStyle(
              color: labelColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    row.$1,
                    style: TextStyle(color: labelColor, fontSize: 12),
                  ),
                  Text(
                    row.$2,
                    style: TextStyle(
                      color: valueColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          Divider(
            height: 1,
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'net_pay'.tr,
                style: TextStyle(
                  color: valueColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                _rm(item.netPay),
                style: const TextStyle(
                  color: Color(0xFF16A34A),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaTile extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  const _MetaTile({
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PayslipErrorState extends StatelessWidget {
  final bool isDark;
  final String message;
  final VoidCallback onRetry;
  const _PayslipErrorState({
    required this.isDark,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 42,
              color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              child: Text(
                'retry'.tr,
                style: const TextStyle(
                  color: Color(0xFF185FA5),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PayslipEmptyState extends StatelessWidget {
  final bool isDark;
  const _PayslipEmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_rounded,
              size: 42,
              color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
            ),
            const SizedBox(height: 12),
            Text(
              'no_payslips'.tr,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
