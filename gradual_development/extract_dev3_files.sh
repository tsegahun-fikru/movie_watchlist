#!/bin/bash
# Extract Developer 3 (UI/UX & Home Architect) files

echo "🚀 Extracting Developer 3 files..."
echo "Developer: UI/UX & Home Architect"
echo "Files: Home screens, Movie presentation, Core widgets"
echo ""

BASE_DIR="gradual_development/developer_3_ui_home/version_3"

# Create directory structure
echo "📁 Creating directory structure..."
mkdir -p "$BASE_DIR/lib/features/home/presentation/screens"
mkdir -p "$BASE_DIR/lib/features/home/presentation/widgets"
mkdir -p "$BASE_DIR/lib/features/movies/presentation/screens"
mkdir -p "$BASE_DIR/lib/features/movies/presentation/widgets"
mkdir -p "$BASE_DIR/lib/features/movies/presentation/notifiers"
mkdir -p "$BASE_DIR/lib/features/movies/presentation/state"
mkdir -p "$BASE_DIR/lib/features/movies/presentation/providers"
mkdir -p "$BASE_DIR/lib/core/widgets"

# Copy home feature
echo "📄 Copying home screens..."
cp lib/features/home/presentation/screens/home_screen.dart \
   "$BASE_DIR/lib/features/home/presentation/screens/" 2>/dev/null && echo "  ✓ home_screen.dart"

echo "📄 Copying home widgets..."
cp lib/features/home/presentation/widgets/auto_carousel.dart \
   "$BASE_DIR/lib/features/home/presentation/widgets/" 2>/dev/null && echo "  ✓ auto_carousel.dart"

cp lib/features/home/presentation/widgets/filter_provider.dart \
   "$BASE_DIR/lib/features/home/presentation/widgets/" 2>/dev/null && echo "  ✓ filter_provider.dart"

cp lib/features/home/presentation/widgets/movie_search_delegate.dart \
   "$BASE_DIR/lib/features/home/presentation/widgets/" 2>/dev/null && echo "  ✓ movie_search_delegate.dart"

cp lib/features/home/presentation/widgets/recommendations_row.dart \
   "$BASE_DIR/lib/features/home/presentation/widgets/" 2>/dev/null && echo "  ✓ recommendations_row.dart"

cp lib/features/home/presentation/widgets/search_history_widget.dart \
   "$BASE_DIR/lib/features/home/presentation/widgets/" 2>/dev/null && echo "  ✓ search_history_widget.dart"

# Copy movies presentation
echo "📄 Copying movie presentation screens..."
cp lib/features/movies/presentation/screens/genre_browse_screen.dart \
   "$BASE_DIR/lib/features/movies/presentation/screens/" 2>/dev/null && echo "  ✓ genre_browse_screen.dart"

echo "📄 Copying movie presentation widgets..."
cp lib/features/movies/presentation/widgets/movie_search_filter_bar.dart \
   "$BASE_DIR/lib/features/movies/presentation/widgets/" 2>/dev/null && echo "  ✓ movie_search_filter_bar.dart"

cp lib/features/movies/presentation/widgets/movie_search_result_list.dart \
   "$BASE_DIR/lib/features/movies/presentation/widgets/" 2>/dev/null && echo "  ✓ movie_search_result_list.dart"

cp lib/features/movies/presentation/widgets/tv_search_filter_bar.dart \
   "$BASE_DIR/lib/features/movies/presentation/widgets/" 2>/dev/null && echo "  ✓ tv_search_filter_bar.dart"

echo "📄 Copying movie notifiers..."
cp lib/features/movies/presentation/notifiers/movie_search_notifier.dart \
   "$BASE_DIR/lib/features/movies/presentation/notifiers/" 2>/dev/null && echo "  ✓ movie_search_notifier.dart"

cp lib/features/movies/presentation/notifiers/tv_search_notifier.dart \
   "$BASE_DIR/lib/features/movies/presentation/notifiers/" 2>/dev/null && echo "  ✓ tv_search_notifier.dart"

echo "📄 Copying movie state..."
cp lib/features/movies/presentation/state/movie_search_state.dart \
   "$BASE_DIR/lib/features/movies/presentation/state/" 2>/dev/null && echo "  ✓ movie_search_state.dart"

cp lib/features/movies/presentation/state/tv_search_state.dart \
   "$BASE_DIR/lib/features/movies/presentation/state/" 2>/dev/null && echo "  ✓ tv_search_state.dart"

echo "📄 Copying movie providers..."
cp lib/features/movies/presentation/providers/movie_providers.dart \
   "$BASE_DIR/lib/features/movies/presentation/providers/" 2>/dev/null && echo "  ✓ movie_providers.dart"

# Copy core widgets
echo "📄 Copying core widgets..."
cp lib/core/widgets/movie_card.dart \
   "$BASE_DIR/lib/core/widgets/" 2>/dev/null && echo "  ✓ movie_card.dart"

cp lib/core/widgets/tv_show_card.dart \
   "$BASE_DIR/lib/core/widgets/" 2>/dev/null && echo "  ✓ tv_show_card.dart"

cp lib/core/widgets/movie_card_skeleton.dart \
   "$BASE_DIR/lib/core/widgets/" 2>/dev/null && echo "  ✓ movie_card_skeleton.dart"

cp lib/core/widgets/shimmer_loading.dart \
   "$BASE_DIR/lib/core/widgets/" 2>/dev/null && echo "  ✓ shimmer_loading.dart"

cp lib/core/widgets/custom_app_bar.dart \
   "$BASE_DIR/lib/core/widgets/" 2>/dev/null && echo "  ✓ custom_app_bar.dart"

# Copy button widgets if they exist
if [ -d "lib/core/widgets/buttons" ]; then
    mkdir -p "$BASE_DIR/lib/core/widgets/buttons"
    cp lib/core/widgets/buttons/*.dart \
       "$BASE_DIR/lib/core/widgets/buttons/" 2>/dev/null && echo "  ✓ button widgets"
fi

echo ""
echo "✅ Developer 3 Version 3 files extracted successfully!"
echo "📊 Files extracted: ~18"
echo ""
echo "📝 Next steps:"
echo "1. Review the extracted files in $BASE_DIR"
echo "2. Create Version 1 with hardcoded movie data (no providers)"
echo "3. Create Version 2 with Riverpod providers and real data"
echo ""
