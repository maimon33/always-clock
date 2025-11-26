import SwiftUI

struct DigitalClockView: View {
    let time: Date
    @EnvironmentObject var settings: ClockSettings

    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .none
        return formatter
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }

    var body: some View {
        VStack(spacing: 8) {
            Text(timeFormatter.string(from: time))
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .foregroundColor(settings.clockColor)
                .shadow(color: .black.opacity(0.5), radius: 2, x: 1, y: 1)

            Text(dateFormatter.string(from: time))
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(settings.clockColor.opacity(0.8))
                .shadow(color: .black.opacity(0.3), radius: 1, x: 0.5, y: 0.5)
        }
        .padding()
    }
}