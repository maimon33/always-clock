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
                .stroke(settings.clockColor.opacity(0.3), lineWidth: 2)
                .frame(width: 160, height: 160)

            ForEach(0..<12) { hour in
                Rectangle()
                    .fill(settings.clockColor)
                    .frame(width: 2, height: 10)
                    .offset(y: -70)
                    .rotationEffect(.degrees(Double(hour * 30)))
            }

            ForEach(0..<60) { minute in
                if minute % 5 != 0 {
                    Rectangle()
                        .fill(settings.clockColor.opacity(0.5))
                        .frame(width: 1, height: 5)
                        .offset(y: -72.5)
                        .rotationEffect(.degrees(Double(minute * 6)))
                }
            }

            Rectangle()
                .fill(settings.clockColor)
                .frame(width: 3, height: 45)
                .offset(y: -22.5)
                .rotationEffect(.degrees(hourAngle))
                .shadow(color: .black.opacity(0.3), radius: 1, x: 1, y: 1)

            Rectangle()
                .fill(settings.clockColor)
                .frame(width: 2, height: 60)
                .offset(y: -30)
                .rotationEffect(.degrees(minuteAngle))
                .shadow(color: .black.opacity(0.3), radius: 1, x: 1, y: 1)

            Rectangle()
                .fill(.red)
                .frame(width: 1, height: 70)
                .offset(y: -35)
                .rotationEffect(.degrees(secondAngle))
                .shadow(color: .black.opacity(0.3), radius: 1, x: 1, y: 1)

            Circle()
                .fill(settings.clockColor)
                .frame(width: 8, height: 8)
                .shadow(color: .black.opacity(0.3), radius: 1, x: 1, y: 1)
        }
        .padding()
        .animation(.easeInOut(duration: 0.1), value: secondAngle)
    }
}