// lib/screens/notifications/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:movie_watchlist/core/theme/app_colors.dart';

import 'package:movie_watchlist/features/notifications/data/services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    final notifications = NotificationService.notifications;

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
          if (notifications.isNotEmpty)
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
      body: notifications.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: AppColors.textTertiary,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Movies added to watchlist will appear here',
                    style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
                  ),
                ],
              ),
            )
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
                    child: const Icon(Icons.delete, color: AppColors.textPrimary),
                  ),
                  onDismissed: (_) {
                    setState(() {
                      NotificationService.remove(notification['id']);
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: notification['isRead']
                          ? AppColors.surface
                          : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: notification['isRead']
                            ? AppColors.surfaceLight
                            : AppColors.primary,
                        child: Icon(
                          Icons.notifications,
                          color: notification['isRead']
                              ? AppColors.textTertiary
                              : AppColors.textPrimary,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        notification['title'],
                        style: TextStyle(
                          color: notification['isRead']
                              ? AppColors.textTertiary
                              : AppColors.textPrimary,
                          fontWeight: notification['isRead']
                              ? FontWeight.normal
                              : FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        notification['message'],
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      trailing: Text(
                        _formatTime(notification['timestamp']),
                        style: const TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          NotificationService.markAsRead(notification['id']);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }

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
