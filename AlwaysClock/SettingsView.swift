import SwiftUI
import ServiceManagement

struct SettingsView: View {
    @EnvironmentObject var settings: ClockSettings
    @State private var startAtLogin = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Always Clock Settings")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Global shortcut: ⌘⇧T to open settings")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 10)

            GroupBox("Clock Type") {
                VStack(alignment: .leading, spacing: 10) {
                    Picker("Clock Style", selection: $settings.isAnalogClock) {
                        Text("Digital").tag(false)
                        Text("Analog").tag(true)
                    }
                    .pickerStyle(.segmented)

                    if !settings.isAnalogClock {
                        Toggle("Show Seconds", isOn: $settings.showSeconds)
                        Toggle("Show Date", isOn: $settings.showDate)

                        Picker("Font", selection: $settings.font) {
                            ForEach(ClockFont.allCases, id: \.self) { Text($0.label).tag($0) }
                        }
                    }
                }
                .padding(8)
            }

            GroupBox("Appearance") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Text transparency:")
                        Spacer()
                        Text("\(Int(settings.transparency * 100))%")
                            .foregroundColor(.secondary)
                    }
                    Slider(value: $settings.transparency, in: 0.1...1.0, step: 0.1)

                    HStack {
                        Text("Text size:")
                        Spacer()
                        Text("\(Int(settings.clockSize * 100))%")
                            .foregroundColor(.secondary)
                    }
                    Slider(value: $settings.clockSize, in: 0.5...2.0, step: 0.1)

                    HStack {
                        Text("Text color:")
                        Spacer()
                        ColorPicker("", selection: $settings.clockColor)
                            .frame(width: 50)
                    }
                }
                .padding(8)
            }

            GroupBox("Frame") {
                VStack(alignment: .leading, spacing: 12) {
                    sliderRow("Width", value: $settings.frameWidth, in: 100...600, step: 10)
                    sliderRow("Height", value: $settings.frameHeight, in: 100...600, step: 10)
                    sliderRow("Frame transparency", value: $settings.frameOpacity, in: 0...1, step: 0.05)
                    sliderRow("Corner radius", value: $settings.frameCornerRadius, in: 0...60, step: 1)

                    HStack {
                        Text("Frame color:")
                        Spacer()
                        ColorPicker("", selection: $settings.frameColor)
                            .frame(width: 50)
                    }
                }
                .padding(8)
            }

            GroupBox("Text Effects") {
                VStack(alignment: .leading, spacing: 12) {
                    sliderRow("Shadow blur", value: $settings.shadowRadius, in: 0...10, step: 0.5)
                    sliderRow("Shadow offset", value: $settings.shadowOffset, in: 0...10, step: 0.5)
                    HStack {
                        Text("Shadow color:")
                        Spacer()
                        ColorPicker("", selection: $settings.shadowColor)
                            .frame(width: 50)
                    }

                    sliderRow("Outline width", value: $settings.outlineWidth, in: 0...5, step: 0.5)
                    HStack {
                        Text("Outline color:")
                        Spacer()
                        ColorPicker("", selection: $settings.outlineColor)
                            .frame(width: 50)
                    }

                    sliderRow("Glow radius", value: $settings.glowRadius, in: 0...30, step: 1)
                    HStack {
                        Text("Glow color:")
                        Spacer()
                        ColorPicker("", selection: $settings.glowColor)
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
                            Button("Top Left") { settings.placeClock(x: .low, y: .high) }
                            Button("Top Center") { settings.placeClock(x: .middle, y: .high) }
                            Button("Top Right") { settings.placeClock(x: .high, y: .high) }
                        }

                        HStack(spacing: 8) {
                            Button("Left Center") { settings.placeClock(x: .low, y: .middle) }
                            Button("Center") { settings.placeClock(x: .middle, y: .middle) }
                            Button("Right Center") { settings.placeClock(x: .high, y: .middle) }
                        }

                        HStack(spacing: 8) {
                            Button("Bottom Left") { settings.placeClock(x: .low, y: .low) }
                            Button("Bottom Center") { settings.placeClock(x: .middle, y: .low) }
                            Button("Bottom Right") { settings.placeClock(x: .high, y: .low) }
                        }
                    }
                    .buttonStyle(.bordered)
                    .font(.caption)
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
                            settings.showSeconds = false
                            settings.showDate = true
                            settings.font = .monospaced
                            settings.frameWidth = 200
                            settings.frameHeight = 200
                            settings.frameOpacity = 0.3
                            settings.frameCornerRadius = 12
                            settings.frameColor = .black
                            settings.shadowColor = .black.opacity(0.5)
                            settings.shadowRadius = 2
                            settings.shadowOffset = 1
                            settings.outlineColor = .black
                            settings.outlineWidth = 0
                            settings.glowColor = .white
                            settings.glowRadius = 0
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

    private func sliderRow(_ title: String, value: Binding<Double>, in range: ClosedRange<Double>, step: Double) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("\(title):")
                Spacer()
                Text(String(format: "%g", value.wrappedValue))
                    .foregroundColor(.secondary)
            }
            Slider(value: value, in: range, step: step)
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
