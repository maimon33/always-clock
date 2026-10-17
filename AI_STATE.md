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
- `.github/workflows/release.yml`: on `v*` tags, signs and notarizes only if the signing secrets exist (otherwise unsigned), runs `distribute.sh`, updates the Homebrew tap, publishes the release.
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
- Signing is optional: without the secrets, a tag still publishes an unsigned release. Signed releases need repository secrets: `MACOS_CERT_P12_BASE64`, `MACOS_CERT_PASSWORD`, `APPLE_TEAM_ID`, `APPLE_SIGN_IDENTITY`, `APPLE_INSTALLER_IDENTITY`, `ASC_KEY_P8_BASE64`, `ASC_KEY_ID`, `ASC_ISSUER_ID`. 
- Homebrew cask lives in the tap repo `maimon33/homebrew-always-clock`, not in this repo. CI updates it on each tag and needs secret `HOMEBREW_TAP_TOKEN`.
- Without the signing secrets, tag releases publish unsigned DMG/PKG/ZIP with first-launch instructions in the release notes.
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
- Open: Developer ID + App Store Connect secrets (see RELEASE_SETUP.md). Signing not run end-to-end.
- Open: `HOMEBREW_TAP_TOKEN` secret (fine-grained PAT, contents write on the tap repo).

### 2026-10-17 — Unsigned release path and Homebrew tap
- Release workflow publishes unsigned when signing secrets are absent; release notes include first-launch instructions.
- Cask moved to tap repo `maimon33/homebrew-always-clock` (v1.3 cask created); `homebrew/always-clock.rb` removed from this repo.
- Added `set-release-secrets.sh` and `RELEASE_SETUP.md` for uploading Apple secrets.

### 2026-10-17 — Frame, text effects, fonts and date toggle
- Window size now comes from `frameWidth`/`frameHeight`; text size (`clockSize`) no longer resizes the window.
- `ContentView` draws a rounded frame (own color, opacity, corner radius); `transparency` now applies to text only.
- `DigitalClockView`: date toggle, `ClockFont` picker (4 system designs), and `textEffects` (outline, glow, adjustable shadow). Analog clock is unchanged.
- Open: not yet compiled in full Xcode; only typechecked with the Swift compiler.

### 2026-10-18 — Frame fits clock content by default
- `fitFrameToContent` (default on): window = measured clock size (`contentSize`, from a GeometryReader in `ContentView`) + `frameMargin` on each side. Works for digital and analog.
- Manual width/height apply only when fit is off.
- Padding removed from `DigitalClockView` and `AnalogClockView`; the frame margin is now the only spacing around the clock.
