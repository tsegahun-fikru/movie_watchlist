# Developer 1: Auth & Database Lead

## 👤 Your Responsibility
You are responsible for implementing the authentication system and Firestore database integration.

## 📁 Your Folders
- `lib/features/auth/` - All authentication screens and providers
- `lib/core/auth/` - Auth repository and wrappers
- `lib/core/firestore/` - Firestore service

## 📋 Your Files
1. `lib/features/auth/presentation/screens/login_screen.dart`
2. `lib/features/auth/presentation/screens/signup_screen.dart`
3. `lib/features/auth/presentation/screens/forgot_password_screen.dart`
4. `lib/features/auth/presentation/screens/change_password_screen.dart`
5. `lib/features/auth/presentation/screens/onboarding_screen.dart`
6. `lib/features/auth/presentation/providers/auth_providers.dart`
7. `lib/core/auth/auth_repository.dart`
8. `lib/core/auth/root_auth_wrapper.dart`
9. `lib/core/firestore/firestore_service.dart`

## 🔄 Development Phases

### Version 1: Basic Structure (Week 1)
**Goal:** Create basic UI with hardcoded data, no Firebase integration

**Dependencies to add:**
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
```

**Git Commands:**
```bash
git checkout -b feature/auth-basic-structure
# Copy files from version_1 folder
git add lib/features/auth/ lib/core/auth/ lib/core/firestore/
git commit -m "feat: Add basic auth UI structure (v1)"
git push origin feature/auth-basic-structure
```

### Version 2: Firebase Integration (Week 2)
**Goal:** Add Firebase Auth, form validation, state management

**Dependencies to add:**
```yaml
dependencies:
  firebase_core: ^3.3.0
  firebase_auth: ^5.2.0
  flutter_riverpod: ^2.5.1
  go_router: ^17.2.2
```

**Git Commands:**
```bash
git pull origin main
# Copy files from version_2 folder
git add lib/features/auth/ lib/core/auth/ lib/core/firestore/
git commit -m "feat: Add Firebase Auth integration and providers (v2)"
git push origin feature/auth-basic-structure
```

### Version 3: Production Ready (Week 3)
**Goal:** Add error handling, Firestore integration, complete features

**Dependencies to add:**
```yaml
dependencies:
  cloud_firestore: ^5.2.0
```

**Git Commands:**
```bash
git pull origin main
# Copy files from version_3 folder
git add lib/features/auth/ lib/core/auth/ lib/core/firestore/
git commit -m "feat: Complete auth with error handling and Firestore (v3)"
git push origin feature/auth-basic-structure
# Create Pull Request for code review
```

## 🧪 Testing Your Code

### Version 1
```bash
flutter run
# Navigate to login/signup screens
# Verify UI displays correctly
```

### Version 2
```bash
# Make sure Firebase is configured
flutter run
# Test login/signup with real credentials
# Verify navigation works
```

### Version 3
```bash
flutter run
# Test all auth flows
# Test error handling
# Test Firestore integration
```

## ⚠️ Important Notes
- Don't modify files outside your responsibility
- Always pull before pushing
- Test on both Android and iOS if possible
- Coordinate with Developer 5 (Core) for routing setup
- Coordinate with Developer 4 for Firestore collection structure

## 📞 Dependencies on Other Developers
- **Developer 5 (Core):** Needs routing setup before you can test navigation
- **Developer 4 (Watchlist):** Will use your Firestore service
- **Developer 3 (UI):** Will use your auth state for conditional rendering
