#!/bin/bash

# Build script for Always Clock macOS app

echo "Building Always Clock..."

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Error: xcodebuild not found."
    echo "Please install Xcode from the Mac App Store."
    exit 1
fi

# Check if we have full Xcode (not just command line tools)
DEVELOPER_DIR=$(xcode-select -p)
if [[ "$DEVELOPER_DIR" == *"CommandLineTools"* ]]; then
    echo "❌ Error: Full Xcode is required (not just command line tools)."
    echo "Please install Xcode from the Mac App Store and run:"
    echo "sudo xcode-select -s /Applications/Xcode.app/Contents/Developer"
    echo ""
    echo "Alternatively, open the project in Xcode and build manually:"
    echo "open AlwaysClock.xcodeproj"
    exit 1
fi

# Build the project
echo "Building with Xcode..."
xcodebuild \
    -project AlwaysClock.xcodeproj \
    -scheme AlwaysClock \
    -configuration Release \
    -derivedDataPath ./build \
    build

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo "The app is located at: ./build/Build/Products/Release/AlwaysClock.app"
    echo ""
    echo "To run the app:"
    echo "open ./build/Build/Products/Release/AlwaysClock.app"
    echo ""
    echo "To install the app to Applications folder:"
    echo "cp -R ./build/Build/Products/Release/AlwaysClock.app /Applications/"
else
    echo "❌ Build failed!"
    echo ""
    echo "You can also open the project in Xcode and build manually:"
    echo "open AlwaysClock.xcodeproj"
    exit 1
fi