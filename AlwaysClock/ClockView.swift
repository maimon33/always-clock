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
    }
}