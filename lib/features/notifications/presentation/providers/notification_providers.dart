import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_watchlist/features/notifications/domain/entities/app_notification.dart';

final notificationNotifierProvider =
    StateNotifierProvider<NotificationNotifier, List<AppNotification>>((ref) {
      return NotificationNotifier();
    });

final unreadNotificationCountProvider = Provider<int>((ref) {
  return ref
      .watch(notificationNotifierProvider)
      .where((notification) => !notification.isRead)
      .length;
});

class NotificationNotifier extends StateNotifier<List<AppNotification>> {
  NotificationNotifier() : super(const <AppNotification>[]);

  void add(AppNotification notification) {
    state = <AppNotification>[notification, ...state];
  }

  void addNotification(String title, String message) {
    add(AppNotification.create(title: title, message: message));
  }

  void markAsRead(int id) {
    state = <AppNotification>[
      for (final notification in state)
        notification.id == id
            ? notification.copyWith(isRead: true)
            : notification,
    ];
  }

  void markAllAsRead() {
    state = <AppNotification>[
      for (final notification in state)
        notification.isRead
            ? notification
            : notification.copyWith(isRead: true),
    ];
  }

  void remove(int id) {
    state = <AppNotification>[
      for (final notification in state)
        if (notification.id != id) notification,
    ];
  }

  void clearAll() {
    state = const <AppNotification>[];
  }
}
