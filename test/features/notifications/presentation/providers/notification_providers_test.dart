import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_watchlist/features/notifications/domain/entities/app_notification.dart';
import 'package:movie_watchlist/features/notifications/presentation/providers/notification_providers.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  test('adds notifications most recent first', () {
    final notifier = container.read(notificationNotifierProvider.notifier);
    final first = AppNotification.create(
      title: 'First',
      message: 'Message',
      timestamp: DateTime(2026),
    );
    final second = AppNotification.create(
      title: 'Second',
      message: 'Message',
      timestamp: DateTime(2026, 1, 2),
    );

    notifier.add(first);
    notifier.add(second);

    final notifications = container.read(notificationNotifierProvider);
    expect(notifications.map((notification) => notification.title), <String>[
      'Second',
      'First',
    ]);
  });

  test('marks a notification as read and updates unread count', () {
    final notifier = container.read(notificationNotifierProvider.notifier);
    final notification = AppNotification.create(
      title: 'Title',
      message: 'Message',
    );

    notifier.add(notification);
    expect(container.read(unreadNotificationCountProvider), 1);

    notifier.markAsRead(notification.id);

    expect(container.read(notificationNotifierProvider).single.isRead, isTrue);
    expect(container.read(unreadNotificationCountProvider), 0);
  });

  test('marks all notifications as read', () {
    final notifier = container.read(notificationNotifierProvider.notifier);

    notifier.addNotification('First', 'Message');
    notifier.addNotification('Second', 'Message');
    notifier.markAllAsRead();

    expect(
      container
          .read(notificationNotifierProvider)
          .every((notification) => notification.isRead),
      isTrue,
    );
    expect(container.read(unreadNotificationCountProvider), 0);
  });

  test('removes and clears notifications', () {
    final notifier = container.read(notificationNotifierProvider.notifier);
    final first = AppNotification.create(title: 'First', message: 'Message');
    final second = AppNotification.create(title: 'Second', message: 'Message');

    notifier.add(first);
    notifier.add(second);
    notifier.remove(first.id);

    expect(container.read(notificationNotifierProvider), <AppNotification>[
      second,
    ]);

    notifier.clearAll();

    expect(container.read(notificationNotifierProvider), isEmpty);
  });
}
