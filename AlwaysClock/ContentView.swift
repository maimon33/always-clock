import SwiftUI

struct ContentView: View {
    @EnvironmentObject var settings: ClockSettings

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: settings.frameCornerRadius)
                .fill(settings.frameColor)
                .opacity(settings.frameOpacity)

            ClockView()
                .environmentObject(settings)
                .opacity(settings.transparency)
        }
    }
}
