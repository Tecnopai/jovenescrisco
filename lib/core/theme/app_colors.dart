import 'package:flutter/material.dart';

/// Paleta oficial de colores para la marca Jóvenes Cristianos.
/// Unifica todos los tonos de la identidad visual para ser usados
/// por el tema (`AppTheme`) y los componentes de UI.
class AppColors {
  AppColors._();

  // =======================================================
  // COLORES PRINCIPALES DE MARCA
  // =======================================================

  /// Rojo vibrante (color principal de la marca)
  static const Color primary = Color(0xFFED1C24);

  /// Rojo oscuro / granate (color secundario)
  static const Color secondary = Color(0xFFC1272D);

  /// Rojo medio (acento)
  static const Color accent = Color(0xFFD72027);

  // =======================================================
  // COLORES DE FONDO Y SUPERFICIE
  // =======================================================

  static const Color background = Color(0xFF242424);
  static const Color surface = Color(0xFF3A3A3A);
  static const Color cardBackground = Color(0xFF515050);

  // =======================================================
  // COLORES DE TEXTO
  // =======================================================

  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textMuted = Color(0xFFF6F5F5);

  // =======================================================
  // COLORES DE ESTADO
  // =======================================================

  static const Color error = Color(0xFFED1C24);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color liveIndicator = Color(0xFFED1C24);

  // =======================================================
  // GRADIENTES
  // =======================================================

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1A1A1A), Color(0xFF000000)],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    colors: [primary, secondary],
  );

  static const LinearGradient logo = LinearGradient(
    colors: [primary, secondary],
  );

  static const RadialGradient discGradient = RadialGradient(
    colors: [primary, secondary, Colors.black],
  );

  // =======================================================
  // MÉTODOS UTILITARIOS (con withValues)
  // =======================================================

  static Color primaryWithOpacity(double opacity) =>
      primary.withValues(alpha: opacity);

  static Color surfaceWithOpacity(double opacity) =>
      surface.withValues(alpha: opacity);

  static Color getShadowColor(BuildContext context, {double opacity = 0.15}) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.shortestSide >= 600;
    return Colors.black.withValues(alpha: isTablet ? opacity * 1.2 : opacity);
  }

  static Color getOverlayColor(
    BuildContext context, {
    double baseOpacity = 0.2,
  }) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.shortestSide >= 600;
    return primary.withValues(
      alpha: isTablet ? baseOpacity * 0.8 : baseOpacity,
    );
  }

  static LinearGradient getAdaptiveButtonGradient(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.shortestSide >= 600;

    if (isTablet) {
      return LinearGradient(
        colors: [
          primary.withValues(alpha: 0.9),
          secondary.withValues(alpha: 0.9),
        ],
      );
    }
    return buttonGradient;
  }

  static Color getBorderColor(BuildContext context, {double opacity = 0.3}) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.shortestSide >= 600;
    return primary.withValues(alpha: isTablet ? opacity * 1.1 : opacity);
  }

  static Color getErrorColor(BuildContext context, {double opacity = 1.0}) =>
      error.withValues(alpha: opacity);

  static Color getSuccessColor(BuildContext context, {double opacity = 1.0}) =>
      success.withValues(alpha: opacity);

  static Color getWarningColor(BuildContext context, {double opacity = 1.0}) =>
      warning.withValues(alpha: opacity);

  static Color getAdaptiveTextColor(
    BuildContext context, {
    required Color backgroundColor,
    Color? lightText,
    Color? darkText,
  }) {
    final light = lightText ?? textPrimary;
    final dark = darkText ?? const Color(0xFF1F2937);
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? dark : light;
  }

  static Color getSurfaceColor(int elevation) {
    switch (elevation) {
      case 0:
        return surface;
      case 1:
        return Color.lerp(surface, Colors.white, 0.05)!;
      case 2:
        return Color.lerp(surface, Colors.white, 0.07)!;
      case 3:
        return Color.lerp(surface, Colors.white, 0.08)!;
      case 4:
        return Color.lerp(surface, Colors.white, 0.09)!;
      case 6:
        return Color.lerp(surface, Colors.white, 0.11)!;
      case 8:
        return Color.lerp(surface, Colors.white, 0.12)!;
      case 12:
        return Color.lerp(surface, Colors.white, 0.14)!;
      case 16:
        return Color.lerp(surface, Colors.white, 0.15)!;
      case 24:
        return Color.lerp(surface, Colors.white, 0.16)!;
      default:
        return surface;
    }
  }

  static LinearGradient getCardGradient(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.shortestSide >= 600;
    if (isTablet) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [getSurfaceColor(2), getSurfaceColor(1)],
      );
    }
    return const LinearGradient(colors: [surface, surface]);
  }

  static const List<Color> accentPalette = [
    primary,
    secondary,
    accent,
    success,
    warning,
    Color(0xFFFF4444),
  ];

  static Color getAccentColor(int index) =>
      accentPalette[index % accentPalette.length];
}
