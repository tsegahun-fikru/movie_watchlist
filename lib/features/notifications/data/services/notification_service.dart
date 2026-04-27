// lib/features/notifications/data/services/notification_service.dart

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final List<Map<String, dynamic>> _notifications = [];

  static List<Map<String, dynamic>> get notifications =>
      List.from(_notifications);

  static int get unreadCount =>
      _notifications.where((n) => n['isRead'] == false).length;

  // ── Firebase Messaging instance ──
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Initialise FCM, request permissions, and set up message handlers.
  /// Call once, preferably in main() after Firebase.initializeApp().
  static Future<void> initialise({
    required GlobalKey<NavigatorState> navigatorKey,
  }) async {
    // 1. Request permission (iOS will show system dialog)
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

    // 2. Get the device token (send to your server if needed)
    final token = await _messaging.getToken();
    debugPrint('FCM Token: $token');

    // 3. Foreground messages – show them inside the app
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 4. Background/terminated tap – navigate when user opens a notification
    FirebaseMessaging.onMessageOpenedApp.listen(
      (msg) => _handleNotificationTap(msg, navigatorKey),
    );

    // 5. Check if app was opened from a terminated state
    final initialMsg = await _messaging.getInitialMessage();
    if (initialMsg != null) {
      _handleNotificationTap(initialMsg, navigatorKey);
    }
  }

  /// Called when a message arrives while the app is in the foreground.
  static void _handleForegroundMessage(RemoteMessage message) {
    final title = message.notification?.title ?? 'New notification';
    final body = message.notification?.body ?? '';
    addNotification(title, body);
  }

  /// Handle the user tapping a notification (app in background or terminated).
  static void _handleNotificationTap(
    RemoteMessage message,
    GlobalKey<NavigatorState> navigatorKey,
  ) {
    // Store the notification locally so it appears in the list
    final title = message.notification?.title ?? '';
    final body = message.notification?.body ?? '';
    addNotification(title, body);

    // Navigate based on payload data (e.g., navigate to movie details)
    final movieId = message.data['movie_id'];
    if (movieId != null) {
      final id = int.tryParse(movieId);
      if (id != null) {
        navigatorKey.currentState?.pushNamed('/movie_by_id', arguments: id);
      }
    } else {
      // Fallback: go to the notifications screen
      navigatorKey.currentState?.pushNamed('/notifications');
    }
  }

  // ── Local storage helpers (unchanged) ──
  static void addNotification(String title, String message) {
    _notifications.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch,
      'title': title,
      'message': message,
      'timestamp': DateTime.now(),
      'isRead': false,
    });
  }

  static void markAsRead(int id) {
    final index = _notifications.indexWhere((n) => n['id'] == id);
    if (index != -1) {
      _notifications[index]['isRead'] = true;
    }
  }

  static void remove(int id) {
    _notifications.removeWhere((n) => n['id'] == id);
  }

  static void clearAll() {
    _notifications.clear();
  }
}
