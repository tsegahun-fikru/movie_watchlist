# Developer 5: Core & DevOps Engineer

## 👤 Your Responsibility
You are responsible for the app foundation: main entry point, routing, dependency injection, localization, and shared infrastructure.

## 📁 Your Folders
- `lib/main.dart` - App entry point
- `lib/app/` - App-level configuration (routing, navigation)
- `lib/core/` - Core infrastructure (DI, theme, constants, error handling)
- `lib/l10n/` - Localization files
- `lib/bootstrap/` - App startup and splash screen
- `lib/shared/` - Shared models used across features

## 📋 Your Files

### Main App (2 files)
1. `lib/main.dart`
2. `lib/firebase_options.dart`

### App Structure (2 files)
3. `lib/app/router/app_router.dart`
4. `lib/app/navigation/main_navigation_wrapper.dart`

### Core Infrastructure (13 files)
5. `lib/core/di/clean_arch_providers.dart`
6. `lib/core/theme/app_colors.dart`
7. `lib/core/theme/app_theme.dart`
8. `lib/core/constants/constants.dart`
9. `lib/core/constants/app_strings.dart`
10. `lib/core/config/api_key.dart`
11. `lib/core/error/exceptions.dart`
12. `lib/core/error/failures.dart`
13. `lib/core/result/result.dart`
14. `lib/core/providers/core_providers.dart`
15. `lib/core/localization/locale_provider.dart`

### Localization (5 files)
16. `lib/l10n/app_en.arb`
17. `lib/l10n/app_am.arb`
18. `lib/l10n/app_localizations.dart`
19. `lib/l10n/app_localizations_en.dart`
20. `lib/l10n/app_localizations_am.dart`

### Bootstrap (2+ files)
21. `lib/bootstrap/app_startup.dart`
22. `lib/bootstrap/splash/splash_screen.dart`
23. `lib/bootstrap/splash/widgets/*` (splash widgets)

### Shared Models (5 files)
24. `lib/shared/models/movie.dart`
25. `lib/shared/models/tv_show.dart`
26. `lib/shared/models/cast_members.dart`
27. `lib/shared/models/tv_episode.dart`
28. `lib/shared/models/search_result_item.dart`

## 🔄 Development Phases

### Version 1: Basic App Structure (Week 1)
**Goal:** Create minimal working app with basic routing

**Dependencies to add:**
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  flutter_localizations:
    sdk: flutter
  intl: any
```

**What to implement:**
- Basic MaterialApp
- Simple routing (2-3 routes)
- Theme configuration
- Constants
- Shared models (basic structure)
- Splash screen

**Git Commands:**
```bash
git checkout -b feature/core-setup
# Copy files from version_1 folder
git add lib/main.dart lib/app/ lib/core/ lib/l10n/ lib/bootstrap/ lib/shared/
git commit -m "feat: Add core app structure and basic routing (v1)"
git push origin feature/core-setup
```

### Version 2: Complete Infrastructure (Week 2)
**Goal:** Add GoRouter, Firebase, Riverpod DI

**Dependencies to add:**
```yaml
dependencies:
  go_router: ^17.2.2
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  firebase_core: ^3.3.0
  
dev_dependencies:
  riverpod_generator: ^2.4.0
  build_runner: ^2.4.9
```

**What to implement:**
- Complete GoRouter setup with all routes
- Auth guards (redirect if not logged in)
- Deep linking
- Firebase initialization
- Riverpod providers for DI
- Error boundary
- App lifecycle management

**Git Commands:**
```bash
git pull origin main
# Copy files from version_2 folder
git add lib/main.dart lib/app/ lib/core/ lib/firebase_options.dart
git commit -m "feat: Add GoRouter, Firebase, and Riverpod DI (v2)"
git push origin feature/core-setup
```

### Version 3: Production Ready (Week 3)
**Goal:** Add complete localization, analytics, error tracking

**Dependencies to add:**
```yaml
dependencies:
  firebase_messaging: ^15.2.10
  app_links: ^6.1.1
```

**What to implement:**
- Complete localization (English + Amharic)
- Push notifications setup
- Deep linking configuration
- Error tracking
- Performance monitoring
- Complete app configuration

**Git Commands:**
```bash
git pull origin main
# Copy files from version_3 folder
git add lib/main.dart lib/app/ lib/core/ lib/l10n/ lib/firebase_options.dart
git commit -m "feat: Complete core with localization and analytics (v3)"
git push origin feature/core-setup
# Create Pull Request for code review
```

## 🧪 Testing Your Code

### Version 1
```bash
flutter run
# Verify app launches
# Check basic routing works
# Verify theme applied
# Test splash screen
```

### Version 2
```bash
# Configure Firebase first
flutter run
# Test all routes
# Test auth guards (try accessing protected routes)
# Test deep linking
# Verify Firebase initialized
```

### Version 3
```bash
flutter run
# Test language switching (English ↔ Amharic)
# Test push notifications
# Test deep links
# Verify error tracking works
# Check performance monitoring
```

## 🔥 Firebase Setup

### Step 1: Create Firebase Project
1. Go to https://console.firebase.google.com/
2. Create new project
3. Enable Authentication (Email/Password)
4. Enable Firestore Database
5. Enable Cloud Messaging (for notifications)

### Step 2: Add Firebase to Flutter
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```

This generates `lib/firebase_options.dart` and updates platform-specific files.

### Step 3: Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## 🗺️ Routing Structure

### Version 1 Routes (Basic)
```dart
- / → Splash Screen
- /login → Login Screen
- /home → Home Screen
```

### Version 2 Routes (Complete)
```dart
- / → Splash Screen
- /onboarding → Onboarding Screen
- /login → Login Screen
- /signup → Signup Screen
- /forgot-password → Forgot Password Screen
- /home → Home Screen (protected)
- /watchlist → Watchlist Screen (protected)
- /watched → Watched Screen (protected)
- /profile → Profile Screen (protected)
- /movie/:id → Movie Details Screen (protected)
- /genre/:id → Genre Browse Screen (protected)
```

### Auth Guard Example
```dart
redirect: (context, state) {
  final isLoggedIn = ref.read(authStateProvider).value != null;
  final isLoggingIn = state.location == '/login';
  
  if (!isLoggedIn && !isLoggingIn) {
    return '/login';
  }
  if (isLoggedIn && isLoggingIn) {
    return '/home';
  }
  return null;
}
```

## 🌍 Localization Setup

### English (app_en.arb)
```json
{
  "appTitle": "Movie Watchlist",
  "login": "Login",
  "signup": "Sign Up",
  "email": "Email",
  "password": "Password",
  "forgotPassword": "Forgot Password?",
  "watchlist": "Watchlist",
  "watched": "Watched",
  "home": "Home",
  "profile": "Profile"
}
```

### Amharic (app_am.arb)
```json
{
  "appTitle": "የፊልም ዝርዝር",
  "login": "ግባ",
  "signup": "ተመዝገብ",
  "email": "ኢሜይል",
  "password": "የይለፍ ቃል",
  "forgotPassword": "የይለፍ ቃል ረሱ?",
  "watchlist": "ለመመልከት",
  "watched": "የተመለከቱ",
  "home": "መነሻ",
  "profile": "መገለጫ"
}
```

### Usage in Code
```dart
Text(AppLocalizations.of(context)!.appTitle)
```

## 🏗️ Dependency Injection Pattern

### Provider Setup
```dart
// lib/core/di/clean_arch_providers.dart

// Auth Repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});

// Movie Repository
final movieRepositoryProvider = Provider<MovieRepository>((ref) {
  return MovieRepositoryImpl(
    dataSource: ref.read(tmdbDataSourceProvider),
  );
});

// Watchlist Repository
final watchlistRepositoryProvider = Provider<WatchlistRepository>((ref) {
  return WatchlistRepositoryImpl(
    dataSource: ref.read(firestoreWatchlistDataSourceProvider),
  );
});
```

## ⚠️ Important Notes
- You are the first developer to push (others depend on your setup)
- Coordinate with all developers for routing
- Manage shared dependencies in pubspec.yaml
- Don't modify feature-specific code
- Keep core infrastructure generic and reusable

## 📞 Dependencies on Other Developers
- **All Developers:** Depend on your routing, theme, and DI setup
- **Developer 1 (Auth):** Needs your auth guards in routing
- **Developer 2 (API):** Needs your API key configuration
- **Developer 3 (UI):** Needs your theme and shared models
- **Developer 4 (Features):** Needs your routing to their screens

## 🎯 Success Criteria

### Version 1
- [ ] App launches successfully
- [ ] Basic routing works
- [ ] Theme applied
- [ ] Splash screen displays
- [ ] Constants defined
- [ ] Shared models created

### Version 2
- [ ] GoRouter with all routes
- [ ] Auth guards working
- [ ] Firebase initialized
- [ ] Riverpod DI setup
- [ ] Deep linking works
- [ ] Error boundary present

### Version 3
- [ ] Localization complete (en + am)
- [ ] Language switching works
- [ ] Push notifications setup
- [ ] Error tracking works
- [ ] Performance monitoring active
- [ ] All configuration complete

## 💡 Pro Tips
1. Set up Firebase early (others need it)
2. Define all routes upfront (helps other developers)
3. Use environment variables for API keys
4. Implement error boundary for crash handling
5. Add logging for debugging
6. Use feature flags for gradual rollout
7. Document all configuration steps
8. Create setup scripts for new developers

## 🚀 Deployment Checklist

### Android
- [ ] Update app name in AndroidManifest.xml
- [ ] Update package name
- [ ] Add google-services.json
- [ ] Configure signing keys
- [ ] Update version code/name

### iOS
- [ ] Update app name in Info.plist
- [ ] Update bundle identifier
- [ ] Add GoogleService-Info.plist
- [ ] Configure signing
- [ ] Update version/build number

### Firebase
- [ ] Enable Authentication
- [ ] Enable Firestore
- [ ] Set security rules
- [ ] Enable Cloud Messaging
- [ ] Configure analytics

## 📚 Additional Resources
- GoRouter: https://pub.dev/packages/go_router
- Riverpod: https://riverpod.dev/
- Firebase: https://firebase.google.com/docs/flutter/setup
- Localization: https://docs.flutter.dev/development/accessibility-and-localization/internationalization
