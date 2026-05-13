// lib/features/watched/presentation/widgets/user_rating_bar.dart
// VERSION 1 - Placeholder for user rating widget.

import 'package:flutter/material.dart';

/// Placeholder for user rating bar widget.
/// TODO v2: Implement 1-5 star rating system
class UserRatingBar extends StatelessWidget {
  final dynamic item; // Movie or TvShow

  const UserRatingBar({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Text(
        'Rating feature coming in v2',
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      ),
    );
  }
}
