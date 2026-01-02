import SwiftUI

struct AnalogClockView: View {
    let time: Date
    @EnvironmentObject var settings: ClockSettings

    private var hourAngle: Double {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: time)
        let minute = calendar.component(.minute, from: time)
        return Double((hour % 12) * 30 + minute / 2) - 90
    }

    private var minuteAngle: Double {
        let calendar = Calendar.current
        let minute = calendar.component(.minute, from: time)
        return Double(minute * 6) - 90
    }

    private var secondAngle: Double {
        let calendar = Calendar.current
        let second = calendar.component(.second, from: time)
        return Double(second * 6) - 90
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(settings.clockColor.opacity(0.3), lineWidth: 2 * settings.clockSize)
                .frame(width: 160 * settings.clockSize, height: 160 * settings.clockSize)

            ForEach(0..<12) { hour in
                Rectangle()
                    .fill(settings.clockColor)
                    .frame(width: 2 * settings.clockSize, height: 10 * settings.clockSize)
                    .offset(y: -70 * settings.clockSize)
                    .rotationEffect(.degrees(Double(hour * 30)))
            }

            ForEach(0..<60) { minute in
                if minute % 5 != 0 {
                    Rectangle()
                        .fill(settings.clockColor.opacity(0.5))
                        .frame(width: 1 * settings.clockSize, height: 5 * settings.clockSize)
                        .offset(y: -72.5 * settings.clockSize)
                        .rotationEffect(.degrees(Double(minute * 6)))
                }
            }

            Rectangle()
                .fill(settings.clockColor)
                .frame(width: 3 * settings.clockSize, height: 45 * settings.clockSize)
                .offset(y: -22.5 * settings.clockSize)
                .rotationEffect(.degrees(hourAngle))
                .shadow(color: .black.opacity(0.3), radius: 1 * settings.clockSize, x: 1 * settings.clockSize, y: 1 * settings.clockSize)

            Rectangle()
                .fill(settings.clockColor)
                .frame(width: 2 * settings.clockSize, height: 60 * settings.clockSize)
                .offset(y: -30 * settings.clockSize)
                .rotationEffect(.degrees(minuteAngle))
                .shadow(color: .black.opacity(0.3), radius: 1 * settings.clockSize, x: 1 * settings.clockSize, y: 1 * settings.clockSize)

            Rectangle()
                .fill(.red)
                .frame(width: 1 * settings.clockSize, height: 70 * settings.clockSize)
                .offset(y: -35 * settings.clockSize)
                .rotationEffect(.degrees(secondAngle))
                .shadow(color: .black.opacity(0.3), radius: 1 * settings.clockSize, x: 1 * settings.clockSize, y: 1 * settings.clockSize)

            Circle()
                .fill(settings.clockColor)
                .frame(width: 8 * settings.clockSize, height: 8 * settings.clockSize)
                .shadow(color: .black.opacity(0.3), radius: 1 * settings.clockSize, x: 1 * settings.clockSize, y: 1 * settings.clockSize)
        }
        .padding(16 * settings.clockSize)
        .animation(.easeInOut(duration: 0.1), value: secondAngle)
    }
}