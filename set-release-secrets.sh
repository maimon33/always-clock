#!/bin/bash

# Uploads the signing and notarization secrets used by .github/workflows/release.yml.
# Values are read interactively and piped straight into `gh secret set`; nothing is written to disk.
# Requires: gh (logged in with repo admin rights).

set -euo pipefail

cd "$(dirname "$0")"

command -v gh >/dev/null || { echo "❌ gh CLI not found"; exit 1; }

ask() { # ask VAR "prompt" [default]
    local value
    if [ -n "${3:-}" ]; then
        read -r -p "$2 [$3]: " value
        value=${value:-$3}
    else
        read -r -p "$2: " value
    fi
    printf -v "$1" '%s' "$value"
}

set_secret() { # set_secret NAME VALUE
    printf '%s' "$2" | gh secret set "$1" --repo maimon33/always-clock
    echo "✅ Set $1"
}

echo "🔐 Always Clock release secrets"
echo "Get these first: see RELEASE_SETUP.md"
echo ""

ask P12_PATH "Path to Developer ID .p12 export (both certificates)"
[ -f "$P12_PATH" ] || { echo "❌ File not found: $P12_PATH"; exit 1; }

read -r -s -p "Password used when exporting the .p12: " P12_PASSWORD; echo ""
[ -n "$P12_PASSWORD" ] || { echo "❌ Password is empty"; exit 1; }

ask TEAM_ID "Apple Team ID (10 characters, from developer.apple.com → Membership)"
ask APP_IDENTITY "Developer ID Application identity (e.g. Developer ID Application: Your Name (TEAMID))"
ask INSTALLER_IDENTITY "Developer ID Installer identity" "${APP_IDENTITY/Developer ID Application/Developer ID Installer}"

ask P8_PATH "Path to App Store Connect API key (AuthKey_XXXX.p8)"
[ -f "$P8_PATH" ] || { echo "❌ File not found: $P8_PATH"; exit 1; }

ask KEY_ID "App Store Connect Key ID (shown next to the key)"
ask ISSUER_ID "App Store Connect Issuer ID (shown at top of the Keys page)"

echo ""
echo "Uploading..."
set_secret MACOS_CERT_P12_BASE64 "$(base64 -i "$P12_PATH")"
set_secret MACOS_CERT_PASSWORD "$P12_PASSWORD"
set_secret APPLE_TEAM_ID "$TEAM_ID"
set_secret APPLE_SIGN_IDENTITY "$APP_IDENTITY"
set_secret APPLE_INSTALLER_IDENTITY "$INSTALLER_IDENTITY"
set_secret ASC_KEY_P8_BASE64 "$(base64 -i "$P8_PATH")"
set_secret ASC_KEY_ID "$KEY_ID"
set_secret ASC_ISSUER_ID "$ISSUER_ID"

echo ""
gh secret list --repo maimon33/always-clock
