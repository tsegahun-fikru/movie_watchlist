#!/bin/bash
# Extract Developer 2 (Movie API Specialist) files

echo "🚀 Extracting Developer 2 files..."
echo "Developer: Movie API Specialist"
echo "Files: TMDB data sources, models, repositories, domain layer"
echo ""

BASE_DIR="gradual_development/developer_2_movie_api/version_3"

# Create directory structure
echo "📁 Creating directory structure..."
mkdir -p "$BASE_DIR/lib/features/movies/data/datasources"
mkdir -p "$BASE_DIR/lib/features/movies/data/models"
mkdir -p "$BASE_DIR/lib/features/movies/data/repositories"
mkdir -p "$BASE_DIR/lib/features/movies/domain/entities"
mkdir -p "$BASE_DIR/lib/features/movies/domain/repositories"
mkdir -p "$BASE_DIR/lib/features/movies/domain/usecases"

# Copy data layer - datasources
echo "📄 Copying data sources..."
cp lib/features/movies/data/datasources/tmdb_remote_data_source.dart \
   "$BASE_DIR/lib/features/movies/data/datasources/" 2>/dev/null && echo "  ✓ tmdb_remote_data_source.dart"

# Copy data layer - models
echo "📄 Copying models..."
cp lib/features/movies/data/models/movie_model.dart \
   "$BASE_DIR/lib/features/movies/data/models/" 2>/dev/null && echo "  ✓ movie_model.dart"

# Copy data layer - repositories
echo "📄 Copying repositories..."
cp lib/features/movies/data/repositories/legacy_tmdb_repository.dart \
   "$BASE_DIR/lib/features/movies/data/repositories/" 2>/dev/null && echo "  ✓ legacy_tmdb_repository.dart"

cp lib/features/movies/data/repositories/movie_repository_impl.dart \
   "$BASE_DIR/lib/features/movies/data/repositories/" 2>/dev/null && echo "  ✓ movie_repository_impl.dart"

# Copy domain layer - entities
echo "📄 Copying entities..."
cp lib/features/movies/domain/entities/genre.dart \
   "$BASE_DIR/lib/features/movies/domain/entities/" 2>/dev/null && echo "  ✓ genre.dart"

cp lib/features/movies/domain/entities/movie_filters.dart \
   "$BASE_DIR/lib/features/movies/domain/entities/" 2>/dev/null && echo "  ✓ movie_filters.dart"

cp lib/features/movies/domain/entities/movie_page.dart \
   "$BASE_DIR/lib/features/movies/domain/entities/" 2>/dev/null && echo "  ✓ movie_page.dart"

cp lib/features/movies/domain/entities/movie.dart \
   "$BASE_DIR/lib/features/movies/domain/entities/" 2>/dev/null && echo "  ✓ movie.dart"

# Copy domain layer - repositories
echo "📄 Copying domain repositories..."
cp lib/features/movies/domain/repositories/movie_repository.dart \
   "$BASE_DIR/lib/features/movies/domain/repositories/" 2>/dev/null && echo "  ✓ movie_repository.dart"

# Copy domain layer - use cases
echo "📄 Copying use cases..."
cp lib/features/movies/domain/usecases/get_movie_genres_use_case.dart \
   "$BASE_DIR/lib/features/movies/domain/usecases/" 2>/dev/null && echo "  ✓ get_movie_genres_use_case.dart"

cp lib/features/movies/domain/usecases/get_trending_movies_use_case.dart \
   "$BASE_DIR/lib/features/movies/domain/usecases/" 2>/dev/null && echo "  ✓ get_trending_movies_use_case.dart"

cp lib/features/movies/domain/usecases/search_movies_use_case.dart \
   "$BASE_DIR/lib/features/movies/domain/usecases/" 2>/dev/null && echo "  ✓ search_movies_use_case.dart"

echo ""
echo "✅ Developer 2 Version 3 files extracted successfully!"
echo "📊 Files extracted: 12"
echo ""
echo "📝 Next steps:"
echo "1. Review the extracted files in $BASE_DIR"
echo "2. Create Version 1 with hardcoded JSON data (no HTTP calls)"
echo "3. Create Version 2 with real HTTP calls but minimal error handling"
echo ""
