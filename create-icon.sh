#!/bin/bash

# Create app icon for Always Clock

set -e

ICON_DIR="AlwaysClock/Assets.xcassets/AppIcon.appiconset"
TEMP_ICON="/tmp/clock_base_icon.png"

echo "🎨 Creating app icon for Always Clock..."

# Create the icon directory
mkdir -p "$ICON_DIR"

echo "🕒 Generating base clock icon..."

# Create a simple clock icon using Python and PIL (if available) or SF Symbols
cat > /tmp/create_clock_icon.py << 'EOF'
#!/usr/bin/env python3

try:
    from PIL import Image, ImageDraw
    import math

    def create_clock_icon(size, filename):
        # Create image with transparent background
        img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
        draw = ImageDraw.Draw(img)

        # Clock face
        center = size // 2
        radius = size // 2 - 10

        # Draw clock circle with gradient effect
        for i in range(5):
            draw.ellipse([center - radius + i, center - radius + i,
                         center + radius - i, center + radius - i],
                        outline=(100 + i*30, 100 + i*30, 255 - i*10, 255 - i*50),
                        width=2)

        # Fill the clock face
        draw.ellipse([center - radius + 5, center - radius + 5,
                     center + radius - 5, center + radius - 5],
                    fill=(240, 248, 255, 200))

        # Draw hour markers
        for hour in range(12):
            angle = math.radians(hour * 30 - 90)
            start_radius = radius - 15
            end_radius = radius - 5

            x1 = center + start_radius * math.cos(angle)
            y1 = center + start_radius * math.sin(angle)
            x2 = center + end_radius * math.cos(angle)
            y2 = center + end_radius * math.sin(angle)

            draw.line([(x1, y1), (x2, y2)], fill=(50, 50, 150, 255), width=3)

        # Draw clock hands (showing 10:10 for aesthetics)
        # Hour hand (pointing to 10)
        hour_angle = math.radians(10 * 30 - 90)
        hour_length = radius * 0.5
        hour_x = center + hour_length * math.cos(hour_angle)
        hour_y = center + hour_length * math.sin(hour_angle)
        draw.line([(center, center), (hour_x, hour_y)], fill=(50, 50, 150, 255), width=6)

        # Minute hand (pointing to 2)
        minute_angle = math.radians(10 * 6 - 90)
        minute_length = radius * 0.7
        minute_x = center + minute_length * math.cos(minute_angle)
        minute_y = center + minute_length * math.sin(minute_angle)
        draw.line([(center, center), (minute_x, minute_y)], fill=(50, 50, 150, 255), width=4)

        # Center dot
        dot_radius = 8
        draw.ellipse([center - dot_radius, center - dot_radius,
                     center + dot_radius, center + dot_radius],
                    fill=(200, 50, 50, 255))

        # Save the image
        img.save(filename, 'PNG')
        print(f"Created {size}x{size} icon: {filename}")

    # Generate base icon
    create_clock_icon(1024, '/tmp/clock_base_icon.png')

except ImportError:
    print("PIL not available, will use SF Symbols instead")
    exit(1)

EOF

# Try to create icon with Python
if python3 /tmp/create_clock_icon.py 2>/dev/null; then
    echo "✅ Created base icon with Python"
    BASE_ICON="$TEMP_ICON"
else
    echo "📱 Using SF Symbols to create icon..."
    # Fallback: Use SF Symbols to create an icon
    cat > /tmp/create_sf_icon.swift << 'EOF'
import Cocoa
import CoreImage

let size = NSSize(width: 1024, height: 1024)
let image = NSImage(size: size)

image.lockFocus()

// Clear background
NSColor.clear.setFill()
NSRect(origin: .zero, size: size).fill()

// Draw clock symbol
if let clockImage = NSImage(systemSymbolName: "clock", accessibilityDescription: nil) {
    clockImage.size = NSSize(width: 800, height: 800)
    let rect = NSRect(x: 112, y: 112, width: 800, height: 800)
    clockImage.draw(in: rect)
}

image.unlockFocus()

// Save as PNG
if let tiffData = image.tiffRepresentation,
   let bitmapRep = NSBitmapImageRep(data: tiffData),
   let pngData = bitmapRep.representation(using: .png, properties: [:]) {
    pngData.write(to: URL(fileURLWithPath: "/tmp/clock_base_icon.png"))
    print("Created SF Symbols icon")
} else {
    print("Failed to create icon")
}
EOF

    if swift /tmp/create_sf_icon.swift 2>/dev/null; then
        echo "✅ Created base icon with SF Symbols"
        BASE_ICON="$TEMP_ICON"
    else
        echo "⚠️  Could not create custom icon, will use system default"
        BASE_ICON=""
    fi
fi

if [ -n "$BASE_ICON" ] && [ -f "$BASE_ICON" ]; then
    echo "📐 Generating icon sizes..."

    # Icon sizes needed for macOS apps
    declare -a sizes=(
        "16" "32" "128" "256" "512" "1024"
    )

    # Generate all required icon sizes
    for size in "${sizes[@]}"; do
        output_file="$ICON_DIR/icon_${size}x${size}.png"
        if command -v sips >/dev/null 2>&1; then
            sips -z "$size" "$size" "$BASE_ICON" --out "$output_file" >/dev/null 2>&1
            echo "  ✓ Generated ${size}x${size} icon"
        else
            echo "  ⚠️  sips not available, copying base icon for ${size}x${size}"
            cp "$BASE_ICON" "$output_file"
        fi
    done

    # Create Contents.json for Xcode
    cat > "$ICON_DIR/Contents.json" << 'EOF'
{
  "images" : [
    {
      "filename" : "icon_16x16.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "16x16"
    },
    {
      "filename" : "icon_32x32.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "16x16"
    },
    {
      "filename" : "icon_32x32.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "32x32"
    },
    {
      "filename" : "icon_64x64.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "32x32"
    },
    {
      "filename" : "icon_128x128.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "128x128"
    },
    {
      "filename" : "icon_256x256.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "128x128"
    },
    {
      "filename" : "icon_256x256.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "256x256"
    },
    {
      "filename" : "icon_512x512.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "256x256"
    },
    {
      "filename" : "icon_512x512.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "512x512"
    },
    {
      "filename" : "icon_1024x1024.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "512x512"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

    # Clean up
    rm -f "$TEMP_ICON"
    rm -f /tmp/create_clock_icon.py
    rm -f /tmp/create_sf_icon.swift

    echo "✅ App icon created successfully!"
    echo "   Location: $ICON_DIR"
    echo "   Sizes: 16x16, 32x32, 128x128, 256x256, 512x512, 1024x1024"
else
    echo "⚠️  Using system default icon (no custom icon created)"
fi

echo ""
echo "🔄 To rebuild the app with the new icon:"
echo "   ./package-app.sh"