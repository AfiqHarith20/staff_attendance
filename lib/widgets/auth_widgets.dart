import 'package:flutter/material.dart';

class FieldLabel extends StatelessWidget {
  final String label;
  final Color color;
  const FieldLabel({required this.label, required this.color, Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        color: color,
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.08,
      ),
    );
  }
}

class RolePill extends StatelessWidget {
  final String label;
  final bool active;
  final bool isDark;
  final VoidCallback? onTap;

  const RolePill({
    required this.label,
    required this.active,
    required this.isDark,
    this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active
              ? const Color(0xFF185FA5)
              : isDark
              ? const Color(0xFF1E293B)
              : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active
                ? const Color(0xFF185FA5)
                : isDark
                ? const Color(0xFF334155)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: active
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
