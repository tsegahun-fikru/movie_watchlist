// lib/core/firestore/firestore_service.dart
// VERSION 1 - No Firebase. Returns hardcoded mock data.

/// Mock Firestore service - returns hardcoded data, no real database.
class FirestoreService {
  // Hardcoded mock watchlist
  final List<Map<String, dynamic>> _mockWatchlist = [
    {'movieId': '1', 'title': 'Inception', 'addedAt': '2024-01-01'},
    {'movieId': '2', 'title': 'The Dark Knight', 'addedAt': '2024-01-02'},
  ];

  /// Returns mock watchlist data.
  /// TODO v2: Replace with real Firestore collection
  List<Map<String, dynamic>> getWatchlist() {
    return _mockWatchlist;
  }

  /// Adds a movie to the mock watchlist.
  /// TODO v2: Replace with Firestore .set()
  Future<void> addToWatchlist(int movieId, Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockWatchlist.add({'movieId': movieId.toString(), ...data});
  }

  /// Removes a movie from the mock watchlist.
  /// TODO v2: Replace with Firestore .delete()
  Future<void> removeFromWatchlist(int movieId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockWatchlist.removeWhere((item) => item['movieId'] == movieId.toString());
  }
}
