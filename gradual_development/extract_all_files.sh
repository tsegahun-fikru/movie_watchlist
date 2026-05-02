#!/bin/bash
# Master script to extract all developer files at once

echo "╔════════════════════════════════════════════════════════════╗"
echo "║   Movie Watchlist - Complete File Extraction Script       ║"
echo "║   Extracting files for all 5 developers                   ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Check if we're in the right directory
if [ ! -d "lib" ]; then
    echo "❌ Error: lib/ directory not found!"
    echo "Please run this script from the project root directory."
    exit 1
fi

echo "📍 Current directory: $(pwd)"
echo "✓ lib/ directory found"
echo ""

# Run extraction for each developer
echo "═══════════════════════════════════════════════════════════"
echo "Developer 1: Auth & Database Lead"
echo "═══════════════════════════════════════════════════════════"
bash gradual_development/extract_dev1_files.sh
echo ""

echo "═══════════════════════════════════════════════════════════"
echo "Developer 2: Movie API Specialist"
echo "═══════════════════════════════════════════════════════════"
bash gradual_development/extract_dev2_files.sh
echo ""

echo "═══════════════════════════════════════════════════════════"
echo "Developer 3: UI/UX & Home Architect"
echo "═══════════════════════════════════════════════════════════"
bash gradual_development/extract_dev3_files.sh
echo ""

echo "═══════════════════════════════════════════════════════════"
echo "Developer 4: Feature Developer (Watchlist & Rating)"
echo "═══════════════════════════════════════════════════════════"
bash gradual_development/extract_dev4_files.sh
echo ""

echo "═══════════════════════════════════════════════════════════"
echo "Developer 5: Core & DevOps Engineer"
echo "═══════════════════════════════════════════════════════════"
bash gradual_development/extract_dev5_files.sh
echo ""

echo "╔════════════════════════════════════════════════════════════╗"
echo "║                  EXTRACTION COMPLETE! 🎉                   ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "📊 Summary:"
echo "  • Developer 1: 9 files extracted"
echo "  • Developer 2: 12 files extracted"
echo "  • Developer 3: 18 files extracted"
echo "  • Developer 4: 16 files extracted"
echo "  • Developer 5: 25 files extracted"
echo "  ─────────────────────────────────"
echo "  • Total: ~80 files extracted"
echo ""
echo "📁 Files location: gradual_development/developer_*/version_3/"
echo ""
echo "📝 Next Steps:"
echo "1. Review extracted files in each developer folder"
echo "2. Create Version 1 files (simplified, no Firebase/API)"
echo "3. Create Version 2 files (add Firebase/API, minimal error handling)"
echo "4. Distribute folders to respective developers"
echo "5. Follow the git workflow in IMPLEMENTATION_GUIDE.md"
echo ""
echo "📚 Documentation:"
echo "  • README.md - Project overview"
echo "  • IMPLEMENTATION_GUIDE.md - Development workflow"
echo "  • EXTRACTION_GUIDE.md - File extraction details"
echo "  • FILE_STRUCTURE.md - Complete file listing"
echo ""
echo "✨ Happy coding!"
