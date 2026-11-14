import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StrideColors {
  static const spruce = Color(0xFF1B3A2F);
  static const moss = Color(0xFF2F6B4F);
  static const mist = Color(0xFFE7EEE8);
  static const fog = Color(0xFFD5E0D7);
  static const ink = Color(0xFF14201A);
  static const ember = Color(0xFFE85D04);
  static const stone = Color(0xFF5C6B62);
}

ThemeData buildStrideTheme() {
  final display = GoogleFonts.frauncesTextTheme();
  final body = GoogleFonts.dmSansTextTheme();

  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: StrideColors.spruce,
      onPrimary: Colors.white,
      secondary: StrideColors.ember,
      onSecondary: Colors.white,
      surface: StrideColors.mist,
      onSurface: StrideColors.ink,
      surfaceContainerHighest: StrideColors.fog,
    ),
    scaffoldBackgroundColor: StrideColors.mist,
  );

  return base.copyWith(
    textTheme: body.copyWith(
      displayLarge: display.displayLarge?.copyWith(
        color: StrideColors.ink,
        fontWeight: FontWeight.w600,
        letterSpacing: -1.2,
      ),
      displayMedium: display.displayMedium?.copyWith(
        color: StrideColors.ink,
        fontWeight: FontWeight.w600,
      ),
      headlineLarge: display.headlineLarge?.copyWith(
        color: StrideColors.ink,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.6,
      ),
      headlineMedium: display.headlineMedium?.copyWith(
        color: StrideColors.ink,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: display.headlineSmall?.copyWith(
        color: StrideColors.ink,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: body.titleLarge?.copyWith(
        color: StrideColors.ink,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: body.bodyLarge?.copyWith(color: StrideColors.ink, height: 1.35),
      bodyMedium:
          body.bodyMedium?.copyWith(color: StrideColors.stone, height: 1.4),
      labelLarge: body.labelLarge?.copyWith(
        color: StrideColors.ink,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: StrideColors.mist,
      foregroundColor: StrideColors.ink,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.fraunces(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: StrideColors.ink,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white.withOpacity(0.92),
      indicatorColor: StrideColors.fog,
      labelTextStyle: WidgetStatePropertyAll(
        GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: StrideColors.ember,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 16),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: StrideColors.ember,
      foregroundColor: Colors.white,
    ),
  );
}
