import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      // Mantiene tu estructura original
      primarySwatch: const MaterialColor(0xFFFF0000, {
        50: Color(0xFFFFE5E5),
        100: Color(0xFFFFB3B3),
        200: Color(0xFFFF8080),
        300: Color(0xFFFF4D4D),
        400: Color(0xFFFF2626),
        500: Color(0xFFFF0000),
        600: Color(0xFFE00000),
        700: Color(0xFFB5121B),
        800: Color(0xFF990F17),
        900: Color(0xFF7A0C13),
      }),
      scaffoldBackgroundColor: AppColors.background,
      useMaterial3: true,

      // Tipografía Montserrat (mantiene TextTheme actual)
      textTheme: GoogleFonts.montserratTextTheme(_buildResponsiveTextTheme()),

      appBarTheme: _buildResponsiveAppBarTheme(),
      bottomNavigationBarTheme: _buildResponsiveBottomNavTheme(),
      elevatedButtonTheme: _buildResponsiveElevatedButtonTheme(),
      cardTheme: _buildResponsiveCardTheme(),
      sliderTheme: _buildResponsiveSliderTheme(),
      iconTheme: _buildResponsiveIconTheme(),
    );
  }

  // ---- Mantiene todos tus métodos originales, solo con los colores actualizados ----

  static AppBarTheme _buildResponsiveAppBarTheme() {
    return const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  static BottomNavigationBarThemeData _buildResponsiveBottomNavTheme() {
    return const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
    );
  }

  static ElevatedButtonThemeData _buildResponsiveElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(AppColors.primary),
        foregroundColor: WidgetStateProperty.all(Colors.white),
        elevation: WidgetStateProperty.resolveWith<double>(
          (states) => states.contains(WidgetState.pressed) ? 2 : 4,
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        textStyle: WidgetStateProperty.all(
          GoogleFonts.montserrat(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  static TextTheme _buildResponsiveTextTheme() {
    return const TextTheme(
      headlineLarge: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      titleSmall: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: AppColors.textSecondary),
      bodySmall: TextStyle(color: AppColors.textMuted),
      labelLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      labelMedium: TextStyle(color: AppColors.textSecondary),
      labelSmall: TextStyle(color: AppColors.textSecondary),
    );
  }

  static CardThemeData _buildResponsiveCardTheme() {
    return CardThemeData(
      color: AppColors.surface,
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
    );
  }

  static SliderThemeData _buildResponsiveSliderTheme() {
    return SliderThemeData(
      activeTrackColor: AppColors.primary,
      inactiveTrackColor: AppColors.textSecondary.withValues(alpha: 0.3),
      thumbColor: AppColors.primary,
      overlayColor: AppColors.primary.withValues(alpha: 0.2),
      valueIndicatorColor: AppColors.primary,
      valueIndicatorTextStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  static IconThemeData _buildResponsiveIconTheme() =>
      const IconThemeData(color: Colors.white);
}
