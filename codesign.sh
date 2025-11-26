#!/bin/bash

# Code signing script for Always Clock
# This script signs the app for distribution outside the App Store

set -e

APP_NAME="Always Clock"
APP_BUNDLE="./dist/$APP_NAME.app"
DEVELOPER_ID=""  # Set your Developer ID here

echo "✍️  Code Signing Always Clock"
echo "============================="

# Check if app bundle exists
if [ ! -d "$APP_BUNDLE" ]; then
    echo "❌ App bundle not found at: $APP_BUNDLE"
    echo "Please run ./package-app.sh first"
    exit 1
fi

# Check if Developer ID is set
if [ -z "$DEVELOPER_ID" ]; then
    echo "ℹ️  No Developer ID specified. Looking for available identities..."
    echo ""

    # List available signing identities
    echo "🔍 Available Developer ID Application certificates:"
    security find-identity -v -p codesigning | grep "Developer ID Application" || {
        echo "❌ No Developer ID Application certificates found!"
        echo ""
        echo "To sign your app, you need:"
        echo "1. Apple Developer Account"
        echo "2. Developer ID Application certificate installed"
        echo ""
        echo "For testing, you can:"
        echo "• Use the unsigned app (works on your Mac)"
        echo "• Create a self-signed certificate for local testing"
        echo ""
        echo "To create a self-signed certificate:"
        echo "1. Open Keychain Access"
        echo "2. Keychain Access > Certificate Assistant > Create Certificate"
        echo "3. Name: 'Always Clock Dev'"
        echo "4. Identity Type: Self Signed Root"
        echo "5. Certificate Type: Code Signing"
        echo ""
        exit 0
    }

    echo ""
    echo "To use code signing:"
    echo "1. Edit this script and set DEVELOPER_ID to your certificate name"
    echo "2. Or run: DEVELOPER_ID=\"Your Developer ID\" ./codesign.sh"
    echo ""
    exit 0
fi

echo "🔐 Signing with identity: $DEVELOPER_ID"

# Sign the app bundle
echo "📝 Signing app bundle..."
codesign --force --options runtime --deep --sign "$DEVELOPER_ID" "$APP_BUNDLE"

# Verify signature
echo "🔍 Verifying signature..."
codesign --verify --verbose=2 "$APP_BUNDLE"

echo "✅ App successfully signed!"
echo ""

# Check if we should notarize
echo "🚨 Important: For distribution outside the App Store, you should also notarize the app."
echo ""
echo "To notarize:"
echo "1. Create an app-specific password in your Apple ID account"
echo "2. Run: xcrun notarytool submit '$APP_BUNDLE' --apple-id your-email@example.com --password app-specific-password --team-id TEAM_ID"
echo "3. Wait for notarization to complete"
echo "4. Run: xcrun stapler staple '$APP_BUNDLE'"
echo ""
echo "For more info: https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution"