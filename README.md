# Always Clock

[![Build App](https://github.com/maimon33/always-clock/actions/workflows/build-app.yml/badge.svg)](https://github.com/maimon33/always-clock/actions/workflows/build-app.yml)
[![Test Build](https://github.com/maimon33/always-clock/actions/workflows/test-build.yml/badge.svg)](https://github.com/maimon33/always-clock/actions/workflows/test-build.yml)

A simple and elegant always-on-top clock for macOS that stays visible over all windows and full-screen applications.

## 🚀 **Get the App (No Xcode Required!)**

### Option 1: Homebrew (Coming Soon)
```bash
brew install --cask always-clock
```

### Option 2: Download from Releases (Recommended)
- Check [**Releases**](../../releases) for stable versions with permanent download links
- Download formats: DMG, PKG, or ZIP

### Option 3: Download from GitHub Actions
1. Go to [**Actions**](../../actions) tab above
2. Click latest **"Build Always Clock App"** workflow run
3. Scroll to **Artifacts** and download your preferred format:
   - `always-clock-dmg` - Mac-style DMG installer
   - `always-clock-pkg` - System installer wizard
   - `always-clock-zip` - ZIP archive
   - `always-clock-app` - Direct app bundle

### Option 4: Trigger Your Own Build
1. Fork this repository
2. Go to **Actions** → **"Build Always Clock App"** → **"Run workflow"**
3. Wait 5 minutes and download your fresh build!

## Features

- **Always on Top**: Stays visible over all applications, including full-screen apps
- **Digital & Analog Clocks**: Switch between digital and analog clock displays
- **Customizable Transparency**: Adjust opacity from 10% to 100%
- **Resizable**: Scale the clock from 50% to 200% of original size
- **Color Customization**: Choose any color for the clock display
- **Start at Login**: Automatically launch when you log in to macOS
- **Draggable**: Click and drag to reposition the clock anywhere on screen
- **Menu Bar Integration**: Access settings and controls from the menu bar
- **Context Menu**: Right-click on the clock for quick options

## Requirements

- macOS 13.0 (Ventura) or later
- Xcode 15.0 or later (for building from source)

## Building & Distribution

### Prerequisites
- macOS 13.0 (Ventura) or later
- Xcode 15.0 or later (full Xcode, not just command line tools)

### Quick Start - Complete Distribution Build
```bash
# Creates all distribution formats at once
./distribute.sh
```

This creates:
- **App Bundle** (`.app`) - Drag to Applications
- **DMG Installer** (`.dmg`) - Mac-style disk image
- **PKG Installer** (`.pkg`) - Installer wizard
- **ZIP Archive** (`.zip`) - Compressed download

### Individual Build Options

#### Option 1: Using Xcode (Recommended for Development)
```bash
./open-xcode.sh          # Opens project in Xcode
# Then press Cmd+R to build and run
```

#### Option 2: Package App Bundle Only
```bash
./package-app.sh         # Creates standalone .app
```

#### Option 3: Create DMG Installer
```bash
./package-app.sh         # First create app bundle
./create-dmg.sh         # Then create DMG
```

#### Option 4: Create PKG Installer
```bash
./package-app.sh         # First create app bundle
./create-pkg.sh         # Then create PKG
```

### Code Signing (Optional)
For distribution outside the App Store:
```bash
./codesign.sh           # Sign the app (requires Developer ID)
```

### App Icon
The build process automatically creates a clock icon. To regenerate:
```bash
./create-icon.sh        # Creates app icon in all required sizes
```

## Usage

### First Launch
1. Run the application
2. The clock will appear on your screen
3. A menu bar item (clock icon) will be added to your system menu bar

### Controls
- **Move the Clock**: Click and drag the clock to reposition it
- **Right-click Menu**:
  - Switch between Digital/Analog modes
  - Open Settings
  - Quit the application
- **Menu Bar**: Click the clock icon in the menu bar for quick access to settings

### Settings
Access settings via the menu bar icon or right-click menu:
- **Clock Type**: Choose between Digital or Analog display
- **Transparency**: Adjust from 10% (very transparent) to 100% (opaque)
- **Size**: Scale from 50% to 200% of original size
- **Color**: Pick any color for the clock display
- **Start at Login**: Enable/disable automatic startup
- **Reset to Defaults**: Restore original settings

### Default Settings
- **Type**: Digital clock
- **Transparency**: 80%
- **Size**: 100%
- **Color**: White
- **Start at Login**: Disabled

## Uninstalling

1. Disable "Start at login" in settings (if enabled)
2. Quit the application
3. Delete the app from your Applications folder
4. The app stores minimal preferences in `~/Library/Preferences/`

## Troubleshooting

**Clock not staying on top of full-screen apps:**
- The app uses `.floating` window level and `.fullScreenAuxiliary` collection behavior to work with full-screen applications

**App won't start at login:**
- Ensure you've enabled the setting in the app preferences
- Check System Preferences > Users & Groups > Login Items

**Clock disappears:**
- Look for the menu bar icon and access settings
- The clock might be positioned off-screen - use Reset to Defaults

## Privacy & Permissions

This app:
- Runs as a menu bar application (LSUIElement)
- Does not collect any personal data
- Does not require internet access
- Stores preferences locally using UserDefaults

## License

This project is provided as-is for educational and personal use.