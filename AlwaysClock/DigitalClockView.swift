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
                .font(.system(size: 28 * settings.clockSize, weight: .bold, design: settings.font.design))
                .foregroundColor(settings.clockColor)
                .textEffects(settings)

            if settings.showDate {
                Text(Self.dateOnly.string(from: time))
                    .font(.system(size: 14 * settings.clockSize, weight: .medium, design: settings.font.design))
                    .foregroundColor(settings.clockColor.opacity(0.8))
                    .textEffects(settings)
            }
        }
    }
}

extension View {
    /// Outline is four zero-blur shadows that cascade into a one-step ring; zero width draws nothing.
    func textEffects(_ settings: ClockSettings) -> some View {
        let outline = settings.outlineWidth * settings.clockSize
        let shadow = settings.shadowOffset * settings.clockSize
        return self
            .shadow(color: settings.outlineColor, radius: 0, x: outline, y: 0)
            .shadow(color: settings.outlineColor, radius: 0, x: -outline, y: 0)
            .shadow(color: settings.outlineColor, radius: 0, x: 0, y: outline)
            .shadow(color: settings.outlineColor, radius: 0, x: 0, y: -outline)
            .shadow(color: settings.glowColor, radius: settings.glowRadius * settings.clockSize)
            .shadow(color: settings.shadowColor, radius: settings.shadowRadius * settings.clockSize, x: shadow, y: shadow)
    }
}
