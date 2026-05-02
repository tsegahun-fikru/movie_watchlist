// lib/core/theme/app_colors.dart
// Centralised colour palette for the app's dark theme.
// All widgets must reference these constants — never hardcode colour values.

import 'package:flutter/material.dart';

class AppColors {
  // ─── Brand ────────────────────────────────────────────────────────────────
  /// Primary accent — cinematic red used for interactive elements and badges.
  static const Color primary = Color(0xFFE50914);

  // ─── Backgrounds ──────────────────────────────────────────────────────────
  /// Darkest background — used for Scaffold and AppBar backgrounds.
  static const Color background = Color(0xFF0D0D0D);

  /// Card / sheet surface — slightly lighter than [background].
  static const Color surface = Color(0xFF1A1A1A);

  /// Elevated surface — used for chips, input fills, and skeleton placeholders.
  static const Color surfaceLight = Color(0xFF242424);

  // ─── Text ─────────────────────────────────────────────────────────────────
  static const Color textPrimary = Colors.white;

  /// ~70% white — secondary body text.
  static const Color textSecondary = Color(0xB3FFFFFF);

  /// ~54% white — hints, metadata, and disabled labels.
  static const Color textTertiary = Color(0x8AFFFFFF);

  // ─── Semantic ─────────────────────────────────────────────────────────────
  /// Error / destructive action colour.
  static const Color error = Color(0xFFCF6679);

  /// Amber/yellow used for star rating icons.
  static const Color star = Color(0xFFFFD54F);

  // ─── Shimmer ──────────────────────────────────────────────────────────────
  /// Base colour for shimmer skeleton placeholders.
  static final Color shimmerBase = const Color(0xFF1A1A1A);

  /// Highlight colour that sweeps across shimmer skeletons.
  static final Color shimmerHighlight = const Color(0xFF2C2C2C);
}
