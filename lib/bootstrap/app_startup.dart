import 'package:movie_watchlist/features/notifications/data/services/notification_service.dart';
import 'package:movie_watchlist/app/router/app_router.dart';


class AppStartupController {
  AppStartupController() {}

  void initialize() {
    NotificationService.initialise(navigatorKey: rootNavigatorKey);
  }

  void dispose() {}
}
