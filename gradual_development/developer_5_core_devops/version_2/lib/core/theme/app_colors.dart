// lib/core/theme/app_colors.dart
// VERSION 2 - Expanded color palette with semantic colors.

import 'package:flutter/material.dart';

/// App color palette.
/// TODO v3: Add color schemes for light/dark modes
class AppColors {
  // Background colors
  static const Color background = Color(0xFF000000);
  static const Color surface = Color(0xFF1C1C1E);
  static const Color surfaceLight = Color(0xFF2C2C2E);
  
  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFAAAAAA);
  static const Color textTertiary = Color(0xFF666666);
  
  // Accent colors
  static const Color primary = Color(0xFFE50914); // Netflix red
  static const Color star = Color(0xFFFFC107); // Amber
  static const Color error = Color(0xFFCF6679);
  
  // Additional colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
}
