import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors - PrintCraft AI
  // Primary - Electric Purple/Violet gradient inspired
  static const Color primaryLight = Color(0xFF6B46C1);
  static const Color primaryDark = Color(0xFF9F7AEA);
  
  // Secondary - Coral/Orange for energy and creativity
  static const Color secondaryLight = Color(0xFFFF6B6B);
  static const Color secondaryDark = Color(0xFFFC8181);
  
  // Accent - Teal for contrast and freshness
  static const Color accentLight = Color(0xFF38B2AC);
  static const Color accentDark = Color(0xFF4FD1C5);
  
  // Background Colors
  static const Color backgroundLight = Color(0xFFFAFBFC);
  static const Color backgroundDark = Color(0xFF0F0F14);
  
  // Surface Colors
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1A1A24);
  
  // Text Colors
  static const Color textPrimaryLight = Color(0xFF1A202C);
  static const Color textPrimaryDark = Color(0xFFE2E8F0);
  
  static const Color textSecondaryLight = Color(0xFF718096);
  static const Color textSecondaryDark = Color(0xFFA0AEC0);
  
  // Border Colors
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF2D3748);
  
  // Error Colors
  static const Color error = Color(0xFFE53E3E);
  static const Color errorDark = Color(0xFFFC8181);
  
  // Success Colors
  static const Color success = Color(0xFF48BB78);
  static const Color successDark = Color(0xFF68D391);
  
  // Warning Colors
  static const Color warning = Color(0xFFED8936);
  static const Color warningDark = Color(0xFFF6AD55);
  
  // Info Colors
  static const Color info = Color(0xFF4299E1);
  static const Color infoDark = Color(0xFF63B3ED);
  
  // Chip/Tag Background
  static const Color chipBackgroundLight = Color(0xFFF7FAFC);
  static const Color chipBackgroundDark = Color(0xFF2A2A3A);
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF6B46C1),
      Color(0xFF553C9A),
    ],
  );
  
  static const LinearGradient primaryGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF9F7AEA),
      Color(0xFFB794F4),
    ],
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF6B6B),
      Color(0xFFFC8181),
    ],
  );
  
  static const LinearGradient shimmerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE2E8F0),
      Color(0xFFF7FAFC),
      Color(0xFFE2E8F0),
    ],
  );
  
  static const LinearGradient shimmerGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2D3748),
      Color(0xFF4A5568),
      Color(0xFF2D3748),
    ],
  );
  
  // Overlay Colors
  static Color overlayLight = Colors.black.withOpacity(0.5);
  static Color overlayDark = Colors.black.withOpacity(0.7);
  
  // Shadow Colors
  static Color shadowLight = Colors.black.withOpacity(0.1);
  static Color shadowDark = Colors.black.withOpacity(0.3);
  
  // Generation Counter Colors
  static const Color freeGenerationColor = Color(0xFF48BB78);
  static const Color premiumGenerationColor = Color(0xFFECC94B);
  
  // Pro Badge Colors
  static const LinearGradient proBadgeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFD700),
      Color(0xFFFFA500),
    ],
  );
}
