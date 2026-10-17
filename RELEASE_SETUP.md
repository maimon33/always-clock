# Release setup: getting the signing secrets

You need an Apple Developer account. These steps happen in Apple's portals, which need your Apple ID and 2FA, so they can't be scripted. Afterwards, `./set-release-secrets.sh` uploads everything to GitHub.

## 1. Join the Apple Developer Program
- Go to https://developer.apple.com/programs/ and enroll ($99/yr). Individual approval can take up to 48 hours.
- Note your **Team ID**: developer.apple.com → Account → Membership details (10 characters).

## 2. Create two Developer ID certificates
You need the **Account Holder** or an **Admin** role for this.

1. On your Mac, open **Keychain Access → Certificate Assistant → Request a Certificate From a Certificate Authority**. Enter your email, choose **Saved to disk**, and save the `.certSigningRequest` file. Do this once; both certificates can use the same request.
2. At https://developer.apple.com/account/resources/certificates/list click **+**:
   - **Developer ID Application** → upload the CSR → download the `.cer` → double-click to install.
   - Click **+** again, choose **Developer ID Installer** → upload the same CSR → download → double-click to install.

## 3. Export both certificates as one .p12
1. In **Keychain Access → login → My Certificates**, select the "Developer ID Application" entry and the "Developer ID Installer" entry (hold ⌘). Each must show a disclosure triangle with a private key under it.
2. Right-click → **Export 2 items…** → format **Personal Information Exchange (.p12)**.
3. Choose a strong password. You'll enter it in the script.

## 4. Create an App Store Connect API key (for notarization)
1. Go to https://appstoreconnect.apple.com → **Users and Access → Integrations → App Store Connect API → Team Keys** (Account Holder or Admin).
2. Click **+**, name it `always-clock-notary`, role **Developer**.
3. Download the `AuthKey_XXXXXXXXXX.p8` file. **Apple only lets you download it once.** Keep it safe.
4. Note the **Key ID** (shown in the list) and the **Issuer ID** (shown at the top of the page).

## 5. Upload the secrets
From the repo root, with `gh` logged in as an account with admin rights on `maimon33/always-clock`:

```bash
./set-release-secrets.sh
```

It asks for the .p12 path and password, your Team ID, the two identity names (for example `Developer ID Application: Your Name (ABCDE12345)`), the .p8 path, Key ID and Issuer ID. Values go straight to GitHub. Nothing is written to disk.

## 6. Publish
```bash
git checkout main && git pull
git tag v1.4 && git push origin v1.4
```
The release workflow signs, notarizes, staples, publishes the DMG/PKG/ZIP to a GitHub release, and updates the Homebrew cask file.

## Afterwards: keep the .p12 and .p8 safe
Delete the local copies of the .p12 and .p8 once the secrets are uploaded and you have a backup somewhere secure. Anyone with them can sign software as you.
