#!/bin/bash

# Create a PKG installer for Always Clock
# Set INSTALLER_IDENTITY ("Developer ID Installer: Name (TEAMID)") to sign the package.

set -e

cd "$(dirname "$0")"
source ./version.sh

APP_NAME="Always Clock"
EXECUTABLE_NAME="AlwaysClock"
BUNDLE_ID="com.alwaysclock.app"
DIST_DIR="./dist"
PKG_DIR="$DIST_DIR/pkg"
APP_BUNDLE="$DIST_DIR/$APP_NAME.app"
PKG_NAME="Always-Clock-v$VERSION.pkg"
FINAL_PKG="$DIST_DIR/$PKG_NAME"
UNSIGNED_PKG="$DIST_DIR/$PKG_NAME.unsigned"

echo "📦 Creating PKG installer for Always Clock $VERSION..."

if [ ! -d "$APP_BUNDLE" ]; then
    echo "❌ App bundle not found. Run ./package-app.sh first"
    exit 1
fi

rm -rf "$PKG_DIR"
rm -f "$FINAL_PKG" "$UNSIGNED_PKG"
mkdir -p "$PKG_DIR/Applications"
cp -R "$APP_BUNDLE" "$PKG_DIR/Applications/"

echo "📝 Creating installer scripts..."

cat > "$PKG_DIR/preinstall" << EOF
#!/bin/bash
# Quit a running copy so its bundle can be replaced
pkill -x "$EXECUTABLE_NAME" 2>/dev/null || true
exit 0
EOF

cat > "$PKG_DIR/postinstall" << 'EOF'
#!/bin/bash
# Installer runs as root; make sure the app is readable by every user
APP_PATH="/Applications/Always Clock.app"
if [ ! -d "$APP_PATH" ]; then
    echo "Always Clock was not found at $APP_PATH" >&2
    exit 1
fi
chmod -R 755 "$APP_PATH"
chown -R root:wheel "$APP_PATH"
exit 0
EOF

chmod +x "$PKG_DIR/preinstall" "$PKG_DIR/postinstall"

echo "📋 Preparing component plist (install in /Applications, never relocate)..."

COMPONENT_PLIST="$DIST_DIR/component.plist"
pkgbuild --analyze --root "$PKG_DIR" "$COMPONENT_PLIST" > /dev/null
/usr/libexec/PlistBuddy -c "Set :0:BundleIsRelocatable false" "$COMPONENT_PLIST"

echo "🏗️  Building PKG installer..."

pkgbuild \
    --root "$PKG_DIR" \
    --component-plist "$COMPONENT_PLIST" \
    --identifier "$BUNDLE_ID.installer" \
    --version "$VERSION" \
    --install-location "/" \
    --scripts "$PKG_DIR" \
    --ownership recommended \
    "$UNSIGNED_PKG"

if [ -n "$INSTALLER_IDENTITY" ]; then
    echo "✍️  Signing PKG with: $INSTALLER_IDENTITY"
    productsign --sign "$INSTALLER_IDENTITY" --timestamp "$UNSIGNED_PKG" "$FINAL_PKG"
    rm -f "$UNSIGNED_PKG"
    pkgutil --check-signature "$FINAL_PKG"
else
    mv "$UNSIGNED_PKG" "$FINAL_PKG"
fi

rm -rf "$PKG_DIR" "$COMPONENT_PLIST"

echo "✅ PKG installer created: $FINAL_PKG ($(du -h "$FINAL_PKG" | cut -f1))"
echo "   Install: sudo installer -pkg '$FINAL_PKG' -target /"
