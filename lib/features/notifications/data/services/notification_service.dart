// lib/features/notifications/data/services/notification_service.dart
// Manages Firebase Cloud Messaging setup and forwards push messages into the
// app's reactive notification state.

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_watchlist/features/notifications/domain/entities/app_notification.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static void Function(AppNotification notification)? _onNotificationReceived;

  /// Initialises FCM, requests permissions, and registers message handlers.
  ///
  /// Should be called once during app startup (from [AppStartupController]).
  /// [navigatorKey] is used to navigate when the user taps a push notification.
  static Future<void> initialise({
    required GlobalKey<NavigatorState> navigatorKey,
    required void Function(AppNotification notification) onNotificationReceived,
  }) async {
    _onNotificationReceived = onNotificationReceived;

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

    final token = await _messaging.getToken();
    debugPrint('FCM Token: $token');

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) => _handleNotificationTap(message, navigatorKey),
    );

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage, navigatorKey);
    }
  }

  static void _handleForegroundMessage(RemoteMessage message) {
    final title = message.notification?.title ?? 'New notification';
    final body = message.notification?.body ?? '';
    _emitNotification(title, body);
  }

  static void _handleNotificationTap(
    RemoteMessage message,
    GlobalKey<NavigatorState> navigatorKey,
  ) {
    final title = message.notification?.title ?? 'New notification';
    final body = message.notification?.body ?? '';
    _emitNotification(title, body);

    final context = navigatorKey.currentContext;
    if (context == null) return;

    final movieId = message.data['movie_id'];
    final id = movieId == null ? null : int.tryParse(movieId);
    if (id != null) {
      context.push('/movie/$id');
      return;
    }

    context.push('/notifications');
  }

  static void _emitNotification(String title, String message) {
    _onNotificationReceived?.call(
      AppNotification.create(title: title, message: message),
    );
  }
}
