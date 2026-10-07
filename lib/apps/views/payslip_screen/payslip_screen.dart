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
              'Pay Slip',
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
                  label: 'Net Pay',
                  value: item.netPayLabel,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetaTile(
                  label: 'Issued',
                  value: controller.formatIssued(item.issuedAt),
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _openPayslip(item.fileUrl),
              icon: const Icon(Icons.download_rounded, size: 18),
              label: const Text('Preview / Download'),
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
      AppToast.failed('Unavailable', 'Unable to open this payslip right now.');
      return;
    }
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      AppToast.failed('Unavailable', 'Unable to open this payslip right now.');
    }
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
              'No payslips for this year',
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
