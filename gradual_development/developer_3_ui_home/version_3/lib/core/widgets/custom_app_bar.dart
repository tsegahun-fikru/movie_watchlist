// lib/core/widgets/custom_app_bar.dart
// Shared AppBar used on the Home screen. Shows the app title, a notification
// bell with an unread-count badge, and a search shortcut.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_watchlist/core/theme/app_colors.dart';
import 'package:movie_watchlist/features/notifications/data/services/notification_service.dart';

/// A [PreferredSizeWidget] AppBar with a notification badge and search button.
///
/// The unread count is read synchronously from [NotificationService.unreadCount]
/// so the badge updates whenever the widget rebuilds (e.g. after a setState in
/// the parent or a navigation event).
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final unreadCount = NotificationService.unreadCount;

    return AppBar(
      backgroundColor: AppColors.background,
      title: const Text(
        'Movies',
        style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
      ),
      elevation: 0,
      actions: [
        // Notifications button with unread count badge
        Stack(
          children: [
            IconButton(
              tooltip: 'Notifications',
              icon: const Icon(Icons.notifications_none, color: AppColors.textPrimary),
              onPressed: () => context.push('/notifications'),
            ),
            if (unreadCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$unreadCount',
                    style: const TextStyle(fontSize: 10, color: AppColors.textPrimary),
                  ),
                ),
              ),
          ],
        ),
        // Search button — navigates to the dedicated search screen
        IconButton(
          tooltip: 'Search movies',
          icon: const Icon(Icons.search, color: AppColors.textPrimary),
          onPressed: () {
            context.push('/search');
          },
        ),
      ],
    );
  }
}
