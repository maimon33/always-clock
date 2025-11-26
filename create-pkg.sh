#!/bin/bash

# Create a PKG installer for Always Clock

set -e

APP_NAME="Always Clock"
BUNDLE_ID="com.alwaysclock.app"
VERSION="1.0"
DIST_DIR="./dist"
PKG_DIR="$DIST_DIR/pkg"
APP_BUNDLE="$DIST_DIR/$APP_NAME.app"
PKG_NAME="Always-Clock-v$VERSION.pkg"
FINAL_PKG="$DIST_DIR/$PKG_NAME"

echo "📦 Creating PKG installer for Always Clock..."

# Check if app bundle exists
if [ ! -d "$APP_BUNDLE" ]; then
    echo "❌ App bundle not found. Run ./package-app.sh first"
    exit 1
fi

# Clean up previous build
rm -rf "$PKG_DIR"
rm -f "$FINAL_PKG"
mkdir -p "$PKG_DIR/Applications"

# Copy app to pkg directory
cp -R "$APP_BUNDLE" "$PKG_DIR/Applications/"

echo "📝 Creating installer scripts..."

# Create preinstall script (runs before installation)
cat > "$PKG_DIR/preinstall" << 'EOF'
#!/bin/bash

# Quit the app if it's running
APP_NAME="Always Clock"
if pgrep -f "$APP_NAME" > /dev/null; then
    echo "Quitting $APP_NAME..."
    killall "$APP_NAME" 2>/dev/null || true
    sleep 1
fi

exit 0
EOF

# Create postinstall script (runs after installation)
cat > "$PKG_DIR/postinstall" << 'EOF'
#!/bin/bash

APP_NAME="Always Clock"
APP_PATH="/Applications/$APP_NAME.app"

echo "Setting up Always Clock..."

# Set proper permissions
if [ -d "$APP_PATH" ]; then
    chmod -R 755 "$APP_PATH"
    chown -R root:wheel "$APP_PATH"

    echo "Always Clock installed successfully!"
    echo "You can find it in Applications or launch it from Spotlight."
else
    echo "Error: App not found at expected location"
    exit 1
fi

exit 0
EOF

# Make scripts executable
chmod +x "$PKG_DIR/preinstall"
chmod +x "$PKG_DIR/postinstall"

echo "🏗️  Building PKG installer..."

# Create component package
pkgbuild \
    --root "$PKG_DIR" \
    --identifier "$BUNDLE_ID.installer" \
    --version "$VERSION" \
    --install-location "/" \
    --scripts "$PKG_DIR" \
    --ownership recommended \
    "$FINAL_PKG"

# Clean up temporary files
rm -rf "$PKG_DIR"

echo "✅ PKG installer created successfully!"
echo ""
echo "📄 PKG Information:"
echo "  File: $FINAL_PKG"
echo "  Size: $(du -h "$FINAL_PKG" | cut -f1)"
echo "  Identifier: $BUNDLE_ID.installer"
echo "  Version: $VERSION"
echo ""
echo "🔍 To inspect the PKG contents:"
echo "  pkgutil --payload-files '$FINAL_PKG'"
echo ""
echo "🚀 To install:"
echo "  Double-click the PKG file"
echo "  Or run: sudo installer -pkg '$FINAL_PKG' -target /"
echo ""
echo "⚠️  Note: PKG installers may require admin privileges"