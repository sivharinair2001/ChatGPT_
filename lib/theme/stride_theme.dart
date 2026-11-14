import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Visual tokens matched to Strava's mobile UI.
class StravaColors {
  static const orange = Color(0xFFFC4C02);
  static const orangeDark = Color(0xFFE34402);
  static const navy = Color(0xFF1E1E1E);
  static const text = Color(0xFF242428);
  static const muted = Color(0xFF6D6D78);
  static const hairline = Color(0xFFE6E6EB);
  static const canvas = Color(0xFFF7F7FA);
  static const white = Colors.white;
  static const mapLine = Color(0xFFFC4C02);
}

ThemeData buildStrideTheme() {
  final textTheme = GoogleFonts.latoTextTheme().apply(
    bodyColor: StravaColors.text,
    displayColor: StravaColors.text,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: StravaColors.white,
    colorScheme: const ColorScheme.light(
      primary: StravaColors.orange,
      onPrimary: Colors.white,
      secondary: StravaColors.orange,
      onSecondary: Colors.white,
      surface: StravaColors.white,
      onSurface: StravaColors.text,
      outline: StravaColors.hairline,
    ),
    textTheme: textTheme.copyWith(
      headlineLarge: textTheme.headlineLarge?.copyWith(
        fontWeight: FontWeight.w800,
        fontSize: 28,
        letterSpacing: -0.4,
        color: StravaColors.text,
      ),
      headlineMedium: textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w800,
        color: StravaColors.text,
      ),
      titleLarge: textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 18,
        color: StravaColors.text,
      ),
      titleMedium: textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: StravaColors.text,
      ),
      bodyLarge: textTheme.bodyLarge?.copyWith(
        fontSize: 15,
        color: StravaColors.text,
        height: 1.3,
      ),
      bodyMedium: textTheme.bodyMedium?.copyWith(
        fontSize: 13,
        color: StravaColors.muted,
        height: 1.3,
      ),
      labelSmall: textTheme.labelSmall?.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
        color: StravaColors.muted,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: StravaColors.white,
      foregroundColor: StravaColors.text,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      centerTitle: true,
      titleTextStyle: GoogleFonts.lato(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: StravaColors.text,
      ),
      iconTheme: const IconThemeData(color: StravaColors.text),
    ),
    dividerTheme: const DividerThemeData(
      color: StravaColors.hairline,
      thickness: 1,
      space: 1,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: StravaColors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: const StadiumBorder(),
        textStyle: GoogleFonts.lato(
          fontWeight: FontWeight.w800,
          fontSize: 16,
          letterSpacing: 0.3,
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: StravaColors.white,
      selectedColor: StravaColors.orange.withOpacity(0.12),
      side: const BorderSide(color: StravaColors.hairline),
      labelStyle: GoogleFonts.lato(
        fontWeight: FontWeight.w700,
        color: StravaColors.text,
      ),
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    ),
  );
}

// Back-compat aliases used by older widgets during migration.
typedef StrideColors = StravaColors;
