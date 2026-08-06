import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Emerald/teal palette to match the PDF export design (spec §6) and
/// Tabiby's visual identity.
class AppColors {
  AppColors._();

  static const emerald = Color(0xFF0F9D75);
  static const teal = Color(0xFF14B8A6);
  static const emeraldDark = Color(0xFF0B6E54);
  static const background = Color(0xFFF6FAF9);
  static const surface = Color(0xFFFFFFFF);
  static const danger = Color(0xFFE0554A);

  static const gradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [emerald, teal],
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.emerald,
        primary: AppColors.emerald,
        secondary: AppColors.teal,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: GoogleFonts.cairoTextTheme(),
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: Colors.black87,
        elevation: 0,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.1)),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.emerald,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.cairo(fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.emerald,
        foregroundColor: Colors.white,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
