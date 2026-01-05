#!/bin/bash

# Create a DMG installer for Always Clock

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
APP_BUNDLE="$DIST_DIR/$APP_NAME.app"
DMG_NAME="Always-Clock-v$VERSION"
TEMP_DMG="$DIST_DIR/temp.dmg"
FINAL_DMG="$DIST_DIR/$DMG_NAME.dmg"

echo "💿 Creating DMG installer for Always Clock..."

# Check if app bundle exists
if [ ! -d "$APP_BUNDLE" ]; then
    echo "❌ App bundle not found. Run ./package-app.sh first"
    exit 1
fi

# Clean up previous DMG
rm -f "$TEMP_DMG" "$FINAL_DMG"

# Create temporary DMG directory
TEMP_DIR=$(mktemp -d)
echo "📁 Using temporary directory: $TEMP_DIR"

# Copy app bundle to temp directory
cp -R "$APP_BUNDLE" "$TEMP_DIR/"

# Create Applications symlink for easy installation
ln -s /Applications "$TEMP_DIR/Applications"

# Create a README for the DMG
cat > "$TEMP_DIR/README.txt" << EOF
Always Clock v$VERSION

INSTALLATION:
1. Drag "Always Clock.app" to the Applications folder
2. Launch from Applications or Spotlight
3. The app will appear as a floating clock with menu bar controls

FEATURES:
• Always stays on top of all windows and full-screen apps
• Digital and analog clock modes
• Adjustable transparency and size
• Customizable colors
• Start at login option
• Drag to reposition

REQUIREMENTS:
• macOS 13.0 (Ventura) or later

For support and updates, visit:
https://github.com/yourusername/always-clock

Enjoy your always-visible clock!
EOF

echo "💾 Creating disk image..."

# Calculate size needed (app size + some padding)
SIZE_KB=$(du -sk "$TEMP_DIR" | cut -f1)
SIZE_KB=$((SIZE_KB + 1024))  # Add 1MB padding

# Create the DMG
hdiutil create -srcfolder "$TEMP_DIR" -volname "$APP_NAME v$VERSION" -fs HFS+ -fsargs "-c c=64,a=16,e=16" -format UDRW -size "${SIZE_KB}k" "$TEMP_DMG"

echo "🎨 Customizing DMG appearance..."

# Mount the DMG
DEVICE=$(hdiutil attach -readwrite -noverify -noautoopen "$TEMP_DMG" | grep '/Volumes' | awk '{print $1}')
MOUNT_POINT="/Volumes/$APP_NAME v$VERSION"

# Wait for mount
sleep 2

# Set up the DMG window (if running with GUI)
if [ -n "$DISPLAY" ] || [ "$(uname)" = "Darwin" ]; then
    # Create a simple AppleScript to set up the DMG window
    cat > /tmp/dmg_setup.applescript << EOF
tell application "Finder"
    tell disk "$APP_NAME v$VERSION"
        open
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        set the bounds of container window to {400, 100, 900, 400}
        set theViewOptions to the icon view options of container window
        set arrangement of theViewOptions to not arranged
        set icon size of theViewOptions to 128
        set background picture of theViewOptions to file ".background:background.png"
        make new alias file at container window to POSIX file "/Applications" with properties {name:"Applications"}
        set position of item "$APP_NAME.app" of container window to {150, 200}
        set position of item "Applications" of container window to {350, 200}
        set position of item "README.txt" of container window to {250, 300}
        update without registering applications
        delay 2
        close
    end tell
end tell
EOF
    # osascript /tmp/dmg_setup.applescript 2>/dev/null || echo "⚠️  Could not customize DMG appearance (GUI required)"
fi

# Unmount
hdiutil detach "$DEVICE"

echo "🗜️  Compressing DMG..."

# Convert to compressed, read-only DMG
hdiutil convert "$TEMP_DMG" -format UDZO -imagekey zlib-level=9 -o "$FINAL_DMG"

# Clean up
rm -f "$TEMP_DMG"
rm -rf "$TEMP_DIR"

echo "✅ DMG created successfully!"
echo ""
echo "📄 DMG Information:"
echo "  File: $FINAL_DMG"
echo "  Size: $(du -h "$FINAL_DMG" | cut -f1)"
echo ""
echo "🚀 To distribute:"
echo "  1. Test the DMG by double-clicking it"
echo "  2. Share the DMG file for easy installation"
echo "  3. Users can drag the app to Applications folder"