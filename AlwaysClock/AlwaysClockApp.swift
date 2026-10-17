import SwiftUI
import Carbon.HIToolbox

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
    private var hotKeyRef: EventHotKeyRef?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupClockWindow()
        setupStatusBarItem()
        setupSettingsHotKey()
    }

    private func setupClockWindow() {
        let contentView = ContentView()
            .environmentObject(ClockSettings.shared)

        let settings = ClockSettings.shared
        clockWindow = NSWindow(
            contentRect: NSRect(x: settings.windowX, y: settings.windowY, width: settings.frameWidth, height: settings.frameHeight),
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

        NotificationCenter.default.addObserver(
            forName: NSWindow.didMoveNotification,
            object: clockWindow,
            queue: .main
        ) { [weak self] _ in
            guard let origin = self?.clockWindow?.frame.origin else { return }
            ClockSettings.shared.windowX = Double(origin.x)
            ClockSettings.shared.windowY = Double(origin.y)
        }

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

            NotificationCenter.default.addObserver(
                forName: NSWindow.willCloseNotification,
                object: settingsWindow,
                queue: .main
            ) { [weak self] _ in
                self?.setClockDraggable(false)
                NSApp.setActivationPolicy(.accessory)
            }
        }

        setClockDraggable(true)
        NSApp.setActivationPolicy(.regular)
        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func setClockDraggable(_ draggable: Bool) {
        clockWindow?.ignoresMouseEvents = !draggable
        clockWindow?.isMovableByWindowBackground = draggable
    }

    @objc private func quitApp() {
        NSApplication.shared.terminate(self)
    }

    /// Registers ⌘⇧T as a system hotkey. Unlike a global key monitor, this needs no
    /// Accessibility or Input Monitoring permission, so macOS never prompts for it.
    private func setupSettingsHotKey() {
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        let selfPointer = Unmanaged.passUnretained(self).toOpaque()

        InstallEventHandler(GetApplicationEventTarget(), { _, _, userData in
            guard let userData else { return OSStatus(eventNotHandledErr) }
            let delegate = Unmanaged<AppDelegate>.fromOpaque(userData).takeUnretainedValue()
            DispatchQueue.main.async { delegate.openSettings() }
            return noErr
        }, 1, &eventType, selfPointer, nil)

        let hotKeyID = EventHotKeyID(signature: OSType(0x41434C4B), id: 1) // 'ACLK'
        RegisterEventHotKey(UInt32(kVK_ANSI_T), UInt32(cmdKey | shiftKey), hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)
    }
}

enum ClockFont: String, CaseIterable {
    case monospaced, rounded, serif, standard

    var design: Font.Design {
        switch self {
        case .monospaced: return .monospaced
        case .rounded: return .rounded
        case .serif: return .serif
        case .standard: return .default
        }
    }

    var label: String {
        switch self {
        case .monospaced: return "Monospaced"
        case .rounded: return "Rounded"
        case .serif: return "Serif"
        case .standard: return "Default"
        }
    }
}

class ClockSettings: ObservableObject {
    static let shared = ClockSettings()

    /// Text opacity (clock digits and date).
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

    @Published var frameWidth: Double {
        didSet {
            UserDefaults.standard.set(frameWidth, forKey: "frameWidth")
            updateWindowSize()
        }
    }

    @Published var frameHeight: Double {
        didSet {
            UserDefaults.standard.set(frameHeight, forKey: "frameHeight")
            updateWindowSize()
        }
    }

    @Published var frameOpacity: Double {
        didSet {
            UserDefaults.standard.set(frameOpacity, forKey: "frameOpacity")
        }
    }

    @Published var frameCornerRadius: Double {
        didSet {
            UserDefaults.standard.set(frameCornerRadius, forKey: "frameCornerRadius")
        }
    }

    @Published var frameColor: Color {
        didSet {
            Self.save(frameColor, forKey: "frameColor")
        }
    }

    @Published var showDate: Bool {
        didSet {
            UserDefaults.standard.set(showDate, forKey: "showDate")
        }
    }

    @Published var font: ClockFont {
        didSet {
            UserDefaults.standard.set(font.rawValue, forKey: "font")
        }
    }

    @Published var shadowColor: Color {
        didSet {
            Self.save(shadowColor, forKey: "shadowColor")
        }
    }

    @Published var shadowRadius: Double {
        didSet {
            UserDefaults.standard.set(shadowRadius, forKey: "shadowRadius")
        }
    }

    @Published var shadowOffset: Double {
        didSet {
            UserDefaults.standard.set(shadowOffset, forKey: "shadowOffset")
        }
    }

    @Published var outlineColor: Color {
        didSet {
            Self.save(outlineColor, forKey: "outlineColor")
        }
    }

    @Published var outlineWidth: Double {
        didSet {
            UserDefaults.standard.set(outlineWidth, forKey: "outlineWidth")
        }
    }

    @Published var glowColor: Color {
        didSet {
            Self.save(glowColor, forKey: "glowColor")
        }
    }

    @Published var glowRadius: Double {
        didSet {
            UserDefaults.standard.set(glowRadius, forKey: "glowRadius")
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

    @Published var showSeconds: Bool {
        didSet {
            UserDefaults.standard.set(showSeconds, forKey: "showSeconds")
        }
    }

    init() {
        self.transparency = UserDefaults.standard.double(forKey: "transparency") == 0 ? 0.8 : UserDefaults.standard.double(forKey: "transparency")
        self.clockSize = UserDefaults.standard.double(forKey: "clockSize") == 0 ? 1.0 : UserDefaults.standard.double(forKey: "clockSize")
        self.isAnalogClock = UserDefaults.standard.bool(forKey: "isAnalogClock")

        self.windowX = UserDefaults.standard.object(forKey: "windowX") as? Double ?? 100
        self.windowY = UserDefaults.standard.object(forKey: "windowY") as? Double ?? 100

        if let colorData = UserDefaults.standard.data(forKey: "clockColor"),
           let nsColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: colorData) {
            self.clockColor = Color(nsColor)
        } else {
            self.clockColor = .white
        }

        self.showSeconds = UserDefaults.standard.bool(forKey: "showSeconds")

        self.frameWidth = UserDefaults.standard.object(forKey: "frameWidth") as? Double ?? 200
        self.frameHeight = UserDefaults.standard.object(forKey: "frameHeight") as? Double ?? 200
        self.frameOpacity = UserDefaults.standard.object(forKey: "frameOpacity") as? Double ?? 0.3
        self.frameCornerRadius = UserDefaults.standard.object(forKey: "frameCornerRadius") as? Double ?? 12
        self.frameColor = Self.load(forKey: "frameColor", default: .black)
        self.showDate = UserDefaults.standard.object(forKey: "showDate") as? Bool ?? true
        self.font = UserDefaults.standard.string(forKey: "font").flatMap(ClockFont.init(rawValue:)) ?? .monospaced
        self.shadowColor = Self.load(forKey: "shadowColor", default: .black.opacity(0.5))
        self.shadowRadius = UserDefaults.standard.object(forKey: "shadowRadius") as? Double ?? 2
        self.shadowOffset = UserDefaults.standard.object(forKey: "shadowOffset") as? Double ?? 1
        self.outlineColor = Self.load(forKey: "outlineColor", default: .black)
        self.outlineWidth = UserDefaults.standard.object(forKey: "outlineWidth") as? Double ?? 0
        self.glowColor = Self.load(forKey: "glowColor", default: .white)
        self.glowRadius = UserDefaults.standard.object(forKey: "glowRadius") as? Double ?? 0
    }

    private static func save(_ color: Color, forKey key: String) {
        if let data = try? NSKeyedArchiver.archivedData(withRootObject: NSColor(color), requiringSecureCoding: false) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private static func load(forKey key: String, default fallback: Color) -> Color {
        guard let data = UserDefaults.standard.data(forKey: key),
              let nsColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: data) else { return fallback }
        return Color(nsColor)
    }

    enum Placement { case low, middle, high }

    /// Moves the clock to a spot inside the visible area of its screen (clear of the menu bar and Dock).
    /// AppKit's y axis grows upward, so `.high` on the vertical axis is the top edge.
    func placeClock(x: Placement, y: Placement) {
        guard let window = clockWindow, let area = (window.screen ?? NSScreen.main)?.visibleFrame else { return }
        let margin: CGFloat = 20
        let size = window.frame.size

        switch x {
        case .low: windowX = Double(area.minX + margin)
        case .middle: windowX = Double(area.midX - size.width / 2)
        case .high: windowX = Double(area.maxX - size.width - margin)
        }

        switch y {
        case .low: windowY = Double(area.minY + margin)
        case .middle: windowY = Double(area.midY - size.height / 2)
        case .high: windowY = Double(area.maxY - size.height - margin)
        }
    }

    private var clockWindow: NSWindow? {
        NSApp.windows.first { $0.level == .floating }
    }

    private func updateWindowPosition() {
        DispatchQueue.main.async {
            guard let clockWindow = self.clockWindow else { return }
            let newOrigin = CGPoint(x: self.windowX, y: self.windowY)
            if clockWindow.frame.origin != newOrigin {
                clockWindow.setFrameOrigin(newOrigin)
            }
        }
    }

    private func updateWindowSize() {
        DispatchQueue.main.async {
            guard let clockWindow = self.clockWindow else { return }
            let currentFrame = clockWindow.frame
            let newFrame = NSRect(
                x: currentFrame.origin.x,
                y: currentFrame.origin.y,
                width: self.frameWidth,
                height: self.frameHeight
            )
            clockWindow.setFrame(newFrame, display: true, animate: false)
        }
    }
}