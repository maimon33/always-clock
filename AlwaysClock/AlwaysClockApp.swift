import SwiftUI
import ServiceManagement

@main
struct AlwaysClockApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var settings = ClockSettings()

    var body: some Scene {
        Settings {
            SettingsView()
                .environmentObject(settings)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var clockWindow: NSWindow?
    private var statusItem: NSStatusItem?
    private var settingsWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupClockWindow()
        setupStatusBarItem()
        setupLoginItem()
    }

    private func setupClockWindow() {
        let contentView = ContentView()
            .environmentObject(ClockSettings.shared)

        clockWindow = NSWindow(
            contentRect: NSRect(x: 100, y: 100, width: 200, height: 200),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        clockWindow?.contentView = NSHostingView(rootView: contentView)
        clockWindow?.backgroundColor = NSColor.clear
        clockWindow?.isOpaque = false
        clockWindow?.level = .floating
        clockWindow?.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]
        clockWindow?.ignoresMouseEvents = false
        clockWindow?.acceptsMouseMovedEvents = true
        clockWindow?.isMovableByWindowBackground = false
        clockWindow?.hasShadow = false
        clockWindow?.makeKeyAndOrderFront(nil)

        NSApp.setActivationPolicy(.accessory)
    }

    private func setupStatusBarItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "clock", accessibilityDescription: "Always Clock")
        }

        let menu = NSMenu()

        let settingsItem = NSMenuItem(title: "Settings", action: #selector(openSettings), keyEquivalent: "")
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "Quit Always Clock", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem?.menu = menu
    }

    @objc func openSettings() {
        if settingsWindow == nil {
            let settingsView = SettingsView()
                .environmentObject(ClockSettings.shared)

            settingsWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 400, height: 500),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )

            settingsWindow?.title = "Always Clock Settings"
            settingsWindow?.contentView = NSHostingView(rootView: settingsView)
            settingsWindow?.center()
            settingsWindow?.setFrameAutosaveName("SettingsWindow")
            settingsWindow?.isReleasedWhenClosed = false
        }

        NSApp.setActivationPolicy(.regular)
        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        // Set back to accessory when window closes
        NotificationCenter.default.addObserver(
            forName: NSWindow.willCloseNotification,
            object: settingsWindow,
            queue: .main
        ) { _ in
            NSApp.setActivationPolicy(.accessory)
        }
    }

    @objc private func quitApp() {
        NSApplication.shared.terminate(self)
    }

    private func setupLoginItem() {
        if #available(macOS 13.0, *) {
            try? SMAppService.mainApp.register()
        }
    }
}

class ClockSettings: ObservableObject {
    static let shared = ClockSettings()

    @Published var transparency: Double {
        didSet {
            UserDefaults.standard.set(transparency, forKey: "transparency")
        }
    }

    @Published var clockSize: Double {
        didSet {
            UserDefaults.standard.set(clockSize, forKey: "clockSize")
        }
    }

    @Published var isAnalogClock: Bool {
        didSet {
            UserDefaults.standard.set(isAnalogClock, forKey: "isAnalogClock")
        }
    }

    @Published var clockColor: Color {
        didSet {
            if let colorData = try? NSKeyedArchiver.archivedData(withRootObject: NSColor(clockColor), requiringSecureCoding: false) {
                UserDefaults.standard.set(colorData, forKey: "clockColor")
            }
        }
    }

    init() {
        self.transparency = UserDefaults.standard.double(forKey: "transparency") == 0 ? 0.8 : UserDefaults.standard.double(forKey: "transparency")
        self.clockSize = UserDefaults.standard.double(forKey: "clockSize") == 0 ? 1.0 : UserDefaults.standard.double(forKey: "clockSize")
        self.isAnalogClock = UserDefaults.standard.bool(forKey: "isAnalogClock")

        if let colorData = UserDefaults.standard.data(forKey: "clockColor"),
           let nsColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: colorData) {
            self.clockColor = Color(nsColor)
        } else {
            self.clockColor = .white
        }
    }
}