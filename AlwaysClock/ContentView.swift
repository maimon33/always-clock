import SwiftUI

struct ContentView: View {
    @EnvironmentObject var settings: ClockSettings

    var body: some View {
        ZStack {
            Color.clear
                .background(.ultraThinMaterial)
                .opacity(settings.transparency * 0.3)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            ClockView()
                .environmentObject(settings)
        }
        .opacity(settings.transparency)
    }
}

