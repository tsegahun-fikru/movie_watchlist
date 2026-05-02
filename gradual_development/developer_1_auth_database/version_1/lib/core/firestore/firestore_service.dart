// Version 1: Basic Structure - Mock Service
// No Firestore implementation yet

/// Mock Firestore service for Version 1
/// This will be replaced with real Firestore in Version 3
class FirestoreService {
  /// Mock method to simulate getting watchlist collection
  dynamic getWatchlistCollection() {
    print('Mock: Getting watchlist collection');
    return null;
  }

  /// Mock method to add to watchlist
  Future<void> addToWatchlist(int movieId, Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 500));
    print('Mock: Added movie $movieId to watchlist');
  }

  /// Mock method to remove from watchlist
  Future<void> removeFromWatchlist(int movieId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    print('Mock: Removed movie $movieId from watchlist');
  }
}
