import SwiftUI
import ServiceManagement

struct SettingsView: View {
    @EnvironmentObject var settings: ClockSettings
    @State private var startAtLogin = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
            Text("Always Clock Settings")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.bottom, 10)

            GroupBox("Clock Type") {
                VStack(alignment: .leading, spacing: 10) {
                    Picker("Clock Style", selection: $settings.isAnalogClock) {
                        Text("Digital").tag(false)
                        Text("Analog").tag(true)
                    }
                    .pickerStyle(.segmented)
                }
                .padding(8)
            }

            GroupBox("Appearance") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Transparency:")
                        Spacer()
                        Text("\(Int(settings.transparency * 100))%")
                            .foregroundColor(.secondary)
                    }
                    Slider(value: $settings.transparency, in: 0.1...1.0, step: 0.1)

                    HStack {
                        Text("Size:")
                        Spacer()
                        Text("\(Int(settings.clockSize * 100))%")
                            .foregroundColor(.secondary)
                    }
                    Slider(value: $settings.clockSize, in: 0.5...2.0, step: 0.1)

                    HStack {
                        Text("Color:")
                        Spacer()
                        ColorPicker("", selection: $settings.clockColor)
                            .frame(width: 50)
                    }
                }
                .padding(8)
            }

            GroupBox("Position") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("X Position:")
                        Spacer()
                        TextField("X", value: $settings.windowX, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 80)
                    }

                    HStack {
                        Text("Y Position:")
                        Spacer()
                        TextField("Y", value: $settings.windowY, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 80)
                    }

                    VStack(spacing: 8) {
                        Text("Predefined Locations:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        HStack(spacing: 8) {
                            Button("Top Left") {
                                if let screen = NSScreen.main {
                                    let screenRect = screen.frame
                                    settings.windowX = 20
                                    settings.windowY = screenRect.height - 220
                                }
                            }
                            .buttonStyle(.bordered)
                            .font(.caption)

                            Button("Top Center") {
                                if let screen = NSScreen.main {
                                    let screenRect = screen.frame
                                    settings.windowX = (screenRect.width - 200) / 2
                                    settings.windowY = screenRect.height - 220
                                }
                            }
                            .buttonStyle(.bordered)
                            .font(.caption)

                            Button("Top Right") {
                                if let screen = NSScreen.main {
                                    let screenRect = screen.frame
                                    settings.windowX = screenRect.width - 220
                                    settings.windowY = screenRect.height - 220
                                }
                            }
                            .buttonStyle(.bordered)
                            .font(.caption)
                        }

                        HStack(spacing: 8) {
                            Button("Left Center") {
                                if let screen = NSScreen.main {
                                    let screenRect = screen.frame
                                    settings.windowX = 20
                                    settings.windowY = (screenRect.height - 200) / 2
                                }
                            }
                            .buttonStyle(.bordered)
                            .font(.caption)

                            Button("Center") {
                                if let screen = NSScreen.main {
                                    let screenRect = screen.frame
                                    settings.windowX = (screenRect.width - 200) / 2
                                    settings.windowY = (screenRect.height - 200) / 2
                                }
                            }
                            .buttonStyle(.bordered)
                            .font(.caption)

                            Button("Right Center") {
                                if let screen = NSScreen.main {
                                    let screenRect = screen.frame
                                    settings.windowX = screenRect.width - 220
                                    settings.windowY = (screenRect.height - 200) / 2
                                }
                            }
                            .buttonStyle(.bordered)
                            .font(.caption)
                        }

                        HStack(spacing: 8) {
                            Button("Bottom Left") {
                                if let screen = NSScreen.main {
                                    settings.windowX = 20
                                    settings.windowY = 20
                                }
                            }
                            .buttonStyle(.bordered)
                            .font(.caption)

                            Button("Bottom Center") {
                                if let screen = NSScreen.main {
                                    let screenRect = screen.frame
                                    settings.windowX = (screenRect.width - 200) / 2
                                    settings.windowY = 20
                                }
                            }
                            .buttonStyle(.bordered)
                            .font(.caption)

                            Button("Bottom Right") {
                                if let screen = NSScreen.main {
                                    let screenRect = screen.frame
                                    settings.windowX = screenRect.width - 220
                                    settings.windowY = 20
                                }
                            }
                            .buttonStyle(.bordered)
                            .font(.caption)
                        }
                    }
                }
                .padding(8)
            }

            GroupBox("System") {
                VStack(alignment: .leading, spacing: 10) {
                    Toggle("Start at login", isOn: $startAtLogin)
                        .onChange(of: startAtLogin) { enabled in
                            setLoginItemEnabled(enabled)
                        }

                    HStack {
                        Button("Reset to Defaults") {
                            settings.transparency = 0.8
                            settings.clockSize = 1.0
                            settings.isAnalogClock = false
                            settings.clockColor = .white
                            settings.windowX = 100
                            settings.windowY = 100
                        }
                        .buttonStyle(.bordered)

                        Spacer()

                        Button("Quit Always Clock") {
                            NSApplication.shared.terminate(nil)
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(.red)
                    }
                }
                .padding(8)
            }

            Spacer()
            }
            .padding(20)
        }
        .frame(width: 400, height: 500)
        .onAppear {
            checkLoginItemStatus()
        }
    }

    private func setLoginItemEnabled(_ enabled: Bool) {
        if #available(macOS 13.0, *) {
            do {
                if enabled {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                print("Failed to set login item: \(error)")
            }
        }
    }

    private func checkLoginItemStatus() {
        if #available(macOS 13.0, *) {
            startAtLogin = SMAppService.mainApp.status == .enabled
        }
    }
}