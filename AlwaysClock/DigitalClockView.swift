import SwiftUI

struct DigitalClockView: View {
    let time: Date
    @EnvironmentObject var settings: ClockSettings

    private static let timeWithSeconds: DateFormatter = makeFormatter(timeStyle: .medium, dateStyle: .none)
    private static let timeOnly: DateFormatter = makeFormatter(timeStyle: .short, dateStyle: .none)
    private static let dateOnly: DateFormatter = makeFormatter(timeStyle: .none, dateStyle: .medium)

    private static func makeFormatter(timeStyle: DateFormatter.Style, dateStyle: DateFormatter.Style) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = timeStyle
        formatter.dateStyle = dateStyle
        return formatter
    }

    var body: some View {
        VStack(spacing: 8 * settings.clockSize) {
            Text((settings.showSeconds ? Self.timeWithSeconds : Self.timeOnly).string(from: time))
                .font(.system(size: 28 * settings.clockSize, weight: .bold, design: .monospaced))
                .foregroundColor(settings.clockColor)
                .shadow(color: .black.opacity(0.5), radius: 2 * settings.clockSize, x: 1 * settings.clockSize, y: 1 * settings.clockSize)

            Text(Self.dateOnly.string(from: time))
                .font(.system(size: 14 * settings.clockSize, weight: .medium))
                .foregroundColor(settings.clockColor.opacity(0.8))
                .shadow(color: .black.opacity(0.3), radius: 1 * settings.clockSize, x: 0.5 * settings.clockSize, y: 0.5 * settings.clockSize)
        }
        .padding(16 * settings.clockSize)
    }
}