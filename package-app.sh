#!/bin/bash

# Package Always Clock as a distributable macOS app

set -e

APP_NAME="Always Clock"
BUNDLE_ID="com.alwaysclock.app"
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
BUILD_DIR="./build"
DIST_DIR="./dist"
APP_BUNDLE="$DIST_DIR/$APP_NAME.app"

echo "📦 Packaging Always Clock for distribution..."

# Clean previous builds
rm -rf "$BUILD_DIR"
rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"

# Check if we have full Xcode
DEVELOPER_DIR=$(xcode-select -p)
if [[ "$DEVELOPER_DIR" == *"CommandLineTools"* ]]; then
    echo "❌ Error: Full Xcode is required (not just command line tools)."
    echo "Please install Xcode from the Mac App Store and run:"
    echo "sudo xcode-select -s /Applications/Xcode.app/Contents/Developer"
    exit 1
fi

echo "🔨 Building release version..."

# Build for release
xcodebuild \
    -project AlwaysClock.xcodeproj \
    -scheme AlwaysClock \
    -configuration Release \
    -derivedDataPath "$BUILD_DIR" \
    -archivePath "$BUILD_DIR/AlwaysClock.xcarchive" \
    archive

echo "📋 Extracting app bundle..."

# Find the actual app name in the archive
if [ -d "$BUILD_DIR/AlwaysClock.xcarchive/Products/Applications/AlwaysClock.app" ]; then
    APP_SOURCE="$BUILD_DIR/AlwaysClock.xcarchive/Products/Applications/AlwaysClock.app"
elif [ -d "$BUILD_DIR/AlwaysClock.xcarchive/Products/Applications/Always Clock.app" ]; then
    APP_SOURCE="$BUILD_DIR/AlwaysClock.xcarchive/Products/Applications/Always Clock.app"
else
    echo "❌ Could not find app in archive. Available files:"
    ls -la "$BUILD_DIR/AlwaysClock.xcarchive/Products/Applications/" || echo "Applications directory not found"
    exit 1
fi

# Copy the app bundle to dist
cp -R "$APP_SOURCE" "$APP_BUNDLE"

echo "🔍 Verifying app bundle..."

# Verify the app bundle structure
if [ ! -d "$APP_BUNDLE" ]; then
    echo "❌ App bundle not found at expected location"
    exit 1
fi

# Check if app is executable
if [ ! -x "$APP_BUNDLE/Contents/MacOS/AlwaysClock" ]; then
    echo "❌ App executable not found or not executable"
    exit 1
fi

echo "📊 App bundle information:"
echo "  Bundle ID: $(plutil -p "$APP_BUNDLE/Contents/Info.plist" | grep CFBundleIdentifier | cut -d'"' -f4)"
echo "  Version: $(plutil -p "$APP_BUNDLE/Contents/Info.plist" | grep CFBundleShortVersionString | cut -d'"' -f4)"
echo "  Size: $(du -h "$APP_BUNDLE" | tail -1 | cut -f1)"

echo "✅ Successfully packaged: $APP_BUNDLE"
echo ""
echo "To test the app:"
echo "  open '$APP_BUNDLE'"
echo ""
echo "To install the app:"
echo "  cp -R '$APP_BUNDLE' /Applications/"
echo ""
echo "To create a DMG installer, run:"
echo "  ./create-dmg.sh"