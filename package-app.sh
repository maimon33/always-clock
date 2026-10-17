#!/bin/bash

# Package Always Clock as a distributable macOS app
# Set SIGN_IDENTITY ("Developer ID Application: Name (TEAMID)") and APPLE_TEAM_ID to sign for distribution.

set -e

cd "$(dirname "$0")"
source ./version.sh

APP_NAME="Always Clock"
BUILD_DIR="./build"
DIST_DIR="./dist"
APP_BUNDLE="$DIST_DIR/$APP_NAME.app"

echo "📦 Packaging Always Clock $VERSION ($BUILD_NUMBER)..."

rm -rf "$BUILD_DIR" "$DIST_DIR"
mkdir -p "$DIST_DIR"

DEVELOPER_DIR=$(xcode-select -p)
if [[ "$DEVELOPER_DIR" == *"CommandLineTools"* ]]; then
    echo "❌ Error: Full Xcode is required (not just command line tools)."
    echo "Please install Xcode and run: sudo xcode-select -s /Applications/Xcode.app/Contents/Developer"
    exit 1
fi

SIGNING_ARGS=()
if [ -n "$SIGN_IDENTITY" ]; then
    : "${APPLE_TEAM_ID:?APPLE_TEAM_ID must be set when SIGN_IDENTITY is set}"
    SIGNING_ARGS=(
        CODE_SIGN_STYLE=Manual
        "CODE_SIGN_IDENTITY=$SIGN_IDENTITY"
        "DEVELOPMENT_TEAM=$APPLE_TEAM_ID"
        "OTHER_CODE_SIGN_FLAGS=--timestamp"
    )
    echo "✍️  Signing with: $SIGN_IDENTITY"
fi

echo "🔨 Building release version..."

xcodebuild \
    -project AlwaysClock.xcodeproj \
    -scheme AlwaysClock \
    -configuration Release \
    -derivedDataPath "$BUILD_DIR" \
    -archivePath "$BUILD_DIR/AlwaysClock.xcarchive" \
    "MARKETING_VERSION=$VERSION" \
    "CURRENT_PROJECT_VERSION=$BUILD_NUMBER" \
    "${SIGNING_ARGS[@]}" \
    archive

echo "📋 Extracting app bundle..."

ARCHIVED_APP="$BUILD_DIR/AlwaysClock.xcarchive/Products/Applications/AlwaysClock.app"
if [ ! -d "$ARCHIVED_APP" ]; then
    echo "❌ Could not find app in archive:"
    ls -la "$BUILD_DIR/AlwaysClock.xcarchive/Products/Applications/" || true
    exit 1
fi

cp -R "$ARCHIVED_APP" "$APP_BUNDLE"

echo "🔍 Verifying app bundle..."

if [ ! -x "$APP_BUNDLE/Contents/MacOS/AlwaysClock" ]; then
    echo "❌ App executable not found or not executable"
    exit 1
fi

if [ -n "$SIGN_IDENTITY" ]; then
    codesign --verify --strict --deep --verbose=2 "$APP_BUNDLE"
fi

echo "📊 App bundle information:"
echo "  Bundle ID: $(plutil -extract CFBundleIdentifier raw "$APP_BUNDLE/Contents/Info.plist")"
echo "  Version: $(plutil -extract CFBundleShortVersionString raw "$APP_BUNDLE/Contents/Info.plist") ($(plutil -extract CFBundleVersion raw "$APP_BUNDLE/Contents/Info.plist"))"

echo "✅ Packaged: $APP_BUNDLE"
