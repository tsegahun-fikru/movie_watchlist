// lib/core/localization/locale_provider.dart
// VERSION 2 - Basic locale management with Riverpod.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Locale provider for language switching.
/// TODO v3: Add persistence with SharedPreferences
final localeProvider = StateProvider<Locale>((ref) {
  return const Locale('en'); // Default to English
});

/// Available locales.
class AppLocales {
  static const Locale english = Locale('en');
  static const Locale amharic = Locale('am');
  
  static const List<Locale> supported = [english, amharic];
}
