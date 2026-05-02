# Developer 2: Movie API Specialist

## 👤 Your Responsibility
You are responsible for implementing the TMDB API integration and the entire movie data layer.

## 📁 Your Folders
- `lib/features/movies/data/` - Data sources, models, repositories
- `lib/features/movies/domain/` - Entities, repository interfaces, use cases

## 📋 Your Files
1. `lib/features/movies/data/datasources/tmdb_remote_data_source.dart`
2. `lib/features/movies/data/models/movie_model.dart`
3. `lib/features/movies/data/repositories/legacy_tmdb_repository.dart`
4. `lib/features/movies/data/repositories/movie_repository_impl.dart`
5. `lib/features/movies/domain/entities/genre.dart`
6. `lib/features/movies/domain/entities/movie_filters.dart`
7. `lib/features/movies/domain/entities/movie_page.dart`
8. `lib/features/movies/domain/entities/movie.dart`
9. `lib/features/movies/domain/repositories/movie_repository.dart`
10. `lib/features/movies/domain/usecases/get_movie_genres_use_case.dart`
11. `lib/features/movies/domain/usecases/get_trending_movies_use_case.dart`
12. `lib/features/movies/domain/usecases/search_movies_use_case.dart`

## 🔄 Development Phases

### Version 1: Basic Structure (Week 1)
**Goal:** Create data structures with hardcoded JSON data

**Dependencies to add:**
```yaml
dependencies:
  flutter:
    sdk: flutter
```

**What to implement:**
- Entity classes (movie, genre, etc.)
- Repository interface
- Mock data source returning hardcoded JSON
- Use cases returning mock data

**Git Commands:**
```bash
git checkout -b feature/movie-api-structure
# Copy files from version_1 folder
git add lib/features/movies/data/ lib/features/movies/domain/
git commit -m "feat: Add movie API structure with mock data (v1)"
git push origin feature/movie-api-structure
```

### Version 2: API Integration (Week 2)
**Goal:** Add real TMDB API calls with HTTP client

**Dependencies to add:**
```yaml
dependencies:
  http: ^1.2.1
  flutter_riverpod: ^2.5.1
```

**What to implement:**
- Real HTTP calls to TMDB API
- JSON parsing in models
- Error handling for network errors
- Repository implementation with real data

**Git Commands:**
```bash
git pull origin main
# Copy files from version_2 folder
git add lib/features/movies/data/ lib/features/movies/domain/
git commit -m "feat: Add TMDB API integration with HTTP (v2)"
git push origin feature/movie-api-structure
```

### Version 3: Production Ready (Week 3)
**Goal:** Add caching, retry logic, complete error handling

**Dependencies to add:**
```yaml
dependencies:
  shared_preferences: ^2.2.2
```

**What to implement:**
- Response caching
- Retry logic for failed requests
- Rate limiting
- Complete error handling
- Logging

**Git Commands:**
```bash
git pull origin main
# Copy files from version_3 folder
git add lib/features/movies/data/ lib/features/movies/domain/
git commit -m "feat: Complete movie API with caching and error handling (v3)"
git push origin feature/movie-api-structure
# Create Pull Request for code review
```

## 🧪 Testing Your Code

### Version 1
```bash
flutter run
# Verify hardcoded data displays
# Check entity classes are properly structured
```

### Version 2
```bash
# Get TMDB API key from https://www.themoviedb.org/settings/api
# Add to lib/core/config/api_key.dart
flutter run
# Test API calls
# Verify JSON parsing works
# Check error handling for network issues
```

### Version 3
```bash
flutter run
# Test caching (turn off internet, data should still load)
# Test retry logic (simulate network failure)
# Verify all error cases handled
```

## 🔑 TMDB API Setup

1. Go to https://www.themoviedb.org/
2. Create an account
3. Go to Settings → API
4. Request an API key
5. Add to `lib/core/config/api_key.dart`:
```dart
class ApiKey {
  static const String tmdbApiKey = 'your_api_key_here';
}
```

## 📊 API Endpoints You'll Use

### Trending Movies
```
GET https://api.themoviedb.org/3/trending/movie/week?api_key={api_key}
```

### Search Movies
```
GET https://api.themoviedb.org/3/search/movie?api_key={api_key}&query={query}
```

### Movie Genres
```
GET https://api.themoviedb.org/3/genre/movie/list?api_key={api_key}
```

### Movie Details
```
GET https://api.themoviedb.org/3/movie/{movie_id}?api_key={api_key}
```

## 🏗️ Architecture Pattern

You're implementing the **Data Layer** of Clean Architecture:

```
Presentation Layer (Developer 3)
        ↓
Domain Layer (You - Use Cases & Entities)
        ↓
Data Layer (You - Repositories & Data Sources)
        ↓
External API (TMDB)
```

## ⚠️ Important Notes
- Don't modify presentation layer files (Developer 3's responsibility)
- Coordinate with Developer 5 for API key configuration
- Coordinate with Developer 3 for provider integration
- Always handle network errors gracefully
- Never commit API keys to git (use .gitignore)

## 📞 Dependencies on Other Developers
- **Developer 5 (Core):** Needs API key configuration
- **Developer 3 (UI):** Will use your repositories and use cases
- **Developer 4 (Features):** May use your movie entities

## 🎯 Success Criteria

### Version 1
- [ ] All entity classes created
- [ ] Repository interface defined
- [ ] Mock data source returns hardcoded movies
- [ ] Use cases return mock data
- [ ] Code compiles without errors

### Version 2
- [ ] HTTP client integrated
- [ ] Real API calls working
- [ ] JSON parsing successful
- [ ] Basic error handling present
- [ ] Repository returns real data

### Version 3
- [ ] Caching implemented
- [ ] Retry logic working
- [ ] All error cases handled
- [ ] Rate limiting in place
- [ ] Logging added
- [ ] Code reviewed and approved

## 💡 Pro Tips
1. Use Postman to test API endpoints before coding
2. Handle rate limiting (TMDB has request limits)
3. Cache responses to reduce API calls
4. Use proper error types (NetworkError, ServerError, etc.)
5. Log all API calls for debugging
6. Test with airplane mode to verify error handling
