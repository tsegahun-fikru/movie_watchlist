// lib/core/widgets/custom_app_bar.dart
// VERSION 1 - Basic app bar. No search functionality yet.

import 'package:flutter/material.dart';

/// Simple app bar with logo and placeholder search icon.
/// TODO v2: Add search functionality with movie_search_delegate
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      title: Row(
        children: [
          const Icon(Icons.movie, color: Colors.red, size: 28),
          const SizedBox(width: 8),
          const Text(
            'Movie Watchlist',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () {
            // TODO v2: Show search delegate
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Search coming in v2')),
            );
          },
        ),
      ],
    );
  }
}
