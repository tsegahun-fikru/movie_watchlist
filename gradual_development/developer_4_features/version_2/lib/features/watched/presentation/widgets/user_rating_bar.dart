// lib/features/watched/presentation/widgets/user_rating_bar.dart
// VERSION 2 - Simple 1-5 star rating widget with Firestore.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_watchlist/features/watched/presentation/providers/watched_providers.dart';

/// User rating bar widget (1-5 stars) with Firestore persistence.
/// TODO v3: Add half-star support, rating distribution
class UserRatingBar extends ConsumerStatefulWidget {
  final dynamic item; // Movie or TvShow

  const UserRatingBar({
    super.key,
    required this.item,
  });

  @override
  ConsumerState<UserRatingBar> createState() => _UserRatingBarState();
}

class _UserRatingBarState extends ConsumerState<UserRatingBar> {
  int? _currentRating;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRating();
  }

  Future<void> _loadRating() async {
    final service = ref.read(watchedServiceProvider);
    if (service != null) {
      final rating = await service.getRating(widget.item);
      if (mounted) {
        setState(() => _currentRating = rating);
      }
    }
  }

  Future<void> _setRating(int rating) async {
    setState(() => _isLoading = true);
    
    try {
      final service = ref.read(watchedServiceProvider);
      if (service == null) return;

      await service.setRating(widget.item, rating);
      if (mounted) setState(() => _currentRating = rating);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Rating',
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(5, (index) {
            final starValue = index + 1;
            final isFilled = _currentRating != null && starValue <= _currentRating!;
            
            return GestureDetector(
              onTap: () => _setRating(starValue),
              child: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  isFilled ? Icons.star : Icons.star_border,
                  color: isFilled ? Colors.amber : Colors.grey,
                  size: 28,
                ),
              ),
            );
          }),
        ),
        if (_currentRating != null) ...[
          const SizedBox(height: 4),
          Text(
            '$_currentRating / 5',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}
