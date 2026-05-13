// lib/l10n/app_localizations.dart
// VERSION 1 - Placeholder for generated localizations.

import 'package:flutter/material.dart';

/// Placeholder for app localizations.
/// TODO v2: Generate with flutter gen-l10n
abstract class AppLocalizations {
  static AppLocalizations of(BuildContext context) {
    return _EnglishLocalizations();
  }

  String get appTitle;
  String get home;
  String get watchlist;
  String get watched;
}

class _EnglishLocalizations extends AppLocalizations {
  @override
  String get appTitle => 'Movie Watchlist';
  @override
  String get home => 'Home';
  @override
  String get watchlist => 'Watchlist';
  @override
  String get watched => 'Watched';
}
