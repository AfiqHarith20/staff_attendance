import 'package:flutter/material.dart';

/// A small helper that constrains and centers its [child] on wide screens.
///
/// Behavior:
/// - On narrow screens (width <= [maxWidth]) it returns the [child] unchanged.
/// - On wider screens it centers the child and constrains the width to [maxWidth]
///   and adds optional [padding]. This keeps existing internal paddings intact
///   on narrow screens while providing a simple place to manage web widths.
class ResponsivePage extends StatelessWidget {
  final Widget child;

  /// The maximum width of the content area before centering is applied.
  final double maxWidth;

  /// Padding applied inside the constrained area when centered.
  final EdgeInsetsGeometry? padding;

  /// When true and the layout becomes wide, the child will be wrapped inside
  /// a subtle card (rounded white/secondary background) to make form-like
  /// screens look less stretched on web.
  final bool wrapWithCard;

  /// Inner padding to apply to the card when [wrapWithCard] is true.
  final EdgeInsetsGeometry cardPadding;

  const ResponsivePage({
    super.key,
    required this.child,
    this.maxWidth = 900,
    this.padding,
    this.wrapWithCard = false,
    this.cardPadding = const EdgeInsets.all(24),
  });

  static bool isWide(BuildContext context, {double breakpoint = 700}) {
    return MediaQuery.of(context).size.width >= breakpoint;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= maxWidth) return child;

        Widget inner = Padding(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
          child: child,
        );

        if (wrapWithCard) {
          inner = Container(
            padding: cardPadding,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF071021)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: Theme.of(context).brightness == Brightness.dark
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.03)
                    : const Color(0xFFF1F5F9),
              ),
            ),
            child: inner,
          );
        }

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: inner,
          ),
        );
      },
    );
  }
}
