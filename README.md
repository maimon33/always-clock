# Always Clock

[![Build App](https://github.com/maimon33/always-clock/actions/workflows/build-app.yml/badge.svg)](https://github.com/maimon33/always-clock/actions/workflows/build-app.yml)
[![Test Build](https://github.com/maimon33/always-clock/actions/workflows/test-build.yml/badge.svg)](https://github.com/maimon33/always-clock/actions/workflows/test-build.yml)

A simple, always-on-top clock for macOS that stays visible over all windows and full-screen apps.

Requires macOS 13.0 (Ventura) or later.

## Install

```bash
brew tap maimon33/always-clock
brew install --cask maimon33/always-clock/always-clock
```

Or download the DMG, PKG or ZIP from the [Releases](../../releases) page.

If macOS says the app can't be opened, run:

```bash
xattr -dr com.apple.quarantine "/Applications/Always Clock.app"
```

## Reinstall / Update

```bash
brew update
brew reinstall --cask maimon33/always-clock/always-clock
```

To update without reinstalling, use `brew upgrade --cask maimon33/always-clock/always-clock`.

If Homebrew reports `already an App at '/Applications/Always Clock.app'`, the app was installed outside Homebrew. Overwrite it with:

```bash
brew install --cask --force maimon33/always-clock/always-clock
```

## Install from Source

You need full Xcode 15 or later.

```bash
git clone https://github.com/maimon33/always-clock.git
cd always-clock
./build.sh
cp -R build/Build/Products/Release/AlwaysClock.app /Applications/
```

To run it from Xcode instead, use `./open-xcode.sh` and press Cmd+R.

For packaging, signing and release details, see [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md).

## Usage

- The clock is click-through, so it never blocks your work.
- Press **⌘⇧T** from anywhere to open Settings.
- Or click the clock icon in the menu bar to open Settings or quit.

### Settings

- **Clock type:** digital or analog. Digital also offers seconds, date and font.
- **Text:** transparency, size and color.
- **Position:** predefined spots or exact X/Y coordinates.
- **System:** start at login, reset to defaults, quit.

## Uninstall

```bash
brew uninstall --cask always-clock
```

Remove the preferences file too, if you want a full cleanup:

```bash
rm ~/Library/Preferences/com.alwaysclock.app.plist
```

If you installed without Homebrew, disable "Start at login" in Settings and delete the app from `/Applications`.

## Privacy

- Runs as a menu bar app with no Dock icon.
- Collects no personal data and needs no internet access.
- Stores preferences locally with UserDefaults.

## License

This project is provided as-is for educational and personal use.
