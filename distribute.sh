#!/bin/bash

# Complete distribution script for Always Clock
# This script builds, packages, and creates all distribution formats

set -e

APP_NAME="Always Clock"
# Get version from git tag or environment variable
if [ -n "$GITHUB_REF" ] && [[ $GITHUB_REF == refs/tags/* ]]; then
    VERSION=${GITHUB_REF#refs/tags/v}
elif [ -n "$VERSION" ]; then
    # Use environment variable if set
    VERSION="$VERSION"
else
    # Fallback to git tag or default
    VERSION=$(git describe --tags --abbrev=0 2>/dev/null | sed 's/^v//' || echo "1.0")
fi
DIST_DIR="./dist"

echo "🚀 Always Clock - Complete Distribution Build"
echo "=============================================="

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf build dist
mkdir -p "$DIST_DIR"

# Step 1: Create app icon (if needed)
if [ ! -d "AlwaysClock/Assets.xcassets/AppIcon.appiconset" ]; then
    echo ""
    echo "🎨 Creating app icon..."
    ./create-icon.sh
fi

# Step 2: Build and package the app
echo ""
echo "📦 Building and packaging app..."
./package-app.sh

if [ ! -d "$DIST_DIR/$APP_NAME.app" ]; then
    echo "❌ App packaging failed!"
    exit 1
fi

# Step 3: Create DMG
echo ""
echo "💿 Creating DMG installer..."
./create-dmg.sh

# Step 4: Create PKG
echo ""
echo "📦 Creating PKG installer..."
./create-pkg.sh

# Step 5: Create ZIP archive (for easy sharing)
echo ""
echo "🗜️  Creating ZIP archive..."
cd "$DIST_DIR"
zip -r "Always-Clock-v$VERSION.zip" "$APP_NAME.app" > /dev/null
cd ..

echo ""
echo "✅ Distribution build complete!"
echo "================================================="
echo ""

# Display results
if [ -d "$DIST_DIR" ]; then
    echo "📄 Distribution files created:"
    echo ""
    for file in "$DIST_DIR"/*; do
        if [ -f "$file" ] || [ -d "$file" ]; then
            filename=$(basename "$file")
            size=""
            if [ -f "$file" ]; then
                size=" ($(du -h "$file" | cut -f1))"
            elif [ -d "$file" ]; then
                size=" ($(du -sh "$file" | cut -f1))"
            fi
            echo "  📎 $filename$size"
        fi
    done

    echo ""
    echo "🎯 Distribution options:"
    echo ""
    echo "1. 📱 Standalone App Bundle:"
    echo "   • File: $DIST_DIR/$APP_NAME.app"
    echo "   • Usage: Drag to Applications folder"
    echo "   • Best for: Direct distribution, testing"
    echo ""
    echo "2. 💿 DMG Installer:"
    echo "   • File: $DIST_DIR/Always-Clock-v$VERSION.dmg"
    echo "   • Usage: Double-click to mount, drag app to Applications"
    echo "   • Best for: Mac App Store style distribution"
    echo ""
    echo "3. 📦 PKG Installer:"
    echo "   • File: $DIST_DIR/Always-Clock-v$VERSION.pkg"
    echo "   • Usage: Double-click to run installer wizard"
    echo "   • Best for: Enterprise distribution, automatic installation"
    echo ""
    echo "4. 🗜️  ZIP Archive:"
    echo "   • File: $DIST_DIR/Always-Clock-v$VERSION.zip"
    echo "   • Usage: Download and extract, then drag to Applications"
    echo "   • Best for: Web distribution, GitHub releases"
    echo ""

    echo "🧪 Testing:"
    echo "  Test the app: open '$DIST_DIR/$APP_NAME.app'"
    echo "  Test the DMG: open '$DIST_DIR/Always-Clock-v$VERSION.dmg'"
    echo ""

    echo "📊 Total size of all distribution files:"
    du -sh "$DIST_DIR" | cut -f1
else
    echo "❌ No distribution files were created!"
    exit 1
fi

echo ""
echo "🎉 Ready for distribution!"