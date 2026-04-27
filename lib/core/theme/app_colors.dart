import 'package:flutter/material.dart';

class AppColors {
  // Primary accent – indigo/blue-purple from the design image
  static const Color primary = Color(0xFF5B6CF0);

  // Backgrounds
  static const Color background = Color(0xFF0D1117);
  static const Color surface = Color(0xFF161B2E);
  static const Color surfaceLight = Color(0xFF1E2436);

  // Text
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xB3FFFFFF); // ~70%
  static const Color textTertiary = Color(0x8AFFFFFF); // ~54%

  // Semantic
  static const Color error = Color(0xFFCF6679);
  static const Color star = Color(0xFFFFD54F); // amber/yellow for ratings

  // Shimmer
  static final Color shimmerBase = const Color(0xFF1E2436);
  static final Color shimmerHighlight = const Color(0xFF2A3150);
}
