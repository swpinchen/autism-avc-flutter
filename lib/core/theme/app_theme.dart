import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  // ── Light theme ───────────────────────────────────────────────────────────
  static ThemeData get light {
    final textTheme = _englishTextTheme(Brightness.light);
    return ThemeData(
      useMaterial3: true,
      colorScheme: _lightScheme,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primaryBlueDarker10,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        shadowColor: const Color(0x1A000000),
        titleTextStyle: textTheme.headlineMedium?.copyWith(
          fontSize: 20,
          color: AppColors.primaryBlueDarker10,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryBlueBase,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryBlueBase,
          side: const BorderSide(color: AppColors.primaryBlueBase),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryBlueBase,
        foregroundColor: Colors.white,
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: AppColors.primaryBlueLighter20,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primaryBlueDarker10);
          }
          return const IconThemeData(color: AppColors.neutralGrayDarker10);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final base = GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          );
          if (states.contains(WidgetState.selected)) {
            return base.copyWith(color: AppColors.primaryBlueDarker10);
          }
          return base.copyWith(color: AppColors.neutralGrayDarker10);
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.neutralGrayLighter10,
        thickness: 1,
      ),
    );
  }

  // ── Dark theme ────────────────────────────────────────────────────────────
  static ThemeData get dark {
    final textTheme = _englishTextTheme(Brightness.dark);
    return ThemeData(
      useMaterial3: true,
      colorScheme: _darkScheme,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        titleTextStyle: textTheme.headlineMedium?.copyWith(
          fontSize: 20,
          color: AppColors.primaryBlueLighter20,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryBlueLighter10,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryBlueLighter10,
          side: const BorderSide(color: AppColors.primaryBlueLighter10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryBlueLighter10,
        foregroundColor: Colors.white,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.neutralGrayDarker20,
        thickness: 1,
      ),
    );
  }

  // ── Japanese text theme override ──────────────────────────────────────────
  static TextTheme japaneseTextTheme(Brightness brightness) {
    final onSurface = brightness == Brightness.light
        ? AppColors.neutralGrayDarker30
        : AppColors.neutralGrayLighter30;

    return TextTheme(
      displayLarge: GoogleFonts.notoSansJp(
        fontSize: 32, fontWeight: FontWeight.w700, height: 40 / 32, color: onSurface,
      ),
      headlineLarge: GoogleFonts.notoSansJp(
        fontSize: 32, fontWeight: FontWeight.w700, height: 40 / 32, color: onSurface,
      ),
      headlineMedium: GoogleFonts.notoSansJp(
        fontSize: 24, fontWeight: FontWeight.w400, height: 32 / 24, color: onSurface,
      ),
      bodySmall: GoogleFonts.notoSansJp(
        fontSize: 14, fontWeight: FontWeight.w400, height: 24 / 14, color: onSurface,
      ),
      bodyMedium: GoogleFonts.notoSansJp(
        fontSize: 16, fontWeight: FontWeight.w400, height: 28 / 16, color: onSurface,
      ),
      bodyLarge: GoogleFonts.notoSansJp(
        fontSize: 20, fontWeight: FontWeight.w400, height: 28 / 20, color: onSurface,
      ),
      labelSmall: GoogleFonts.notoSansJp(
        fontSize: 16, fontWeight: FontWeight.w700, height: 20 / 16, color: onSurface,
      ),
      labelLarge: GoogleFonts.notoSansJp(
        fontSize: 20, fontWeight: FontWeight.w700, height: 24 / 20, color: onSurface,
      ),
      titleMedium: GoogleFonts.notoSansJp(
        fontSize: 18, fontWeight: FontWeight.w700, height: 24 / 18, color: onSurface,
      ),
      titleSmall: GoogleFonts.notoSansJp(
        fontSize: 16, fontWeight: FontWeight.w700, height: 20 / 16, color: onSurface,
      ),
    );
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  static const _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primaryBlueBase,
    onPrimary: Colors.white,
    primaryContainer: AppColors.primaryBlueLighter20,
    onPrimaryContainer: AppColors.primaryBlueDarker10,
    secondary: AppColors.blossomPinkBase,
    onSecondary: Colors.white,
    secondaryContainer: AppColors.blossomPinkLighter20,
    onSecondaryContainer: AppColors.blossomPinkDarker10,
    tertiary: AppColors.brilliantTealBase,
    onTertiary: Colors.white,
    tertiaryContainer: AppColors.brilliantTealLighter20,
    onTertiaryContainer: AppColors.brilliantTealDarker10,
    error: AppColors.brickRedBase,
    onError: Colors.white,
    errorContainer: AppColors.brickRedLighter20,
    onErrorContainer: AppColors.brickRedDarker10,
    surface: AppColors.neutralGrayLighter30,
    onSurface: AppColors.neutralGrayDarker30,
    surfaceContainerHighest: AppColors.neutralGrayLighter20,
    outline: AppColors.neutralGrayDarker10,
    outlineVariant: AppColors.neutralGrayLighter10,
  );

  static const _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primaryBlueLighter10,
    onPrimary: AppColors.primaryBlueDarker10,
    primaryContainer: AppColors.primaryBlueDarker10,
    onPrimaryContainer: AppColors.primaryBlueLighter20,
    secondary: AppColors.blossomPinkLighter10,
    onSecondary: AppColors.blossomPinkDarker10,
    secondaryContainer: AppColors.blossomPinkDarker10,
    onSecondaryContainer: AppColors.blossomPinkLighter20,
    tertiary: AppColors.brilliantTealLighter10,
    onTertiary: AppColors.brilliantTealDarker10,
    tertiaryContainer: AppColors.brilliantTealDarker10,
    onTertiaryContainer: AppColors.brilliantTealLighter20,
    error: AppColors.brickRedLighter10,
    onError: AppColors.brickRedDarker10,
    errorContainer: AppColors.brickRedDarker10,
    onErrorContainer: AppColors.brickRedLighter20,
    surface: AppColors.neutralGrayDarker30,
    onSurface: AppColors.neutralGrayLighter30,
    surfaceContainerHighest: AppColors.neutralGrayDarker20,
    outline: AppColors.neutralGrayDarker10,
    outlineVariant: AppColors.neutralGrayDarker20,
  );

  static TextTheme _englishTextTheme(Brightness brightness) {
    final onSurface = brightness == Brightness.light
        ? AppColors.neutralGrayDarker30
        : AppColors.neutralGrayLighter30;

    return TextTheme(
      // H1 — Poppins Bold 32/40
      displayLarge: GoogleFonts.poppins(
        fontSize: 32, fontWeight: FontWeight.w700, height: 40 / 32, color: onSurface,
      ),
      headlineLarge: GoogleFonts.poppins(
        fontSize: 32, fontWeight: FontWeight.w700, height: 40 / 32, color: onSurface,
      ),
      // H2 — Karla Regular 24/32
      headlineMedium: GoogleFonts.karla(
        fontSize: 24, fontWeight: FontWeight.w400, height: 32 / 24, color: onSurface,
      ),
      // Body S — Karla Regular 14/20
      bodySmall: GoogleFonts.karla(
        fontSize: 14, fontWeight: FontWeight.w400, height: 20 / 14, color: onSurface,
      ),
      // Body M — Karla Regular 16/24
      bodyMedium: GoogleFonts.karla(
        fontSize: 16, fontWeight: FontWeight.w400, height: 24 / 16, color: onSurface,
      ),
      // Body L — Karla Regular 20/28
      bodyLarge: GoogleFonts.karla(
        fontSize: 20, fontWeight: FontWeight.w400, height: 28 / 20, color: onSurface,
      ),
      // Label S — Poppins Bold 16/20
      labelSmall: GoogleFonts.poppins(
        fontSize: 16, fontWeight: FontWeight.w700, height: 20 / 16, color: onSurface,
      ),
      // Label L — Poppins Bold 20/24
      labelLarge: GoogleFonts.poppins(
        fontSize: 20, fontWeight: FontWeight.w700, height: 24 / 20, color: onSurface,
      ),
      // Card / AppBar titles — Poppins Bold
      titleMedium: GoogleFonts.poppins(
        fontSize: 18, fontWeight: FontWeight.w700, height: 24 / 18, color: onSurface,
      ),
      titleSmall: GoogleFonts.poppins(
        fontSize: 16, fontWeight: FontWeight.w700, height: 20 / 16, color: onSurface,
      ),
    );
  }
}
