// lib/l10n/app_localizations.dart
// VERSION 2 - Basic localizations (will be generated in v3).

import 'package:flutter/material.dart';

/// App localizations.
/// TODO v3: Generate with flutter gen-l10n command
abstract class AppLocalizations {
  static AppLocalizations of(BuildContext context) {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode == 'am') {
      return _AmharicLocalizations();
    }
    return _EnglishLocalizations();
  }

  String get appTitle;
  String get home;
  String get watchlist;
  String get watched;
  String get search;
  String get filter;
  String get sort;
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
  @override
  String get search => 'Search';
  @override
  String get filter => 'Filter';
  @override
  String get sort => 'Sort';
}

class _AmharicLocalizations extends AppLocalizations {
  @override
  String get appTitle => 'የፊልም ዝርዝር';
  @override
  String get home => 'መነሻ';
  @override
  String get watchlist => 'ዝርዝር';
  @override
  String get watched => 'የታዩ';
  @override
  String get search => 'ፈልግ';
  @override
  String get filter => 'አጣራ';
  @override
  String get sort => 'ደርድር';
}
