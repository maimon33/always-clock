# Homebrew Cask Setup for Always Clock

## Step-by-Step Process

### 1. Create a Release
```bash
# Create and push a version tag
git tag v1.0
git push origin v1.0
```

This triggers the GitHub Action that:
- Builds the DMG
- Calculates SHA256 checksum
- Creates a GitHub release

### 2. Get Release Information
After the release is created, you'll need:
- **Download URL**: `https://github.com/maimon33/always-clock/releases/download/v1.0/Always%20Clock.dmg`
- **SHA256**: Check the GitHub Action output for the checksum

### 3. Update the Cask Formula
Update `homebrew/always-clock.rb` with:
- Correct version number
- Actual SHA256 from the release

### 4. Test Locally
```bash
# Test the cask locally
brew install --cask ./homebrew/always-clock.rb

# Verify it works
brew list --cask always-clock
```

### 5. Submit to Homebrew Cask
There are two options:

#### Option A: Submit to Official Homebrew Cask (Recommended)
1. Fork the [homebrew-cask repository](https://github.com/Homebrew/homebrew-cask)
2. Add your formula to `Casks/always-clock.rb`
3. Create a Pull Request
4. Wait for review and merge

#### Option B: Create Your Own Tap
1. Create a repository named `homebrew-tap`
2. Add your formula to `Casks/always-clock.rb`
3. Users install with: `brew tap maimon33/tap && brew install --cask always-clock`

## Installation Commands

### After Official Cask Approval:
```bash
brew install --cask always-clock
```

### With Your Own Tap:
```bash
brew tap maimon33/tap
brew install --cask always-clock
```

## Benefits
- ✅ No code signing required
- ✅ Users get automatic updates via `brew upgrade`
- ✅ Easy uninstall with `brew uninstall --cask always-clock`
- ✅ Integrates with macOS security (same as unsigned apps)
- ✅ Wide distribution reach

## Next Steps
1. Create your first release (v1.0)
2. Test the cask locally
3. Choose submission method (official vs. your own tap)