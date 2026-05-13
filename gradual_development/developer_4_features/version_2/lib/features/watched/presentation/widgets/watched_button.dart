// lib/features/watched/presentation/widgets/watched_button.dart
// VERSION 2 - Watched button with Firestore integration.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_watchlist/features/watched/presentation/providers/watched_providers.dart';

/// Button to mark/unmark an item as watched with Firestore.
/// TODO v3: Add optimistic updates, undo functionality
class WatchedButton extends ConsumerStatefulWidget {
  final dynamic item; // Movie or TvShow

  const WatchedButton({
    super.key,
    required this.item,
  });

  @override
  ConsumerState<WatchedButton> createState() => _WatchedButtonState();
}

class _WatchedButtonState extends ConsumerState<WatchedButton> {
  bool _isLoading = false;
  bool? _isWatched;

  @override
  void initState() {
    super.initState();
    _checkWatchedStatus();
  }

  Future<void> _checkWatchedStatus() async {
    final service = ref.read(watchedServiceProvider);
    if (service != null) {
      final watched = await service.isWatched(widget.item);
      if (mounted) {
        setState(() => _isWatched = watched);
      }
    }
  }

  Future<void> _toggleWatched() async {
    setState(() => _isLoading = true);
    
    try {
      final service = ref.read(watchedServiceProvider);
      if (service == null) return;

      if (_isWatched == true) {
        await service.removeItem(widget.item);
        if (mounted) setState(() => _isWatched = false);
      } else {
        await service.addItem(widget.item);
        if (mounted) setState(() => _isWatched = true);
      }
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
      return const Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return IconButton(
      icon: Icon(
        _isWatched == true ? Icons.check_circle : Icons.check_circle_outline,
        color: _isWatched == true ? Colors.red : Colors.grey,
      ),
      onPressed: _toggleWatched,
      tooltip: _isWatched == true ? 'Mark as unwatched' : 'Mark as watched',
    );
  }
}
