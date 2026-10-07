import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class AppTheme {
  static const _primary = Color(0xFF185FA5);
  static const _accent = Color(0xFF378ADD);
  static const _lightBg = Color(0xFFF8FAFC);
  static const _darkBg = Color(0xFF0F172A);
  static const _darkSurface = Color(0xFF1E293B);
  static const _darkSurfaceAlt = Color(0xFF111827);
  static const _darkBorder = Color(0xFF334155);
  static const _darkTextMuted = Color(0xFF94A3B8);

  static ThemeData get light => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: _lightBg,
    primaryColor: _primary,
    colorScheme: ColorScheme.light(
      primary: _primary,
      secondary: _accent,
      surface: Colors.white,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(),
    appBarTheme: const AppBarTheme(
      backgroundColor: _lightBg,
      foregroundColor: Color(0xFF0F172A),
      elevation: 0,
      centerTitle: false,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: _primary,
      unselectedItemColor: Color(0xFF64748B),
      type: BottomNavigationBarType.fixed,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: _SmoothPageTransitionsBuilder(),
        TargetPlatform.iOS: _SmoothPageTransitionsBuilder(),
        TargetPlatform.macOS: _SmoothPageTransitionsBuilder(),
        TargetPlatform.windows: _SmoothPageTransitionsBuilder(),
        TargetPlatform.linux: _SmoothPageTransitionsBuilder(),
      },
    ),
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: Colors.white,
      selectedIconTheme: IconThemeData(color: _primary),
      unselectedIconTheme: IconThemeData(color: Color(0xFF64748B)),
      selectedLabelTextStyle: TextStyle(
        color: _primary,
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelTextStyle: TextStyle(color: Color(0xFF64748B)),
    ),
    dividerTheme: const DividerThemeData(color: Color(0xFFE2E8F0)),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      modalBackgroundColor: Colors.white,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF0F172A),
      contentTextStyle: GoogleFonts.poppins(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white,
      selectedColor: _primary,
      disabledColor: const Color(0xFFF1F5F9),
      side: const BorderSide(color: Color(0xFFE2E8F0)),
      labelStyle: GoogleFonts.poppins(color: const Color(0xFF475569)),
      secondaryLabelStyle: GoogleFonts.poppins(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDC2626)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
      ),
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
    ),
  );

  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: _darkBg,
    primaryColor: _primary,
    colorScheme: ColorScheme.dark(
      primary: _primary,
      secondary: _accent,
      surface: _darkSurface,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(
      ThemeData(brightness: Brightness.dark).textTheme,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: _darkBg,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _darkSurface,
      selectedItemColor: _accent,
      unselectedItemColor: _darkTextMuted,
      type: BottomNavigationBarType.fixed,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: _SmoothPageTransitionsBuilder(),
        TargetPlatform.iOS: _SmoothPageTransitionsBuilder(),
        TargetPlatform.macOS: _SmoothPageTransitionsBuilder(),
        TargetPlatform.windows: _SmoothPageTransitionsBuilder(),
        TargetPlatform.linux: _SmoothPageTransitionsBuilder(),
      },
    ),
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: _darkSurface,
      selectedIconTheme: IconThemeData(color: _accent),
      unselectedIconTheme: IconThemeData(color: _darkTextMuted),
      selectedLabelTextStyle: TextStyle(
        color: _accent,
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelTextStyle: TextStyle(color: _darkTextMuted),
    ),
    dividerTheme: const DividerThemeData(color: _darkBorder),
    dialogTheme: DialogThemeData(
      backgroundColor: _darkSurface,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
      contentTextStyle: GoogleFonts.poppins(color: _darkTextMuted),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: _darkSurface,
      surfaceTintColor: Colors.transparent,
      modalBackgroundColor: _darkSurface,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: _darkSurfaceAlt,
      contentTextStyle: GoogleFonts.poppins(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: _darkSurface,
      selectedColor: _accent,
      disabledColor: _darkSurfaceAlt,
      side: const BorderSide(color: _darkBorder),
      labelStyle: GoogleFonts.poppins(color: const Color(0xFFCBD5E1)),
      secondaryLabelStyle: GoogleFonts.poppins(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected) ? _accent : _darkTextMuted;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected)
            ? _accent.withValues(alpha: 0.35)
            : _darkBorder;
      }),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _darkSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _accent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFF87171)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFF87171), width: 1.5),
      ),
      hintStyle: const TextStyle(color: _darkTextMuted, fontSize: 14),
    ),
  );
}

class _SmoothPageTransitionsBuilder extends PageTransitionsBuilder {
  const _SmoothPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    final offset = Tween<Offset>(
      begin: const Offset(0.045, 0.0),
      end: Offset.zero,
    ).animate(curved);

    return FadeTransition(
      opacity: curved,
      child: SlideTransition(position: offset, child: child),
    );
  }
}
