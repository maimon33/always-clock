import SwiftUI

struct ClockView: View {
    @EnvironmentObject var settings: ClockSettings
    @State private var currentTime = Date()

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        Group {
            if settings.isAnalogClock {
                AnalogClockView(time: currentTime)
                    .environmentObject(settings)
            } else {
                DigitalClockView(time: currentTime)
                    .environmentObject(settings)
            }
        }
        .onReceive(timer) { time in
            currentTime = time
        }
        .contextMenu {
            Button("Switch to \(settings.isAnalogClock ? "Digital" : "Analog")") {
                withAnimation(.easeInOut) {
                    settings.isAnalogClock.toggle()
                }
            }

            Divider()

            Button("Settings...") {
                if let appDelegate = NSApp.delegate as? AppDelegate {
                    appDelegate.openSettings()
                }
            }

            Divider()

            Button("Quit Always Clock") {
                NSApplication.shared.terminate(nil)
            }
        }
    }
}