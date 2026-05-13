// lib/core/constants/constants.dart
// VERSION 2 - App constants with configuration.

/// App constants and configuration.
/// TODO v3: Add feature flags, environment-specific configs
class Constants {
  static const String appName = 'Movie Watchlist';
  static const String appVersion = '1.0.0';
  
  // Pagination
  static const int defaultPageSize = 20;
  
  // Cache durations
  static const Duration cacheExpiration = Duration(hours: 24);
  
  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
}
