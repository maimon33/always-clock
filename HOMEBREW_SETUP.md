# Homebrew

Always Clock is distributed through the tap repo [maimon33/homebrew-always-clock](https://github.com/maimon33/homebrew-always-clock).

```bash
brew tap maimon33/always-clock
brew install --cask always-clock
```

## How the cask is updated
- `.github/workflows/release.yml` rewrites `Casks/always-clock.rb` in the tap on every `v*` tag, using the release DMG's version and sha256.
- That needs the repository secret `HOMEBREW_TAP_TOKEN`: a fine-grained personal access token with **Contents: read and write** on `maimon33/homebrew-always-clock`. Without it, the tap update is skipped with a warning.

## Unsigned builds
Until Apple signing is set up, the cask's caveats show the command that clears macOS's quarantine flag on first launch.
