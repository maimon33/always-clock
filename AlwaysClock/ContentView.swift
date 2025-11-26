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

            // Invisible clickable overlay for settings access
            ClickThroughView()
        }
        .opacity(settings.transparency)
    }
}

struct ClickThroughView: NSViewRepresentable {
    func makeNSView(context: Context) -> ClickThroughNSView {
        ClickThroughNSView()
    }

    func updateNSView(_ nsView: ClickThroughNSView, context: Context) {}
}

class ClickThroughNSView: NSView {
    override func hitTest(_ point: NSPoint) -> NSView? {
        let bounds = self.bounds
        let center = NSPoint(x: bounds.midX, y: bounds.midY)
        let distance = sqrt(pow(point.x - center.x, 2) + pow(point.y - center.y, 2))

        // Only respond to clicks within 20 points of center
        if distance <= 20 {
            return self
        }

        // For clicks outside center, make window ignore this event
        if let window = self.window {
            window.ignoresMouseEvents = true

            // Re-enable mouse events after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                window.ignoresMouseEvents = false
            }
        }

        return nil
    }

    override func mouseDown(with event: NSEvent) {
        // Open settings when center is clicked
        if let appDelegate = NSApp.delegate as? AppDelegate {
            appDelegate.openSettings()
        }
    }
}