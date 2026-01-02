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
    private var globalEventMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupClockWindow()
        setupStatusBarItem()
        setupLoginItem()
        setupGlobalKeyboardShortcut()
    }

    private func setupClockWindow() {
        let contentView = ContentView()
            .environmentObject(ClockSettings.shared)

        let settings = ClockSettings.shared
        let windowSize = max(200 * settings.clockSize, 100)
        clockWindow = NSWindow(
            contentRect: NSRect(x: settings.windowX, y: settings.windowY, width: windowSize, height: windowSize),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        clockWindow?.contentView = NSHostingView(rootView: contentView)
        clockWindow?.backgroundColor = NSColor.clear
        clockWindow?.isOpaque = false
        clockWindow?.level = .floating
        clockWindow?.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]
        clockWindow?.ignoresMouseEvents = true
        clockWindow?.acceptsMouseMovedEvents = false
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

    private func setupGlobalKeyboardShortcut() {
        // Check for accessibility permissions first
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options as CFDictionary)

        if accessEnabled {
            globalEventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
                // Check for Cmd+Shift+T shortcut
                if event.modifierFlags.contains([.command, .shift]) && event.keyCode == 17 { // T key
                    DispatchQueue.main.async {
                        self.openSettings()
                    }
                }
            }
        } else {
            // Show alert about accessibility permission
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                let alert = NSAlert()
                alert.messageText = "Accessibility Permission Required"
                alert.informativeText = "To use the global keyboard shortcut (⌘⇧T), please grant Always Clock accessibility access in System Settings > Privacy & Security > Accessibility."
                alert.addButton(withTitle: "Open System Settings")
                alert.addButton(withTitle: "Skip")

                if alert.runModal() == .alertFirstButtonReturn {
                    NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
                }
            }
        }
    }

    deinit {
        if let monitor = globalEventMonitor {
            NSEvent.removeMonitor(monitor)
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
            updateWindowSize()
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

    @Published var windowX: Double {
        didSet {
            UserDefaults.standard.set(windowX, forKey: "windowX")
            updateWindowPosition()
        }
    }

    @Published var windowY: Double {
        didSet {
            UserDefaults.standard.set(windowY, forKey: "windowY")
            updateWindowPosition()
        }
    }

    init() {
        self.transparency = UserDefaults.standard.double(forKey: "transparency") == 0 ? 0.8 : UserDefaults.standard.double(forKey: "transparency")
        self.clockSize = UserDefaults.standard.double(forKey: "clockSize") == 0 ? 1.0 : UserDefaults.standard.double(forKey: "clockSize")
        self.isAnalogClock = UserDefaults.standard.bool(forKey: "isAnalogClock")

        let savedX = UserDefaults.standard.double(forKey: "windowX")
        self.windowX = savedX == 0 ? 100 : savedX

        let savedY = UserDefaults.standard.double(forKey: "windowY")
        self.windowY = savedY == 0 ? 100 : savedY

        if let colorData = UserDefaults.standard.data(forKey: "clockColor"),
           let nsColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: colorData) {
            self.clockColor = Color(nsColor)
        } else {
            self.clockColor = .white
        }
    }

    private func updateWindowPosition() {
        DispatchQueue.main.async {
            if let clockWindow = NSApp.windows.first(where: { window in
                window.level == .floating
            }) {
                let newOrigin = CGPoint(x: self.windowX, y: self.windowY)
                clockWindow.setFrameOrigin(newOrigin)
            }
        }
    }

    private func updateWindowSize() {
        DispatchQueue.main.async {
            if let clockWindow = NSApp.windows.first(where: { window in
                window.level == .floating
            }) {
                let windowSize = max(200 * self.clockSize, 100)
                let currentFrame = clockWindow.frame
                let newFrame = NSRect(
                    x: currentFrame.origin.x,
                    y: currentFrame.origin.y,
                    width: windowSize,
                    height: windowSize
                )
                clockWindow.setFrame(newFrame, display: true, animate: false)
            }
        }
    }
}