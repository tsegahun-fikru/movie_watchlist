// lib/core/localization/locale_provider.dart
// Riverpod provider that persists the user's selected locale across sessions
// using SharedPreferences. Supported locales: 'en' (English) and 'am' (Amharic).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Exposes the current [Locale] and allows it to be changed at runtime.
/// The selected locale is persisted so it survives app restarts.
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

/// [StateNotifier] that manages the app locale.
///
/// Initialises to English and then loads the persisted value asynchronously.
/// Call [setLocale] to change the locale and persist the new value.
class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en')) {
    _loadLocale();
  }

  static const _key = 'selected_locale';

  /// Loads the previously saved locale from [SharedPreferences].
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_key);
    if (languageCode != null) {
      state = Locale(languageCode);
    }
  }

  /// Updates the current locale and persists it for future sessions.
  Future<void> setLocale(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, locale.languageCode);
  }
}
