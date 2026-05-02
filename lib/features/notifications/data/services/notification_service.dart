// lib/features/notifications/data/services/notification_service.dart
// Manages Firebase Cloud Messaging setup and an in-memory list of local
// notifications (watchlist/watched actions + push messages).

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

/// Handles FCM initialisation and maintains an in-memory notification list.
///
/// Local notifications (e.g. "Added to Watchlist") are added via
/// [addNotification] and displayed in [NotificationsScreen].
/// Push notifications from FCM are also funnelled through [addNotification]
/// so they appear in the same list.
class NotificationService {
  /// In-memory list of notifications (most recent first).
  static final List<Map<String, dynamic>> _notifications = [];

  /// Returns a copy of the current notification list.
  static List<Map<String, dynamic>> get notifications =>
      List.from(_notifications);

  /// Returns the number of unread notifications.
  static int get unreadCount =>
      _notifications.where((n) => n['isRead'] == false).length;

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Initialises FCM, requests permissions, and registers message handlers.
  ///
  /// Should be called once during app startup (from [AppStartupController]).
  /// [navigatorKey] is used to navigate when the user taps a push notification.
  static Future<void> initialise({
    required GlobalKey<NavigatorState> navigatorKey,
  }) async {
    // 1. Request permission (iOS will show a system dialog)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('FCM permission granted');
    } else {
      debugPrint('FCM permission denied');
    }

    // 2. Log the device token (send to your server if needed for targeting)
    final token = await _messaging.getToken();
    debugPrint('FCM Token: $token');

    // 3. Handle messages that arrive while the app is in the foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 4. Handle notification taps when the app is in the background
    FirebaseMessaging.onMessageOpenedApp.listen(
      (msg) => _handleNotificationTap(msg, navigatorKey),
    );

    // 5. Handle notification taps when the app was terminated
    final initialMsg = await _messaging.getInitialMessage();
    if (initialMsg != null) {
      _handleNotificationTap(initialMsg, navigatorKey);
    }
  }

  /// Called when a push message arrives while the app is in the foreground.
  static void _handleForegroundMessage(RemoteMessage message) {
    final title = message.notification?.title ?? 'New notification';
    final body = message.notification?.body ?? '';
    addNotification(title, body);
  }

  /// Handles the user tapping a notification (app in background or terminated).
  ///
  /// Stores the notification locally and navigates to the relevant screen
  /// based on the message's `data` payload.
  static void _handleNotificationTap(
    RemoteMessage message,
    GlobalKey<NavigatorState> navigatorKey,
  ) {
    final title = message.notification?.title ?? '';
    final body = message.notification?.body ?? '';
    addNotification(title, body);

    // Navigate to a specific movie if the payload contains a movie_id
    final movieId = message.data['movie_id'];
    if (movieId != null) {
      final id = int.tryParse(movieId);
      if (id != null) {
        navigatorKey.currentState?.pushNamed('/movie_by_id', arguments: id);
      }
    } else {
      // Fallback: open the notifications screen
      navigatorKey.currentState?.pushNamed('/notifications');
    }
  }

  // ─── Local notification helpers ───────────────────────────────────────────

  /// Adds a new unread notification to the top of the list.
  static void addNotification(String title, String message) {
    _notifications.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch,
      'title': title,
      'message': message,
      'timestamp': DateTime.now(),
      'isRead': false,
    });
  }

  /// Marks the notification with [id] as read.
  static void markAsRead(int id) {
    final index = _notifications.indexWhere((n) => n['id'] == id);
    if (index != -1) {
      _notifications[index]['isRead'] = true;
    }
  }

  /// Removes the notification with [id] from the list.
  static void remove(int id) {
    _notifications.removeWhere((n) => n['id'] == id);
  }

  /// Clears all notifications.
  static void clearAll() {
    _notifications.clear();
  }
}
