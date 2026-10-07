// ignore_for_file: use_key_in_widget_constructors, camel_case_types

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:staff_attendance/widgets/app_page_widgets.dart';

// ── App bar ──────────────────────────────────────────────────────────────────
class appBar extends StatelessWidget {
  final bool isDark;
  final String title;
  const appBar({required this.isDark, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          const AppBackButton(),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class formSectionCard extends StatelessWidget {
  final bool isDark;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const formSectionCard({
    required this.isDark,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: child,
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────
class sectionLabel extends StatelessWidget {
  final String label;
  final bool isDark;
  const sectionLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.5,
      ),
    );
  }
}

// ── Date picker tile ──────────────────────────────────────────────────────────
class datePickerTile extends StatelessWidget {
  final String label;
  final bool isDark;
  final Rxn<DateTime> dateObs;
  final VoidCallback onTap;
  final IconData icon;

  const datePickerTile({
    required this.label,
    required this.isDark,
    required this.dateObs,
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final date = dateObs.value;
      final hasDate = date != null;
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasDate
                  ? const Color(0xFF185FA5)
                  : isDark
                  ? const Color(0xFF334155)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFF64748B)
                      : const Color(0xFF94A3B8),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: hasDate
                        ? const Color(0xFF185FA5)
                        : isDark
                        ? const Color(0xFF475569)
                        : const Color(0xFFCBD5E1),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      hasDate
                          ? DateFormat('d MMM yyyy').format(date)
                          : 'Select',
                      style: TextStyle(
                        color: hasDate
                            ? isDark
                                  ? Colors.white
                                  : const Color(0xFF0F172A)
                            : isDark
                            ? const Color(0xFF475569)
                            : const Color(0xFFCBD5E1),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: isDark
                        ? const Color(0xFF475569)
                        : const Color(0xFFCBD5E1),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}

// ── Reason text field ─────────────────────────────────────────────────────────
class reasonField extends StatelessWidget {
  final TextEditingController ctrl;
  final bool isDark;
  final String hint;

  const reasonField({
    required this.ctrl,
    required this.isDark,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      maxLines: 4,
      style: TextStyle(
        color: isDark ? Colors.white : const Color(0xFF0F172A),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
          fontSize: 13,
          height: 1.4,
        ),
        fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        filled: true,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF185FA5), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFDC2626)),
        ),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Reason is required';
        if (v.trim().length < 10) return 'Please provide more detail';
        return null;
      },
    );
  }
}

// ── Note card ─────────────────────────────────────────────────────────────────
class noteCard extends StatelessWidget {
  final bool isDark;
  final List<String> lines;
  const noteCard({required this.isDark, required this.lines});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF185FA5).withValues(alpha: 0.10)
            : const Color(0xFFE6F1FB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF185FA5).withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 14,
                color: Color(0xFF185FA5),
              ),
              const SizedBox(width: 6),
              Text(
                'Note',
                style: const TextStyle(
                  color: Color(0xFF185FA5),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...lines.map(
            (l) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 14,
                    color: Color(0xFF185FA5),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      l,
                      style: const TextStyle(
                        color: Color(0xFF185FA5),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Submit bar ────────────────────────────────────────────────────────────────
class submitBar extends StatelessWidget {
  final bool isDark;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final RxBool isSubmitting;

  const submitBar({
    required this.isDark,
    required this.label,
    required this.color,
    required this.onTap,
    required this.isSubmitting,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        10,
        16,
        14 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: Obx(
        () => SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isSubmitting.value ? null : onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              disabledBackgroundColor: color.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: isSubmitting.value
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
