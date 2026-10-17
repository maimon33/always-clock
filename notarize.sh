#!/bin/bash

# Notarize and staple a signed .app, .dmg or .pkg.
# Usage: ./notarize.sh "dist/Always Clock.app"
# Requires: ASC_KEY_PATH (path to AuthKey_XXXX.p8), ASC_KEY_ID, ASC_ISSUER_ID

set -euo pipefail

TARGET="$1"
: "${ASC_KEY_PATH:?}" "${ASC_KEY_ID:?}" "${ASC_ISSUER_ID:?}"

SUBMIT_FILE="$TARGET"
TEMP_ZIP=""
if [[ "$TARGET" == *.app ]]; then
    # notarytool accepts zip/dmg/pkg; apps must be zipped first
    TEMP_ZIP=$(mktemp -d)/"$(basename "$TARGET" .app)".zip
    ditto -c -k --keepParent "$TARGET" "$TEMP_ZIP"
    SUBMIT_FILE="$TEMP_ZIP"
fi

echo "📨 Notarizing $(basename "$TARGET")..."
xcrun notarytool submit "$SUBMIT_FILE" \
    --key "$ASC_KEY_PATH" \
    --key-id "$ASC_KEY_ID" \
    --issuer "$ASC_ISSUER_ID" \
    --wait

xcrun stapler staple "$TARGET"
xcrun stapler validate "$TARGET"

[ -n "$TEMP_ZIP" ] && rm -rf "$(dirname "$TEMP_ZIP")"
echo "✅ Notarized and stapled: $TARGET"
