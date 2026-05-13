// lib/core/widgets/custom_app_bar.dart
// VERSION 2 - Adds search delegate functionality.

import 'package:flutter/material.dart';
import 'package:movie_watchlist/features/home/presentation/widgets/movie_search_delegate.dart';

/// App bar with logo and functional search.
/// TODO v3: Add notification icon, profile menu
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
            showSearch(
              context: context,
              delegate: MovieSearchDelegate(),
            );
          },
        ),
      ],
    );
  }
}
