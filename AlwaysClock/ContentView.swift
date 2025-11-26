import SwiftUI

struct ContentView: View {
    @EnvironmentObject var settings: ClockSettings
    @State private var isDragging = false

    var body: some View {
        ZStack {
            Color.clear
                .background(.ultraThinMaterial)
                .opacity(settings.transparency * 0.3)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            ClockView()
                .environmentObject(settings)
                .scaleEffect(settings.clockSize)
        }
        .opacity(settings.transparency)
        .scaleEffect(isDragging ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isDragging)
        .gesture(
            DragGesture(coordinateSpace: .global)
                .onChanged { value in
                    isDragging = true

                    // Get the mouse location in global coordinates
                    let mouseLocation = value.location

                    // Find our clock window
                    if let clockWindow = NSApp.windows.first(where: { window in
                        window.contentView is NSHostingView<ContentView> && window.level == .floating
                    }) {
                        // Calculate new window position (center the window on mouse)
                        let windowSize = clockWindow.frame.size
                        let newOrigin = CGPoint(
                            x: mouseLocation.x - windowSize.width / 2,
                            y: NSScreen.main?.frame.height ?? 0 - mouseLocation.y - windowSize.height / 2
                        )

                        // Move the window
                        clockWindow.setFrameOrigin(newOrigin)
                    }
                }
                .onEnded { _ in
                    isDragging = false
                }
        )
    }
}