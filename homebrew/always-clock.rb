cask "always-clock" do
  version "1.0"  # This will be updated automatically
  sha256 "PLACEHOLDER_SHA256"  # This will be updated with actual SHA256

  url "https://github.com/maimon33/always-clock/releases/download/v#{version}/Always%20Clock.dmg"
  name "Always Clock"
  desc "Always-on-top transparent clock for macOS"
  homepage "https://github.com/maimon33/always-clock"

  depends_on macos: ">= :ventura"

  app "Always Clock.app"

  zap trash: [
    "~/Library/Preferences/com.maimon33.AlwaysClock.plist",
  ]
end