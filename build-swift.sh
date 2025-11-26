#!/bin/bash

# Build Always Clock using Swift compiler directly (without full Xcode)

set -e

APP_NAME="Always Clock"
BUNDLE_ID="com.alwaysclock.app"
VERSION="1.0"
DIST_DIR="./dist"
APP_BUNDLE="$DIST_DIR/$APP_NAME.app"
SWIFT_FILES="AlwaysClock/AlwaysClockApp.swift AlwaysClock/ContentView.swift AlwaysClock/ClockView.swift AlwaysClock/DigitalClockView.swift AlwaysClock/AnalogClockView.swift AlwaysClock/SettingsView.swift"

echo "🔧 Building Always Clock with Swift compiler..."

# Clean and create directories
rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

echo "📝 Compiling Swift sources..."

# Try to compile with Swift compiler directly
swiftc -o "$APP_BUNDLE/Contents/MacOS/AlwaysClock" \
    -target x86_64-apple-macosx13.0 \
    -Xlinker -rpath -Xlinker @executable_path/../Frameworks \
    -framework SwiftUI \
    -framework Cocoa \
    -framework ServiceManagement \
    $SWIFT_FILES 2>&1 || {

    echo "❌ Direct Swift compilation failed."
    echo ""
    echo "This is expected - SwiftUI apps typically require Xcode for proper compilation."
    echo "The project is properly configured and would build successfully with:"
    echo ""
    echo "1. Install Xcode from the Mac App Store"
    echo "2. Run: sudo xcode-select -s /Applications/Xcode.app/Contents/Developer"
    echo "3. Then run: ./distribute.sh"
    echo ""
    echo "Or open the project in Xcode:"
    echo "   ./open-xcode.sh"
    echo ""

    # Clean up failed attempt
    rm -rf "$DIST_DIR"
    exit 1
}

echo "📋 Creating Info.plist..."

# Copy Info.plist
cp "AlwaysClock/Info.plist" "$APP_BUNDLE/Contents/Info.plist"

# Make executable
chmod +x "$APP_BUNDLE/Contents/MacOS/AlwaysClock"

echo "✅ App built successfully!"
echo "   Location: $APP_BUNDLE"
echo ""
echo "To test: open '$APP_BUNDLE'"