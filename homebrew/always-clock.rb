cask "always-clock" do
  version "1.1"
  sha256 "f8eab3fa0b100c86a4b6a38f41fca12a33043f5dd4cc715367f5bd885b442d9f"

  url "https://github.com/maimon33/always-clock/releases/download/v#{version}/Always-Clock-v1.0.dmg"
  name "Always Clock"
  desc "Always-on-top transparent clock for macOS"
  homepage "https://github.com/maimon33/always-clock"

  depends_on macos: ">= :ventura"

  app "Always Clock.app"

  zap trash: [
    "~/Library/Preferences/com.maimon33.AlwaysClock.plist",
  ]
end