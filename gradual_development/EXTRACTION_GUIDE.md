# File Extraction Guide

## 🎯 Purpose
This guide helps you extract files from the existing `lib/` folder and create 3 progressive versions for each developer.

## 📋 Extraction Strategy

### Step 1: Identify Your Files
Each developer should identify their files from the main `lib/` folder based on their responsibility.

### Step 2: Create 3 Versions
For each file, create 3 versions with increasing complexity:

#### Version 1: Basic Structure
- Remove all business logic
- Replace API calls with hardcoded data
- Remove Firebase/Firestore code
- Keep only UI structure
- Replace providers with simple print statements
- Use mock data

#### Version 2: Integration
- Add back business logic
- Add API/Firebase integration
- Add providers and state management
- Keep error handling minimal
- Add loading states

#### Version 3: Production (Copy from existing)
- Copy the complete file from existing `lib/` folder
- This is the final production-ready code

## 🔧 Automated Extraction Script

### For Developer 1 (Auth & Database Lead)

```bash
#!/bin/bash
# extract_dev1_files.sh

# Version 3 (Production) - Copy existing files
echo "Extracting Developer 1 files..."

# Create directory structure
mkdir -p gradual_development/developer_1_auth_database/version_3/lib/features/auth/presentation/screens
mkdir -p gradual_development/developer_1_auth_database/version_3/lib/features/auth/presentation/providers
mkdir -p gradual_development/developer_1_auth_database/version_3/lib/core/auth
mkdir -p gradual_development/developer_1_auth_database/version_3/lib/core/firestore

# Copy auth screens
cp lib/features/auth/presentation/screens/*.dart \
   gradual_development/developer_1_auth_database/version_3/lib/features/auth/presentation/screens/

# Copy auth providers
cp lib/features/auth/presentation/providers/*.dart \
   gradual_development/developer_1_auth_database/version_3/lib/features/auth/presentation/providers/

# Copy core auth
cp lib/core/auth/*.dart \
   gradual_development/developer_1_auth_database/version_3/lib/core/auth/

# Copy firestore service
cp lib/core/firestore/*.dart \
   gradual_development/developer_1_auth_database/version_3/lib/core/firestore/

echo "✅ Developer 1 Version 3 files extracted!"
```

### For Developer 2 (Movie API Specialist)

```bash
#!/bin/bash
# extract_dev2_files.sh

echo "Extracting Developer 2 files..."

# Create directory structure
mkdir -p gradual_development/developer_2_movie_api/version_3/lib/features/movies/data/datasources
mkdir -p gradual_development/developer_2_movie_api/version_3/lib/features/movies/data/models
mkdir -p gradual_development/developer_2_movie_api/version_3/lib/features/movies/data/repositories
mkdir -p gradual_development/developer_2_movie_api/version_3/lib/features/movies/domain/entities
mkdir -p gradual_development/developer_2_movie_api/version_3/lib/features/movies/domain/repositories
mkdir -p gradual_development/developer_2_movie_api/version_3/lib/features/movies/domain/usecases

# Copy data layer
cp lib/features/movies/data/datasources/*.dart \
   gradual_development/developer_2_movie_api/version_3/lib/features/movies/data/datasources/

cp lib/features/movies/data/models/*.dart \
   gradual_development/developer_2_movie_api/version_3/lib/features/movies/data/models/

cp lib/features/movies/data/repositories/*.dart \
   gradual_development/developer_2_movie_api/version_3/lib/features/movies/data/repositories/

# Copy domain layer
cp lib/features/movies/domain/entities/*.dart \
   gradual_development/developer_2_movie_api/version_3/lib/features/movies/domain/entities/

cp lib/features/movies/domain/repositories/*.dart \
   gradual_development/developer_2_movie_api/version_3/lib/features/movies/domain/repositories/

cp lib/features/movies/domain/usecases/*.dart \
   gradual_development/developer_2_movie_api/version_3/lib/features/movies/domain/usecases/

echo "✅ Developer 2 Version 3 files extracted!"
```

### For Developer 3 (UI/UX & Home Architect)

```bash
#!/bin/bash
# extract_dev3_files.sh

echo "Extracting Developer 3 files..."

# Create directory structure
mkdir -p gradual_development/developer_3_ui_home/version_3/lib/features/home/presentation/screens
mkdir -p gradual_development/developer_3_ui_home/version_3/lib/features/home/presentation/widgets
mkdir -p gradual_development/developer_3_ui_home/version_3/lib/features/movies/presentation/screens
mkdir -p gradual_development/developer_3_ui_home/version_3/lib/features/movies/presentation/widgets
mkdir -p gradual_development/developer_3_ui_home/version_3/lib/features/movies/presentation/notifiers
mkdir -p gradual_development/developer_3_ui_home/version_3/lib/features/movies/presentation/state
mkdir -p gradual_development/developer_3_ui_home/version_3/lib/features/movies/presentation/providers
mkdir -p gradual_development/developer_3_ui_home/version_3/lib/core/widgets

# Copy home feature
cp lib/features/home/presentation/screens/*.dart \
   gradual_development/developer_3_ui_home/version_3/lib/features/home/presentation/screens/

cp lib/features/home/presentation/widgets/*.dart \
   gradual_development/developer_3_ui_home/version_3/lib/features/home/presentation/widgets/

# Copy movies presentation
cp lib/features/movies/presentation/screens/*.dart \
   gradual_development/developer_3_ui_home/version_3/lib/features/movies/presentation/screens/

cp lib/features/movies/presentation/widgets/*.dart \
   gradual_development/developer_3_ui_home/version_3/lib/features/movies/presentation/widgets/

cp lib/features/movies/presentation/notifiers/*.dart \
   gradual_development/developer_3_ui_home/version_3/lib/features/movies/presentation/notifiers/

cp lib/features/movies/presentation/state/*.dart \
   gradual_development/developer_3_ui_home/version_3/lib/features/movies/presentation/state/

cp lib/features/movies/presentation/providers/*.dart \
   gradual_development/developer_3_ui_home/version_3/lib/features/movies/presentation/providers/

# Copy core widgets
cp lib/core/widgets/*.dart \
   gradual_development/developer_3_ui_home/version_3/lib/core/widgets/

echo "✅ Developer 3 Version 3 files extracted!"
```

### For Developer 4 (Watchlist & Rating)

```bash
#!/bin/bash
# extract_dev4_files.sh

echo "Extracting Developer 4 files..."

# Create directory structure for watchlist
mkdir -p gradual_development/developer_4_features/version_3/lib/features/watchlist/data/datasources
mkdir -p gradual_development/developer_4_features/version_3/lib/features/watchlist/data/models
mkdir -p gradual_development/developer_4_features/version_3/lib/features/watchlist/data/repositories
mkdir -p gradual_development/developer_4_features/version_3/lib/features/watchlist/data/services
mkdir -p gradual_development/developer_4_features/version_3/lib/features/watchlist/domain/entities
mkdir -p gradual_development/developer_4_features/version_3/lib/features/watchlist/domain/repositories
mkdir -p gradual_development/developer_4_features/version_3/lib/features/watchlist/domain/usecases
mkdir -p gradual_development/developer_4_features/version_3/lib/features/watchlist/presentation/screens
mkdir -p gradual_development/developer_4_features/version_3/lib/features/watchlist/presentation/widgets
mkdir -p gradual_development/developer_4_features/version_3/lib/features/watchlist/presentation/providers

# Create directory structure for watched
mkdir -p gradual_development/developer_4_features/version_3/lib/features/watched/data/services
mkdir -p gradual_development/developer_4_features/version_3/lib/features/watched/presentation/screens
mkdir -p gradual_development/developer_4_features/version_3/lib/features/watched/presentation/widgets
mkdir -p gradual_development/developer_4_features/version_3/lib/features/watched/presentation/providers

# Copy watchlist files
cp -r lib/features/watchlist/* \
   gradual_development/developer_4_features/version_3/lib/features/watchlist/

# Copy watched files
cp -r lib/features/watched/* \
   gradual_development/developer_4_features/version_3/lib/features/watched/

echo "✅ Developer 4 Version 3 files extracted!"
```

### For Developer 5 (Core & DevOps)

```bash
#!/bin/bash
# extract_dev5_files.sh

echo "Extracting Developer 5 files..."

# Create directory structure
mkdir -p gradual_development/developer_5_core_devops/version_3/lib/app/router
mkdir -p gradual_development/developer_5_core_devops/version_3/lib/app/navigation
mkdir -p gradual_development/developer_5_core_devops/version_3/lib/core/di
mkdir -p gradual_development/developer_5_core_devops/version_3/lib/core/theme
mkdir -p gradual_development/developer_5_core_devops/version_3/lib/core/constants
mkdir -p gradual_development/developer_5_core_devops/version_3/lib/core/config
mkdir -p gradual_development/developer_5_core_devops/version_3/lib/core/error
mkdir -p gradual_development/developer_5_core_devops/version_3/lib/core/result
mkdir -p gradual_development/developer_5_core_devops/version_3/lib/core/providers
mkdir -p gradual_development/developer_5_core_devops/version_3/lib/core/localization
mkdir -p gradual_development/developer_5_core_devops/version_3/lib/l10n
mkdir -p gradual_development/developer_5_core_devops/version_3/lib/bootstrap/splash/widgets
mkdir -p gradual_development/developer_5_core_devops/version_3/lib/shared/models

# Copy main files
cp lib/main.dart gradual_development/developer_5_core_devops/version_3/lib/
cp lib/firebase_options.dart gradual_development/developer_5_core_devops/version_3/lib/

# Copy app structure
cp -r lib/app/* gradual_development/developer_5_core_devops/version_3/lib/app/

# Copy core files
cp lib/core/di/*.dart gradual_development/developer_5_core_devops/version_3/lib/core/di/
cp lib/core/theme/*.dart gradual_development/developer_5_core_devops/version_3/lib/core/theme/
cp lib/core/constants/*.dart gradual_development/developer_5_core_devops/version_3/lib/core/constants/
cp lib/core/config/*.dart gradual_development/developer_5_core_devops/version_3/lib/core/config/
cp lib/core/error/*.dart gradual_development/developer_5_core_devops/version_3/lib/core/error/
cp lib/core/result/*.dart gradual_development/developer_5_core_devops/version_3/lib/core/result/
cp lib/core/providers/*.dart gradual_development/developer_5_core_devops/version_3/lib/core/providers/
cp lib/core/localization/*.dart gradual_development/developer_5_core_devops/version_3/lib/core/localization/

# Copy localization
cp lib/l10n/*.arb gradual_development/developer_5_core_devops/version_3/lib/l10n/
cp lib/l10n/*.dart gradual_development/developer_5_core_devops/version_3/lib/l10n/

# Copy bootstrap
cp -r lib/bootstrap/* gradual_development/developer_5_core_devops/version_3/lib/bootstrap/

# Copy shared models
cp lib/shared/models/*.dart gradual_development/developer_5_core_devops/version_3/lib/shared/models/

echo "✅ Developer 5 Version 3 files extracted!"
```

## 🔄 Running All Extraction Scripts

### On Linux/Mac:
```bash
# Make scripts executable
chmod +x extract_dev*.sh

# Run all scripts
./extract_dev1_files.sh
./extract_dev2_files.sh
./extract_dev3_files.sh
./extract_dev4_files.sh
./extract_dev5_files.sh
```

### On Windows (PowerShell):
```powershell
# Run each script
bash extract_dev1_files.sh
bash extract_dev2_files.sh
bash extract_dev3_files.sh
bash extract_dev4_files.sh
bash extract_dev5_files.sh
```

## 📝 Creating Version 1 and Version 2

After extracting Version 3 (production files), you need to manually create Version 1 and Version 2 by simplifying the code:

### Version 1 Simplification Checklist:
- [ ] Remove all `import` statements for Firebase, HTTP, Riverpod
- [ ] Replace API calls with hardcoded JSON data
- [ ] Replace Firestore operations with print statements
- [ ] Remove form validation
- [ ] Remove error handling
- [ ] Replace StatefulWidget providers with simple setState
- [ ] Use hardcoded colors instead of theme
- [ ] Remove navigation (just print statements)

### Version 2 Simplification Checklist:
- [ ] Add back Firebase/HTTP imports
- [ ] Add back API calls
- [ ] Add back Riverpod providers
- [ ] Add basic form validation
- [ ] Add basic error handling (simple SnackBars)
- [ ] Add navigation
- [ ] Keep error handling minimal
- [ ] No caching or advanced features

## 🎯 Quick Reference

### File Ownership Matrix

| Feature | Developer | Version 1 | Version 2 | Version 3 |
|---------|-----------|-----------|-----------|-----------|
| Auth Screens | Dev 1 | UI only | + Firebase | + Error handling |
| Auth Repository | Dev 1 | Mock | Firebase | + Retry logic |
| Firestore Service | Dev 1 | Mock | Mock | Real Firestore |
| TMDB Data Source | Dev 2 | Hardcoded | HTTP calls | + Caching |
| Movie Models | Dev 2 | Basic | + fromJson | + Validation |
| Movie Repository | Dev 2 | Mock data | Real API | + Error handling |
| Home Screen | Dev 3 | Static UI | + Providers | + Animations |
| Movie Cards | Dev 3 | Hardcoded | Real data | + Cached images |
| Search | Dev 3 | Mock | Real search | + History |
| Watchlist Screen | Dev 4 | Static list | + Firestore | + Offline |
| Watchlist Repository | Dev 4 | Mock | Real CRUD | + Optimistic updates |
| Rating Widget | Dev 4 | Static | Interactive | + Persistence |
| Main.dart | Dev 5 | Basic app | + Router | + Firebase init |
| Router | Dev 5 | 2-3 routes | All routes | + Guards |
| Localization | Dev 5 | English only | English only | English + Amharic |

## ⚠️ Important Notes

1. **Always test after extraction** - Make sure files compile
2. **Check dependencies** - Each version has different dependencies
3. **Coordinate with team** - Don't modify shared files independently
4. **Document changes** - Add comments explaining what changed between versions
5. **Version control** - Commit each version separately

## 🆘 Troubleshooting

### Issue: "File not found"
- Check if the source file exists in `lib/`
- Verify the path is correct
- Make sure you're running from project root

### Issue: "Permission denied"
- On Linux/Mac: Run `chmod +x extract_dev*.sh`
- On Windows: Run PowerShell as Administrator

### Issue: "Directory already exists"
- Delete the gradual_development folder and start fresh
- Or use `-f` flag to force overwrite

## 📚 Additional Resources

- See `FILE_STRUCTURE.md` for complete file listing
- See `IMPLEMENTATION_GUIDE.md` for development workflow
- See individual developer README files for specific instructions
