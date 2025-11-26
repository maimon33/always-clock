import SwiftUI

struct ContentView: View {
    @EnvironmentObject var settings: ClockSettings
    @State private var dragOffset = CGSize.zero
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
        .offset(dragOffset)
        .scaleEffect(isDragging ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isDragging)
        .gesture(
            DragGesture()
                .onChanged { value in
                    if !isDragging {
                        isDragging = true
                    }
                    dragOffset = value.translation
                }
                .onEnded { value in
                    isDragging = false
                    if let window = NSApp.keyWindow {
                        let newOrigin = CGPoint(
                            x: window.frame.origin.x + value.translation.width,
                            y: window.frame.origin.y - value.translation.height
                        )
                        window.setFrameOrigin(newOrigin)
                    }
                    dragOffset = .zero
                }
        )
        .onHover { isHovering in
            if let window = NSApp.windows.first(where: { $0.contentView is NSHostingView<ContentView> }) {
                window.ignoresMouseEvents = !isHovering
            }
        }
        .frame(width: 200 * settings.clockSize, height: 200 * settings.clockSize)
    }
}