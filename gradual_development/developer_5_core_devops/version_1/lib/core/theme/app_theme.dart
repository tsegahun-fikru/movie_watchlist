// lib/core/theme/app_theme.dart
// VERSION 1 - Basic dark theme.

import 'package:flutter/material.dart';
import 'package:movie_watchlist/core/theme/app_colors.dart';

/// Simple dark theme for the app.
/// TODO v2: Add custom component themes, typography
class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
    );
  }
}
