// lib/bootstrap/app_startup.dart
// Handles one-time app initialisation tasks that must run before the UI is
// fully interactive (currently: Firebase Cloud Messaging setup).

import 'package:movie_watchlist/features/notifications/data/services/notification_service.dart';
import 'package:movie_watchlist/app/router/app_router.dart';

/// Coordinates startup tasks that should run once when the app launches.
///
/// Call [initialize] from [MyApp.initState] and [dispose] from
/// [MyApp.dispose] to properly manage any resources.
class AppStartupController {
  AppStartupController();

  /// Initialises Firebase Messaging and registers notification handlers.
  /// Uses [rootNavigatorKey] so that notification taps can trigger navigation.
  void initialize() {
    NotificationService.initialise(navigatorKey: rootNavigatorKey);
  }

  void dispose() {}
}
