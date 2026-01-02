cask "always-clock" do
  version "1.0"
  sha256 "85086e4457b66d7350a7a47918f2e3e4fe0dcfd59ec822e5279a860688430181"

  url "https://github.com/maimon33/always-clock/releases/download/v#{version}/Always-Clock-v#{version}.dmg"
  name "Always Clock"
  desc "Always-on-top transparent clock for macOS"
  homepage "https://github.com/maimon33/always-clock"

  depends_on macos: ">= :ventura"

  app "Always Clock.app"

  zap trash: [
    "~/Library/Preferences/com.maimon33.AlwaysClock.plist",
  ]
end