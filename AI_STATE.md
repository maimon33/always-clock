# AI_STATE

## Purpose and stack
- Always Clock: an always-on-top, click-through floating clock for macOS 13+.
- SwiftUI + AppKit, menu bar app (`LSUIElement`), built with Xcode (`AlwaysClock.xcodeproj`); distributed via GitHub Releases (DMG/PKG/ZIP) and a Homebrew cask.

## Key file map
- `AlwaysClock/AlwaysClockApp.swift`: app delegate (clock window, status item, settings window, ⌘⇧T hotkey) and `ClockSettings` (UserDefaults-backed `ObservableObject`, window placement).
- `AlwaysClock/SettingsView.swift`: settings UI, including preset positions and login item toggle.
- `AlwaysClock/ClockView.swift`, `DigitalClockView.swift`, `AnalogClockView.swift`, `ContentView.swift`: rendering.
- `version.sh`: single source of `VERSION` and `BUILD_NUMBER` (from `v*` tag or CI run number). Sourced by every build script.
- `package-app.sh`: archives with xcodebuild; signs with Developer ID when `SIGN_IDENTITY` is set.
- `create-dmg.sh`, `create-pkg.sh`: installers; sign when `SIGN_IDENTITY` / `INSTALLER_IDENTITY` are set.
- `notarize.sh`: notarytool submit + staple for `.app`, `.dmg`, `.pkg` (needs `ASC_KEY_PATH`, `ASC_KEY_ID`, `ASC_ISSUER_ID`).
- `distribute.sh`: full pipeline; notarizes only when `ASC_KEY_PATH` is set.
- `.github/workflows/release.yml`: on `v*` tags, requires signing secrets, imports the cert, runs `distribute.sh`, regenerates `homebrew/always-clock.rb`, publishes the release.
- `.github/workflows/build-app.yml`: unsigned build of `distribute.sh` on push/PR.

## Active conventions
- Version numbers are never hardcoded in scripts or workflows; they come from `version.sh`. `MARKETING_VERSION` in the pbxproj is only a local-build default that CI overrides.
- Global hotkey uses Carbon `RegisterEventHotKey`. Do not reintroduce `NSEvent` global key monitors or Accessibility prompts: they trigger macOS permission dialogs.
- Clock is click-through except while Settings is open, when it becomes draggable and persists its origin.
- Login item is owned by the Settings toggle. Do not register it at launch.

## Current initiatives
- Production distribution: Developer ID signing, notarization, stapled installers, auto-updated Homebrew cask.
- Mac App Store is not pursued yet; it would need App Sandbox (currently off) and a privacy manifest.

## Constraints that would surprise a cold reader
- Release builds need repository secrets: `MACOS_CERT_P12_BASE64`, `MACOS_CERT_PASSWORD`, `APPLE_TEAM_ID`, `APPLE_SIGN_IDENTITY`, `APPLE_INSTALLER_IDENTITY`, `ASC_KEY_P8_BASE64`, `ASC_KEY_ID`, `ASC_ISSUER_ID`. Tag builds fail without them.
- `homebrew/always-clock.rb` is rewritten by CI on every tag; it is stale until the first tagged release.
- Deployment target is macOS 13.0.
- Local builds need full Xcode; Command Line Tools cannot run `xcodebuild`.

## Session Log

### 2026-10-15 — Permission prompts, dynamic versions, production signing pipeline
- Replaced the global `NSEvent` keyDown monitor and Accessibility prompt with Carbon `RegisterEventHotKey` for ⌘⇧T. This removes the Accessibility/Input Monitoring dialog that appeared on launch.
- Removed the unused `NSAccessibilityUsageDescription`.
- Added `version.sh`; removed the duplicated version blocks and `1.0` fallbacks from all scripts.
- Added `notarize.sh`; signing and notarization are wired into `package-app.sh`, `create-dmg.sh`, `create-pkg.sh` and `distribute.sh`.
- Rewrote `release.yml` (secret-gated tag releases, cask regeneration) and `build-app.yml` (uses `distribute.sh`).
- Removed `codesign.sh` (superseded) and `build-swift.sh` (hardcoded x86_64 and documented as failing).
- Open: Developer ID + App Store Connect secrets must be added to the repo. Not yet run end-to-end; no signing identity or notary access was available locally.
- Open: `homebrew/always-clock.rb` still shows the v1.0-era values until the next tag.
