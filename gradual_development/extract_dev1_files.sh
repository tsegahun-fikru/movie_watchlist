#!/bin/bash
# Extract Developer 1 (Auth & Database Lead) files
# This script copies Version 3 (production) files from the main lib folder

echo "🚀 Extracting Developer 1 files..."
echo "Developer: Auth & Database Lead"
echo "Files: Auth screens, Auth repository, Firestore service"
echo ""

# Base directory
BASE_DIR="gradual_development/developer_1_auth_database/version_3"

# Create directory structure
echo "📁 Creating directory structure..."
mkdir -p "$BASE_DIR/lib/features/auth/presentation/screens"
mkdir -p "$BASE_DIR/lib/features/auth/presentation/providers"
mkdir -p "$BASE_DIR/lib/core/auth"
mkdir -p "$BASE_DIR/lib/core/firestore"

# Copy auth screens
echo "📄 Copying auth screens..."
cp lib/features/auth/presentation/screens/login_screen.dart \
   "$BASE_DIR/lib/features/auth/presentation/screens/" 2>/dev/null && echo "  ✓ login_screen.dart"

cp lib/features/auth/presentation/screens/signup_screen.dart \
   "$BASE_DIR/lib/features/auth/presentation/screens/" 2>/dev/null && echo "  ✓ signup_screen.dart"

cp lib/features/auth/presentation/screens/forgot_password_screen.dart \
   "$BASE_DIR/lib/features/auth/presentation/screens/" 2>/dev/null && echo "  ✓ forgot_password_screen.dart"

cp lib/features/auth/presentation/screens/change_password_screen.dart \
   "$BASE_DIR/lib/features/auth/presentation/screens/" 2>/dev/null && echo "  ✓ change_password_screen.dart"

cp lib/features/auth/presentation/screens/onboarding_screen.dart \
   "$BASE_DIR/lib/features/auth/presentation/screens/" 2>/dev/null && echo "  ✓ onboarding_screen.dart"

# Copy auth providers
echo "📄 Copying auth providers..."
cp lib/features/auth/presentation/providers/auth_providers.dart \
   "$BASE_DIR/lib/features/auth/presentation/providers/" 2>/dev/null && echo "  ✓ auth_providers.dart"

# Copy core auth
echo "📄 Copying core auth files..."
cp lib/core/auth/auth_repository.dart \
   "$BASE_DIR/lib/core/auth/" 2>/dev/null && echo "  ✓ auth_repository.dart"

cp lib/core/auth/root_auth_wrapper.dart \
   "$BASE_DIR/lib/core/auth/" 2>/dev/null && echo "  ✓ root_auth_wrapper.dart"

# Copy firestore service
echo "📄 Copying Firestore service..."
cp lib/core/firestore/firestore_service.dart \
   "$BASE_DIR/lib/core/firestore/" 2>/dev/null && echo "  ✓ firestore_service.dart"

echo ""
echo "✅ Developer 1 Version 3 files extracted successfully!"
echo "📊 Files extracted: 9"
echo ""
echo "📝 Next steps:"
echo "1. Review the extracted files in $BASE_DIR"
echo "2. Create Version 1 by simplifying these files (remove Firebase, use mocks)"
echo "3. Create Version 2 by adding Firebase but keeping error handling minimal"
echo ""
