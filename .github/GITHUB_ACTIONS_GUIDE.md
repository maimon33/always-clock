# GitHub Actions Build Guide

## 🚀 **Getting Your App via GitHub Actions**

This repository is configured to automatically build the Always Clock app using GitHub Actions. No local Xcode installation required!

## 📦 **Available Workflows**

### 1. **Build App** (`build-app.yml`)
- **Triggers:** Every push to main, PRs, manual trigger
- **Outputs:** App bundle, DMG, PKG, and ZIP files
- **Artifacts:** Available for 30 days

### 2. **Release** (`release.yml`)
- **Triggers:** Git tags (v1.0, v1.1, etc.), manual trigger
- **Outputs:** Full release with download links
- **Creates:** GitHub Release with all distribution formats

### 3. **Test Build** (`test-build.yml`)
- **Triggers:** Every push/PR
- **Purpose:** Quick validation that project builds correctly

## 🎯 **How to Get the App**

### Option A: Download from Actions (Immediate)
1. Go to **Actions** tab in GitHub
2. Click on latest **"Build Always Clock App"** workflow
3. Scroll to **Artifacts** section
4. Download your preferred format:
   - `always-clock-app` - App bundle only
   - `always-clock-dmg` - DMG installer
   - `always-clock-pkg` - PKG installer
   - `always-clock-zip` - ZIP archive
   - `always-clock-all-formats` - Everything

### Option B: Create a Release (Permanent Downloads)
1. Create a new tag: `git tag v1.0 && git push origin v1.0`
2. Or go to **Releases** → **"Create a new release"**
3. Release workflow automatically builds and attaches files
4. Download from the **Releases** page (permanent links)

### Option C: Manual Trigger
1. Go to **Actions** tab
2. Select **"Build Always Clock App"**
3. Click **"Run workflow"** → **"Run workflow"**
4. Wait for completion and download artifacts

## 📱 **What You Get**

Each build creates:
- **Always Clock.app** - Ready-to-run macOS app
- **Always-Clock-v1.0.dmg** - Mac-style installer
- **Always-Clock-v1.0.pkg** - System installer wizard
- **Always-Clock-v1.0.zip** - Compressed archive

## ⚡ **Quick Start**

**Fastest way to get the app:**
1. Fork/clone this repository to GitHub
2. Push to main branch (triggers automatic build)
3. Wait ~5 minutes for Actions to complete
4. Download from Actions → Artifacts

## 🔧 **Build Environment**

GitHub Actions provides:
- ✅ **macOS runner** with full Xcode
- ✅ **Code signing** (unsigned builds work fine)
- ✅ **All dependencies** included
- ✅ **Automatic artifact uploads**

## 🎉 **Benefits**

- **No local Xcode needed** - Build in the cloud
- **Multiple formats** - DMG, PKG, ZIP, App bundle
- **Automatic updates** - Push code = new build
- **Easy sharing** - Send GitHub Release links
- **Version control** - Tagged releases with changelogs

## 🛠️ **Troubleshooting**

**If build fails:**
1. Check **Actions** tab for error logs
2. Common issues: missing files, syntax errors
3. Test build locally with `./open-xcode.sh` first

**If artifacts expired:**
1. Re-run the workflow (free on public repos)
2. Or create a release tag for permanent storage

## 📊 **Build Status**

The latest build status is shown by badges in the main README. Green = ready to download!