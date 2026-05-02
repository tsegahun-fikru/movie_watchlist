# Developer 3: UI/UX & Home Architect

## 👤 Your Responsibility
You are responsible for the home screen, movie presentation layer, and all core UI widgets.

## 📁 Your Folders
- `lib/features/home/` - Home screen and widgets
- `lib/features/movies/presentation/` - Movie presentation (screens, widgets, notifiers, state)
- `lib/core/widgets/` - Reusable widgets (movie cards, loading states, etc.)

## 📋 Your Files

### Home Feature (6 files)
1. `lib/features/home/presentation/screens/home_screen.dart`
2. `lib/features/home/presentation/widgets/auto_carousel.dart`
3. `lib/features/home/presentation/widgets/filter_provider.dart`
4. `lib/features/home/presentation/widgets/movie_search_delegate.dart`
5. `lib/features/home/presentation/widgets/recommendations_row.dart`
6. `lib/features/home/presentation/widgets/search_history_widget.dart`

### Movies Presentation (9 files)
7. `lib/features/movies/presentation/screens/genre_browse_screen.dart`
8. `lib/features/movies/presentation/widgets/movie_search_filter_bar.dart`
9. `lib/features/movies/presentation/widgets/movie_search_result_list.dart`
10. `lib/features/movies/presentation/widgets/tv_search_filter_bar.dart`
11. `lib/features/movies/presentation/notifiers/movie_search_notifier.dart`
12. `lib/features/movies/presentation/notifiers/tv_search_notifier.dart`
13. `lib/features/movies/presentation/state/movie_search_state.dart`
14. `lib/features/movies/presentation/state/tv_search_state.dart`
15. `lib/features/movies/presentation/providers/movie_providers.dart`

### Core Widgets (5 files)
16. `lib/core/widgets/movie_card.dart`
17. `lib/core/widgets/tv_show_card.dart`
18. `lib/core/widgets/movie_card_skeleton.dart`
19. `lib/core/widgets/shimmer_loading.dart`
20. `lib/core/widgets/custom_app_bar.dart`

## 🔄 Development Phases

### Version 1: Basic UI (Week 1)
**Goal:** Create UI shells with hardcoded movie data

**Dependencies to add:**
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
```

**What to implement:**
- Home screen with static layout
- Movie cards with hardcoded data
- Carousel with placeholder images
- Search UI (no functionality)
- Genre grid with hardcoded genres

**Git Commands:**
```bash
git checkout -b feature/ui-home-structure
# Copy files from version_1 folder
git add lib/features/home/ lib/features/movies/presentation/ lib/core/widgets/
git commit -m "feat: Add home and movie UI structure (v1)"
git push origin feature/ui-home-structure
```

### Version 2: Provider Integration (Week 2)
**Goal:** Connect UI to providers and display real data

**Dependencies to add:**
```yaml
dependencies:
  flutter_riverpod: ^2.5.1
  cached_network_image: ^3.3.1
```

**What to implement:**
- Riverpod providers for state management
- Connect to movie repository (Developer 2's work)
- Display real movie data
- Loading states
- Error states
- Search functionality

**Git Commands:**
```bash
git pull origin main
# Copy files from version_2 folder
git add lib/features/home/ lib/features/movies/presentation/ lib/core/widgets/
git commit -m "feat: Add provider integration and real data display (v2)"
git push origin feature/ui-home-structure
```

### Version 3: Production Ready (Week 3)
**Goal:** Add animations, caching, polish

**What to implement:**
- Cached network images
- Smooth animations
- Pull to refresh
- Infinite scroll
- Search history
- Complete error handling
- Loading skeletons

**Git Commands:**
```bash
git pull origin main
# Copy files from version_3 folder
git add lib/features/home/ lib/features/movies/presentation/ lib/core/widgets/
git commit -m "feat: Complete UI with animations and caching (v3)"
git push origin feature/ui-home-structure
# Create Pull Request for code review
```

## 🧪 Testing Your Code

### Version 1
```bash
flutter run
# Verify all screens display
# Check hardcoded data shows correctly
# Test navigation between screens
```

### Version 2
```bash
flutter run
# Verify real movie data displays
# Test search functionality
# Check loading states
# Test error states (turn off internet)
```

### Version 3
```bash
flutter run
# Test image caching (scroll, go back, images should load instantly)
# Test pull to refresh
# Test infinite scroll
# Verify smooth animations
# Test search history
```

## 🎨 UI Components You'll Build

### Home Screen
- **Auto Carousel:** Rotating banner of trending movies
- **Recommendations Row:** Horizontal scrolling movie list
- **Search Bar:** Search movies and TV shows
- **Genre Chips:** Filter by genre

### Movie Card
- Movie poster image
- Title
- Rating (stars)
- Year
- Watchlist button

### Loading States
- Shimmer loading for cards
- Skeleton screens
- Progress indicators

### Error States
- No internet connection
- Server error
- Empty results

## 🏗️ Architecture Pattern

You're implementing the **Presentation Layer** of Clean Architecture:

```
Your UI Components
        ↓
Riverpod Providers (State Management)
        ↓
Use Cases (Developer 2)
        ↓
Repositories (Developer 2)
```

## ⚠️ Important Notes
- Don't modify data or domain layers (Developer 2's responsibility)
- Coordinate with Developer 2 for provider integration
- Coordinate with Developer 5 for routing
- Use theme colors from `lib/core/theme/app_colors.dart`
- Make UI responsive (works on different screen sizes)

## 📞 Dependencies on Other Developers
- **Developer 2 (API):** Provides movie data through repositories
- **Developer 5 (Core):** Provides routing and theme
- **Developer 4 (Features):** Will use your movie cards in watchlist

## 🎯 Success Criteria

### Version 1
- [ ] Home screen displays with static layout
- [ ] Movie cards show hardcoded data
- [ ] Carousel displays placeholder images
- [ ] Search UI present (no functionality)
- [ ] Code compiles without errors

### Version 2
- [ ] Providers integrated
- [ ] Real movie data displays
- [ ] Search works
- [ ] Loading states show
- [ ] Error states handled

### Version 3
- [ ] Images cached
- [ ] Animations smooth
- [ ] Pull to refresh works
- [ ] Infinite scroll works
- [ ] Search history saved
- [ ] All edge cases handled

## 💡 Pro Tips
1. Use `cached_network_image` for all movie posters
2. Implement shimmer loading for better UX
3. Use `ListView.builder` for performance
4. Add pull-to-refresh for better UX
5. Handle empty states gracefully
6. Test on different screen sizes
7. Use const constructors for performance
8. Implement hero animations for movie details

## 🎨 Design Guidelines
- Follow Material Design principles
- Use consistent spacing (8px grid)
- Use theme colors (don't hardcode colors)
- Add subtle animations (don't overdo it)
- Make touch targets at least 48x48
- Support both light and dark themes
- Ensure text is readable (good contrast)

## 📱 Responsive Design
- Mobile: Single column layout
- Tablet: Two column layout
- Desktop: Three column layout
- Use `MediaQuery` to detect screen size
- Test on different devices
