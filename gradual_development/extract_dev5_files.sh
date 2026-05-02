#!/bin/bash
# Extract Developer 5 (Core & DevOps Engineer) files

echo "🚀 Extracting Developer 5 files..."
echo "Developer: Core & DevOps Engineer"
echo "Files: Main app, routing, DI, localization, shared models"
echo ""

BASE_DIR="gradual_development/developer_5_core_devops/version_3"

# Create directory structure
echo "📁 Creating directory structure..."
mkdir -p "$BASE_DIR/lib/app/router"
mkdir -p "$BASE_DIR/lib/app/navigation"
mkdir -p "$BASE_DIR/lib/core/di"
mkdir -p "$BASE_DIR/lib/core/theme"
mkdir -p "$BASE_DIR/lib/core/constants"
mkdir -p "$BASE_DIR/lib/core/config"
mkdir -p "$BASE_DIR/lib/core/error"
mkdir -p "$BASE_DIR/lib/core/result"
mkdir -p "$BASE_DIR/lib/core/providers"
mkdir -p "$BASE_DIR/lib/core/localization"
mkdir -p "$BASE_DIR/lib/l10n"
mkdir -p "$BASE_DIR/lib/bootstrap/splash/widgets"
mkdir -p "$BASE_DIR/lib/shared/models"

# Copy main files
echo "📄 Copying main application files..."
cp lib/main.dart "$BASE_DIR/lib/" 2>/dev/null && echo "  ✓ main.dart"
cp lib/firebase_options.dart "$BASE_DIR/lib/" 2>/dev/null && echo "  ✓ firebase_options.dart"

# Copy app structure
echo "📄 Copying app router..."
cp lib/app/router/app_router.dart \
   "$BASE_DIR/lib/app/router/" 2>/dev/null && echo "  ✓ app_router.dart"

echo "📄 Copying app navigation..."
cp lib/app/navigation/main_navigation_wrapper.dart \
   "$BASE_DIR/lib/app/navigation/" 2>/dev/null && echo "  ✓ main_navigation_wrapper.dart"

# Copy core DI
echo "📄 Copying dependency injection..."
cp lib/core/di/clean_arch_providers.dart \
   "$BASE_DIR/lib/core/di/" 2>/dev/null && echo "  ✓ clean_arch_providers.dart"

# Copy core theme
echo "📄 Copying theme files..."
cp lib/core/theme/app_colors.dart \
   "$BASE_DIR/lib/core/theme/" 2>/dev/null && echo "  ✓ app_colors.dart"

cp lib/core/theme/app_theme.dart \
   "$BASE_DIR/lib/core/theme/" 2>/dev/null && echo "  ✓ app_theme.dart"

# Copy core constants
echo "📄 Copying constants..."
cp lib/core/constants/constants.dart \
   "$BASE_DIR/lib/core/constants/" 2>/dev/null && echo "  ✓ constants.dart"

cp lib/core/constants/app_strings.dart \
   "$BASE_DIR/lib/core/constants/" 2>/dev/null && echo "  ✓ app_strings.dart"

# Copy core config
echo "📄 Copying configuration..."
cp lib/core/config/api_key.dart \
   "$BASE_DIR/lib/core/config/" 2>/dev/null && echo "  ✓ api_key.dart"

# Copy core error
echo "📄 Copying error handling..."
cp lib/core/error/exceptions.dart \
   "$BASE_DIR/lib/core/error/" 2>/dev/null && echo "  ✓ exceptions.dart"

cp lib/core/error/failures.dart \
   "$BASE_DIR/lib/core/error/" 2>/dev/null && echo "  ✓ failures.dart"

# Copy core result
echo "📄 Copying result type..."
cp lib/core/result/result.dart \
   "$BASE_DIR/lib/core/result/" 2>/dev/null && echo "  ✓ result.dart"

# Copy core providers
echo "📄 Copying core providers..."
cp lib/core/providers/core_providers.dart \
   "$BASE_DIR/lib/core/providers/" 2>/dev/null && echo "  ✓ core_providers.dart"

# Copy core localization
echo "📄 Copying localization provider..."
cp lib/core/localization/locale_provider.dart \
   "$BASE_DIR/lib/core/localization/" 2>/dev/null && echo "  ✓ locale_provider.dart"

# Copy localization files
echo "📄 Copying localization files..."
cp lib/l10n/app_en.arb \
   "$BASE_DIR/lib/l10n/" 2>/dev/null && echo "  ✓ app_en.arb"

cp lib/l10n/app_am.arb \
   "$BASE_DIR/lib/l10n/" 2>/dev/null && echo "  ✓ app_am.arb"

cp lib/l10n/app_localizations.dart \
   "$BASE_DIR/lib/l10n/" 2>/dev/null && echo "  ✓ app_localizations.dart"

cp lib/l10n/app_localizations_en.dart \
   "$BASE_DIR/lib/l10n/" 2>/dev/null && echo "  ✓ app_localizations_en.dart"

cp lib/l10n/app_localizations_am.dart \
   "$BASE_DIR/lib/l10n/" 2>/dev/null && echo "  ✓ app_localizations_am.dart"

# Copy bootstrap
echo "📄 Copying bootstrap files..."
cp lib/bootstrap/app_startup.dart \
   "$BASE_DIR/lib/bootstrap/" 2>/dev/null && echo "  ✓ app_startup.dart"

cp lib/bootstrap/splash/splash_screen.dart \
   "$BASE_DIR/lib/bootstrap/splash/" 2>/dev/null && echo "  ✓ splash_screen.dart"

# Copy splash widgets if they exist
if [ -d "lib/bootstrap/splash/widgets" ]; then
    cp lib/bootstrap/splash/widgets/*.dart \
       "$BASE_DIR/lib/bootstrap/splash/widgets/" 2>/dev/null && echo "  ✓ splash widgets"
fi

# Copy shared models
echo "📄 Copying shared models..."
cp lib/shared/models/movie.dart \
   "$BASE_DIR/lib/shared/models/" 2>/dev/null && echo "  ✓ movie.dart"

cp lib/shared/models/tv_show.dart \
   "$BASE_DIR/lib/shared/models/" 2>/dev/null && echo "  ✓ tv_show.dart"

cp lib/shared/models/cast_members.dart \
   "$BASE_DIR/lib/shared/models/" 2>/dev/null && echo "  ✓ cast_members.dart"

cp lib/shared/models/tv_episode.dart \
   "$BASE_DIR/lib/shared/models/" 2>/dev/null && echo "  ✓ tv_episode.dart"

cp lib/shared/models/search_result_item.dart \
   "$BASE_DIR/lib/shared/models/" 2>/dev/null && echo "  ✓ search_result_item.dart"

echo ""
echo "✅ Developer 5 Version 3 files extracted successfully!"
echo "📊 Files extracted: ~25"
echo ""
echo "📝 Next steps:"
echo "1. Review the extracted files in $BASE_DIR"
echo "2. Create Version 1 with basic MaterialApp (no routing, no Firebase)"
echo "3. Create Version 2 with GoRouter and Firebase initialization"
echo ""
