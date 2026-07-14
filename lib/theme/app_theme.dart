import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const ink = Color(0xFF1A1F1C);
  static const mist = Color(0xFFF3F6F2);
  static const leaf = Color(0xFF1F6F54);
  static const leafSoft = Color(0xFFD8ECE4);
  static const coral = Color(0xFFC45C3A);
  static const paper = Color(0xFFFAFBF8);
  static const line = Color(0xFFD5DDD7);
}

class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.leaf,
        brightness: Brightness.light,
        primary: AppColors.leaf,
        surface: AppColors.paper,
      ),
      scaffoldBackgroundColor: AppColors.mist,
    );

    return base.copyWith(
      textTheme: GoogleFonts.frauncesTextTheme(base.textTheme).copyWith(
        bodyLarge: GoogleFonts.dmSans(fontSize: 16, color: AppColors.ink),
        bodyMedium: GoogleFonts.dmSans(fontSize: 14, color: AppColors.ink),
        bodySmall: GoogleFonts.dmSans(fontSize: 12, color: AppColors.ink),
        labelLarge: GoogleFonts.dmSans(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
        titleLarge: GoogleFonts.fraunces(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
        titleMedium: GoogleFonts.fraunces(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.fraunces(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
        iconTheme: const IconThemeData(color: AppColors.ink),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.leaf,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: AppColors.line),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.paper,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.leaf, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}
