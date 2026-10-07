import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry margin;

  const AppBackButton({
    super.key,
    this.onPressed,
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: margin,
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: IconButton(
        onPressed: onPressed ?? Get.back,
        splashRadius: 20,
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 16,
          color: isDark ? Colors.white : const Color(0xFF0F172A),
        ),
      ),
    );
  }
}

class AppPageHeader extends StatelessWidget {
  final String title;
  final bool showBackButton;
  final List<Widget> actions;

  const AppPageHeader({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        if (showBackButton) ...[
          const AppBackButton(),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        ...actions,
      ],
    );
  }
}

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = Container(
      margin: margin,
      padding: padding,
      decoration: appCardDecoration(isDark),
      child: child,
    );

    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: card,
    );
  }
}

class AppAdaptiveGrid extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double minChildWidth;
  final double childAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  const AppAdaptiveGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.minChildWidth = 160,
    this.childAspectRatio = 1.5,
    this.crossAxisSpacing = 10,
    this.mainAxisSpacing = 10,
    this.physics = const NeverScrollableScrollPhysics(),
    this.shrinkWrap = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final columns = math.max(
          1,
          ((availableWidth + crossAxisSpacing) /
                  (minChildWidth + crossAxisSpacing))
              .floor(),
        );

        return GridView.builder(
          shrinkWrap: shrinkWrap,
          physics: physics,
          itemCount: itemCount,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: crossAxisSpacing,
            mainAxisSpacing: mainAxisSpacing,
            childAspectRatio: childAspectRatio,
          ),
          itemBuilder: itemBuilder,
        );
      },
    );
  }
}

class AppSearchField extends StatelessWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final Widget? suffixIcon;

  const AppSearchField({
    super.key,
    required this.hintText,
    required this.onChanged,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: _border(isDark),
        enabledBorder: _border(isDark),
        focusedBorder: _border(isDark).copyWith(
          borderSide: const BorderSide(color: Color(0xFF185FA5), width: 1.4),
        ),
      ),
    );
  }

  OutlineInputBorder _border(bool isDark) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
      ),
    );
  }
}

class AppChoiceChips extends StatelessWidget {
  final List<String> values;
  final String selected;
  final ValueChanged<String> onChanged;
  final bool filledWhenSelected;
  final EdgeInsetsGeometry padding;

  const AppChoiceChips({
    super.key,
    required this.values,
    required this.selected,
    required this.onChanged,
    this.filledWhenSelected = true,
    this.padding = const EdgeInsets.fromLTRB(16, 0, 16, 12),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedColor = filledWhenSelected
        ? const Color(0xFF185FA5)
        : isDark
        ? const Color(0xFF1A3556)
        : const Color(0xFFE6F1FB);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Row(
        children: values.map((value) {
          final active = selected == value;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              selected: active,
              selectedColor: selectedColor,
              label: Text(value),
              onSelected: (_) => onChanged(value),
              labelStyle: TextStyle(
                color: active && filledWhenSelected
                    ? Colors.white
                    : active
                    ? isDark
                          ? const Color(0xFFE6F1FB)
                          : const Color(0xFF185FA5)
                    : isDark
                    ? const Color(0xFFCBD5E1)
                    : const Color(0xFF475569),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class AppStatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const AppStatusBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class AppDetailLine extends StatelessWidget {
  final String label;
  final String value;

  const AppDetailLine({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

BoxDecoration appCardDecoration(bool isDark) => BoxDecoration(
  color: isDark ? const Color(0xFF1E293B) : Colors.white,
  borderRadius: BorderRadius.circular(8),
  border: Border.all(
    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
  ),
);
