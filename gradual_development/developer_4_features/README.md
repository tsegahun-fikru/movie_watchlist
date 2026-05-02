# Developer 4: Feature Developer (Watchlist & Rating)

## 👤 Your Responsibility
You are responsible for implementing the watchlist and watched features, including rating functionality.

## 📁 Your Folders
- `lib/features/watchlist/` - Complete watchlist feature (data, domain, presentation)
- `lib/features/watched/` - Complete watched feature (data, presentation)

## 📋 Your Files

### Watchlist Feature (13 files)
1. `lib/features/watchlist/data/datasources/firestore_watchlist_data_source.dart`
2. `lib/features/watchlist/data/models/watchlist_item_model.dart`
3. `lib/features/watchlist/data/models/watchlist_item.dart`
4. `lib/features/watchlist/data/repositories/watchlist_repository_impl.dart`
5. `lib/features/watchlist/data/services/watchlist_service.dart`
6. `lib/features/watchlist/domain/entities/watchlist_item.dart`
7. `lib/features/watchlist/domain/repositories/watchlist_repository.dart`
8. `lib/features/watchlist/domain/usecases/add_to_watchlist_use_case.dart`
9. `lib/features/watchlist/domain/usecases/get_watchlist_use_case.dart`
10. `lib/features/watchlist/domain/usecases/remove_from_watchlist_use_case.dart`
11. `lib/features/watchlist/presentation/screens/watchlist_screen.dart`
12. `lib/features/watchlist/presentation/widgets/watchlist_card.dart`
13. `lib/features/watchlist/presentation/providers/watchlist_providers.dart`

### Watched Feature (5 files)
14. `lib/features/watched/data/services/watched_service.dart`
15. `lib/features/watched/presentation/screens/watched_screen.dart`
16. `lib/features/watched/presentation/widgets/user_rating_bar.dart`
17. `lib/features/watched/presentation/widgets/watched_button.dart`
18. `lib/features/watched/presentation/providers/watched_providers.dart`

## 🔄 Development Phases

### Version 1: Basic Structure (Week 1)
**Goal:** Create UI with hardcoded watchlist data

**Dependencies to add:**
```yaml
dependencies:
  flutter:
    sdk: flutter
```

**What to implement:**
- Watchlist screen with hardcoded movies
- Watched screen with hardcoded movies
- Rating widget (static)
- Add/remove buttons (no functionality)
- Entity classes

**Git Commands:**
```bash
git checkout -b feature/watchlist-watched-structure
# Copy files from version_1 folder
git add lib/features/watchlist/ lib/features/watched/
git commit -m "feat: Add watchlist and watched UI structure (v1)"
git push origin feature/watchlist-watched-structure
```

### Version 2: Firestore Integration (Week 2)
**Goal:** Add real Firestore CRUD operations

**Dependencies to add:**
```yaml
dependencies:
  cloud_firestore: ^5.2.0
  flutter_riverpod: ^2.5.1
```

**What to implement:**
- Firestore data source
- Real CRUD operations (Create, Read, Update, Delete)
- Repository implementation
- Use cases with real data
- Provider integration
- Loading states

**Git Commands:**
```bash
git pull origin main
# Copy files from version_2 folder
git add lib/features/watchlist/ lib/features/watched/
git commit -m "feat: Add Firestore integration for watchlist (v2)"
git push origin feature/watchlist-watched-structure
```

### Version 3: Production Ready (Week 3)
**Goal:** Add optimistic updates, offline support, polish

**What to implement:**
- Optimistic updates (instant UI feedback)
- Offline support (local caching)
- Sync indicators
- Complete error handling
- Rating persistence
- Swipe to delete
- Empty states

**Git Commands:**
```bash
git pull origin main
# Copy files from version_3 folder
git add lib/features/watchlist/ lib/features/watched/
git commit -m "feat: Complete watchlist with offline support (v3)"
git push origin feature/watchlist-watched-structure
# Create Pull Request for code review
```

## 🧪 Testing Your Code

### Version 1
```bash
flutter run
# Verify watchlist screen displays
# Check hardcoded movies show
# Test rating widget displays
```

### Version 2
```bash
# Make sure Firebase is configured
flutter run
# Test adding movies to watchlist
# Test removing movies
# Test rating movies
# Verify data persists after app restart
```

### Version 3
```bash
flutter run
# Test optimistic updates (instant feedback)
# Test offline mode (turn off internet, should still work)
# Test sync when back online
# Test swipe to delete
# Verify all error cases handled
```

## 🔥 Firestore Structure

### Watchlist Collection
```
users/{userId}/watchlist/{movieId}
  ├── movieId: int
  ├── title: string
  ├── posterPath: string
  ├── rating: double
  ├── releaseDate: string
  ├── addedAt: timestamp
  └── isWatched: boolean
```

### Watched Collection
```
users/{userId}/watched/{movieId}
  ├── movieId: int
  ├── title: string
  ├── posterPath: string
  ├── userRating: double (1-5 stars)
  ├── watchedAt: timestamp
  └── notes: string (optional)
```

## 🏗️ Architecture Pattern

You're implementing **Complete Clean Architecture** for your features:

```
Presentation Layer (Your Screens & Widgets)
        ↓
Domain Layer (Your Use Cases & Entities)
        ↓
Data Layer (Your Repositories & Data Sources)
        ↓
External Service (Firestore)
```

## ⚠️ Important Notes
- Use Developer 1's Firestore service for database access
- Coordinate with Developer 3 for movie card widgets
- Coordinate with Developer 5 for routing to your screens
- Always handle offline scenarios
- Implement optimistic updates for better UX

## 📞 Dependencies on Other Developers
- **Developer 1 (Auth):** Provides Firestore service and user authentication
- **Developer 3 (UI):** Provides movie card widgets you'll reuse
- **Developer 5 (Core):** Provides routing to your screens
- **Developer 2 (API):** Provides movie entities

## 🎯 Success Criteria

### Version 1
- [ ] Watchlist screen displays
- [ ] Watched screen displays
- [ ] Rating widget works (UI only)
- [ ] Hardcoded data shows correctly
- [ ] Code compiles without errors

### Version 2
- [ ] Add to watchlist works
- [ ] Remove from watchlist works
- [ ] Rating persists to Firestore
- [ ] Data loads from Firestore
- [ ] Loading states present

### Version 3
- [ ] Optimistic updates work
- [ ] Offline mode works
- [ ] Sync works when back online
- [ ] Swipe to delete works
- [ ] All error cases handled
- [ ] Empty states present

## 💡 Pro Tips
1. Use optimistic updates for instant feedback
2. Cache data locally for offline support
3. Show sync indicators when syncing
4. Handle conflicts (same movie added on different devices)
5. Use transactions for atomic operations
6. Implement undo functionality for deletes
7. Add search/filter to watchlist
8. Sort by date added, rating, or title

## 🎨 UI Features to Implement

### Watchlist Screen
- List of movies to watch
- Add/remove buttons
- Sort options (date, title, rating)
- Filter options (genre, year)
- Search functionality
- Empty state ("No movies in watchlist")

### Watched Screen
- List of watched movies
- User ratings (1-5 stars)
- Watch date
- Personal notes (optional)
- Sort by watch date or rating
- Empty state ("No watched movies yet")

### Rating Widget
- 5-star rating system
- Half-star support
- Tap to rate
- Visual feedback
- Persist rating to Firestore

## 🔄 Optimistic Updates Pattern

```dart
// Example: Add to watchlist with optimistic update
Future<void> addToWatchlist(Movie movie) async {
  // 1. Update UI immediately (optimistic)
  state = [...state, movie];
  
  try {
    // 2. Save to Firestore
    await repository.addToWatchlist(movie);
  } catch (e) {
    // 3. Revert if failed
    state = state.where((m) => m.id != movie.id).toList();
    // 4. Show error
    showError('Failed to add to watchlist');
  }
}
```

## 📱 Offline Support Strategy

1. **Local Cache:** Use Firestore offline persistence
2. **Sync Indicator:** Show when syncing with server
3. **Conflict Resolution:** Last write wins
4. **Queue Operations:** Queue writes when offline
5. **Retry Logic:** Retry failed operations when back online

## 🐛 Common Issues & Solutions

### Issue: "User not authenticated"
**Solution:** Check if user is logged in before Firestore operations

### Issue: "Permission denied"
**Solution:** Update Firestore security rules

### Issue: "Data not syncing"
**Solution:** Enable Firestore offline persistence

### Issue: "Duplicate entries"
**Solution:** Use movieId as document ID (prevents duplicates)
