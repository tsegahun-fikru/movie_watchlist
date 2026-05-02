#!/bin/bash
# Extract Developer 4 (Feature Developer - Watchlist & Rating) files

echo "🚀 Extracting Developer 4 files..."
echo "Developer: Feature Developer (Watchlist & Rating)"
echo "Files: Watchlist feature, Watched feature"
echo ""

BASE_DIR="gradual_development/developer_4_features/version_3"

# Create directory structure for watchlist
echo "📁 Creating watchlist directory structure..."
mkdir -p "$BASE_DIR/lib/features/watchlist/data/datasources"
mkdir -p "$BASE_DIR/lib/features/watchlist/data/models"
mkdir -p "$BASE_DIR/lib/features/watchlist/data/repositories"
mkdir -p "$BASE_DIR/lib/features/watchlist/data/services"
mkdir -p "$BASE_DIR/lib/features/watchlist/domain/entities"
mkdir -p "$BASE_DIR/lib/features/watchlist/domain/repositories"
mkdir -p "$BASE_DIR/lib/features/watchlist/domain/usecases"
mkdir -p "$BASE_DIR/lib/features/watchlist/presentation/screens"
mkdir -p "$BASE_DIR/lib/features/watchlist/presentation/widgets"
mkdir -p "$BASE_DIR/lib/features/watchlist/presentation/providers"

# Create directory structure for watched
echo "📁 Creating watched directory structure..."
mkdir -p "$BASE_DIR/lib/features/watched/data/services"
mkdir -p "$BASE_DIR/lib/features/watched/presentation/screens"
mkdir -p "$BASE_DIR/lib/features/watched/presentation/widgets"
mkdir -p "$BASE_DIR/lib/features/watched/presentation/providers"

# Copy watchlist data layer
echo "📄 Copying watchlist data sources..."
cp lib/features/watchlist/data/datasources/firestore_watchlist_data_source.dart \
   "$BASE_DIR/lib/features/watchlist/data/datasources/" 2>/dev/null && echo "  ✓ firestore_watchlist_data_source.dart"

echo "📄 Copying watchlist models..."
cp lib/features/watchlist/data/models/watchlist_item_model.dart \
   "$BASE_DIR/lib/features/watchlist/data/models/" 2>/dev/null && echo "  ✓ watchlist_item_model.dart"

cp lib/features/watchlist/data/models/watchlist_item.dart \
   "$BASE_DIR/lib/features/watchlist/data/models/" 2>/dev/null && echo "  ✓ watchlist_item.dart"

echo "📄 Copying watchlist repositories..."
cp lib/features/watchlist/data/repositories/watchlist_repository_impl.dart \
   "$BASE_DIR/lib/features/watchlist/data/repositories/" 2>/dev/null && echo "  ✓ watchlist_repository_impl.dart"

echo "📄 Copying watchlist services..."
cp lib/features/watchlist/data/services/watchlist_service.dart \
   "$BASE_DIR/lib/features/watchlist/data/services/" 2>/dev/null && echo "  ✓ watchlist_service.dart"

# Copy watchlist domain layer
echo "📄 Copying watchlist entities..."
cp lib/features/watchlist/domain/entities/watchlist_item.dart \
   "$BASE_DIR/lib/features/watchlist/domain/entities/" 2>/dev/null && echo "  ✓ watchlist_item.dart"

echo "📄 Copying watchlist domain repositories..."
cp lib/features/watchlist/domain/repositories/watchlist_repository.dart \
   "$BASE_DIR/lib/features/watchlist/domain/repositories/" 2>/dev/null && echo "  ✓ watchlist_repository.dart"

echo "📄 Copying watchlist use cases..."
cp lib/features/watchlist/domain/usecases/add_to_watchlist_use_case.dart \
   "$BASE_DIR/lib/features/watchlist/domain/usecases/" 2>/dev/null && echo "  ✓ add_to_watchlist_use_case.dart"

cp lib/features/watchlist/domain/usecases/get_watchlist_use_case.dart \
   "$BASE_DIR/lib/features/watchlist/domain/usecases/" 2>/dev/null && echo "  ✓ get_watchlist_use_case.dart"

cp lib/features/watchlist/domain/usecases/remove_from_watchlist_use_case.dart \
   "$BASE_DIR/lib/features/watchlist/domain/usecases/" 2>/dev/null && echo "  ✓ remove_from_watchlist_use_case.dart"

# Copy watchlist presentation layer
echo "📄 Copying watchlist screens..."
cp lib/features/watchlist/presentation/screens/watchlist_screen.dart \
   "$BASE_DIR/lib/features/watchlist/presentation/screens/" 2>/dev/null && echo "  ✓ watchlist_screen.dart"

echo "📄 Copying watchlist widgets..."
cp lib/features/watchlist/presentation/widgets/watchlist_card.dart \
   "$BASE_DIR/lib/features/watchlist/presentation/widgets/" 2>/dev/null && echo "  ✓ watchlist_card.dart"

echo "📄 Copying watchlist providers..."
cp lib/features/watchlist/presentation/providers/watchlist_providers.dart \
   "$BASE_DIR/lib/features/watchlist/presentation/providers/" 2>/dev/null && echo "  ✓ watchlist_providers.dart"

# Copy watched feature
echo "📄 Copying watched services..."
cp lib/features/watched/data/services/watched_service.dart \
   "$BASE_DIR/lib/features/watched/data/services/" 2>/dev/null && echo "  ✓ watched_service.dart"

echo "📄 Copying watched screens..."
cp lib/features/watched/presentation/screens/watched_screen.dart \
   "$BASE_DIR/lib/features/watched/presentation/screens/" 2>/dev/null && echo "  ✓ watched_screen.dart"

echo "📄 Copying watched widgets..."
cp lib/features/watched/presentation/widgets/user_rating_bar.dart \
   "$BASE_DIR/lib/features/watched/presentation/widgets/" 2>/dev/null && echo "  ✓ user_rating_bar.dart"

cp lib/features/watched/presentation/widgets/watched_button.dart \
   "$BASE_DIR/lib/features/watched/presentation/widgets/" 2>/dev/null && echo "  ✓ watched_button.dart"

echo "📄 Copying watched providers..."
cp lib/features/watched/presentation/providers/watched_providers.dart \
   "$BASE_DIR/lib/features/watched/presentation/providers/" 2>/dev/null && echo "  ✓ watched_providers.dart"

echo ""
echo "✅ Developer 4 Version 3 files extracted successfully!"
echo "📊 Files extracted: ~16"
echo ""
echo "📝 Next steps:"
echo "1. Review the extracted files in $BASE_DIR"
echo "2. Create Version 1 with hardcoded watchlist data (no Firestore)"
echo "3. Create Version 2 with Firestore integration but minimal error handling"
echo ""
