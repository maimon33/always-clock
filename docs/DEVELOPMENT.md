# Development

Build, package and release details for Always Clock. For installing the app, see the [main README](../README.md).

## Prerequisites

- macOS 13.0 (Ventura) or later
- Full Xcode 15.0 or later (command line tools alone cannot run `xcodebuild`)

## Build Scripts

Run these from the repository root.

| Script | Does |
|---|---|
| `./open-xcode.sh` | Opens the project in Xcode (Cmd+R to build and run) |
| `./build.sh` | Release build to `build/Build/Products/Release/AlwaysClock.app` |
| `./package-app.sh` | Creates a standalone `.app` bundle |
| `./create-dmg.sh` | Creates a DMG from the app bundle (run `package-app.sh` first) |
| `./create-pkg.sh` | Creates a PKG installer (run `package-app.sh` first) |
| `./distribute.sh` | Creates all formats: `.app`, `.dmg`, `.pkg`, `.zip` |
| `./create-icon.sh` | Regenerates the app icon in all required sizes |

`distribute.sh` builds unsigned artifacts unless the signing variables below are set.

## Signed and Notarized Builds

```bash
export SIGN_IDENTITY="Developer ID Application: Your Name (TEAMID)"
export INSTALLER_IDENTITY="Developer ID Installer: Your Name (TEAMID)"
export APPLE_TEAM_ID=TEAMID
export ASC_KEY_PATH=~/keys/AuthKey_XXXXXXXXXX.p8
export ASC_KEY_ID=XXXXXXXXXX
export ASC_ISSUER_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
./distribute.sh
```

Versions come from the latest `v*` git tag. To override: `VERSION=1.4 ./distribute.sh`.

## Releases

- Pushing a `v*` tag runs `.github/workflows/release.yml`. It builds, signs and notarizes when the signing secrets exist, otherwise it publishes unsigned artifacts.
- The workflow publishes the GitHub release and regenerates the Homebrew cask in `maimon33/homebrew-always-clock`. This needs the `HOMEBREW_TAP_TOKEN` secret.
- Signing secrets are listed in [RELEASE_SETUP.md](../RELEASE_SETUP.md).
- Every push to `main` runs `.github/workflows/build-app.yml`, which builds unsigned artifacts. Download them from the workflow run's **Artifacts** section (`always-clock-dmg`, `always-clock-pkg`, `always-clock-zip`, `always-clock-app`).
- Manual builds: **Actions** → **Build Always Clock App** → **Run workflow**.

## Homebrew

See [HOMEBREW_SETUP.md](../HOMEBREW_SETUP.md) for the tap setup.
