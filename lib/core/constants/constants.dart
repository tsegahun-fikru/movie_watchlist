// lib/core/constants/constants.dart
// App-wide compile-time constants for layout dimensions, asset paths, and
// placeholder strings. Centralising them here avoids magic numbers/strings
// scattered across the codebase.

class Constants {
  // ─── Layout ───────────────────────────────────────────────────────────────
  static const double heroHeight = 400.0;
  static const double movieCardWidth = 100.0;
  static const double movieCardHeight = 140.0;

  // ─── Assets ───────────────────────────────────────────────────────────────
  static const String splashPersonAsset = 'assets/images/person.png';

  // ─── Strings ──────────────────────────────────────────────────────────────
  static const String appTitle = 'Movie Watchlist';
  static const String heroTag = 'heroImage';

  static const String aboutText = 'Movie Watchlist app built with Flutter.';
  static const String profileText = 'User profile details go here.';
  static const String watchlistEmptyText = 'Your saved movies appear here.';

  // ─── Timing ───────────────────────────────────────────────────────────────
  /// Minimum number of seconds the splash screen is displayed.
  static const int splashDelaySeconds = 3;
}
