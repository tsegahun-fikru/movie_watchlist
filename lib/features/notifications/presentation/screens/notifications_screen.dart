// lib/features/notifications/presentation/screens/notifications_screen.dart
// Displays the in-memory notification list with All / Unread filter tabs.
// Notifications can be dismissed by swiping, marked as read by tapping,
// or cleared in bulk.

import 'package:flutter/material.dart';
import 'package:movie_watchlist/core/theme/app_colors.dart';
import 'package:movie_watchlist/features/notifications/data/services/notification_service.dart';

enum _NotifFilter { all, unread }

/// Notification list screen with All / Unread filter tabs.
///
/// Reads from [NotificationService.notifications] (in-memory list).
/// Swipe-to-dismiss removes individual notifications; tapping marks them read.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  _NotifFilter _filter = _NotifFilter.all;

  @override
  Widget build(BuildContext context) {
    final allNotifications = NotificationService.notifications;
    final notifications = _filter == _NotifFilter.unread
        ? allNotifications.where((n) => n['isRead'] == false).toList()
        : allNotifications;
    final unreadCount =
        allNotifications.where((n) => n['isRead'] == false).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () {
                setState(() {
                  for (final n in allNotifications) {
                    NotificationService.markAsRead(n['id'] as int);
                  }
                });
              },
              child: const Text(
                'Mark all read',
                style: TextStyle(color: AppColors.primary, fontSize: 12),
              ),
            ),
          if (allNotifications.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  NotificationService.clearAll();
                });
              },
              child: const Text(
                'Clear All',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // ── Filter tabs ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  _FilterTab(
                    label: 'All',
                    selected: _filter == _NotifFilter.all,
                    onTap: () => setState(() => _filter = _NotifFilter.all),
                  ),
                  _FilterTab(
                    label: 'Unread${unreadCount > 0 ? ' ($unreadCount)' : ''}',
                    selected: _filter == _NotifFilter.unread,
                    onTap: () => setState(() => _filter = _NotifFilter.unread),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ── List or empty state ──
          Expanded(
            child: notifications.isEmpty
                ? _EmptyState(isFiltered: _filter == _NotifFilter.unread)
                : ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return Dismissible(
                        key: Key(notification['id'].toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: AppColors.error,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete,
                              color: AppColors.textPrimary),
                        ),
                        onDismissed: (_) {
                          setState(() {
                            NotificationService.remove(
                                notification['id'] as int);
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: notification['isRead'] as bool
                                ? AppColors.surface
                                : AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: notification['isRead'] as bool
                                  ? AppColors.surfaceLight
                                  : AppColors.primary,
                              child: Icon(
                                Icons.notifications,
                                color: notification['isRead'] as bool
                                    ? AppColors.textTertiary
                                    : AppColors.textPrimary,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              notification['title'] as String,
                              style: TextStyle(
                                color: notification['isRead'] as bool
                                    ? AppColors.textTertiary
                                    : AppColors.textPrimary,
                                fontWeight: notification['isRead'] as bool
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              notification['message'] as String,
                              style: const TextStyle(
                                  color: AppColors.textSecondary),
                            ),
                            trailing: Text(
                              _formatTime(
                                  notification['timestamp'] as DateTime),
                              style: const TextStyle(
                                color: AppColors.textTertiary,
                                fontSize: 12,
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                NotificationService.markAsRead(
                                    notification['id'] as int);
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Formats a [timestamp] as a human-readable relative time string.
  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              color: selected ? Colors.white : AppColors.textTertiary,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isFiltered;
  const _EmptyState({required this.isFiltered});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_off_outlined,
                size: 48,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isFiltered ? 'No unread notifications' : 'No notifications yet',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isFiltered
                  ? 'You\'re all caught up!'
                  : 'Movies added to your watchlist will appear here.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
