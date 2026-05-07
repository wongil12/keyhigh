import AppKit

final class CharacterPanel: NSPanel {

    let originDefaultsKey: String

    init(initialSize: NSSize, persistenceKey: String = "characterOrigin") {
        self.originDefaultsKey = persistenceKey
        let initialFrame = NSRect(origin: .zero, size: initialSize)
        super.init(
            contentRect: initialFrame,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        isOpaque = false
        backgroundColor = .clear
        hasShadow = false
        isMovable = true
        isMovableByWindowBackground = true
        ignoresMouseEvents = false
        isReleasedWhenClosed = false
        hidesOnDeactivate = false
        level = .statusBar
        collectionBehavior = [
            .canJoinAllSpaces,
            .stationary,
            .ignoresCycle,
            .fullScreenAuxiliary
        ]
        animationBehavior = .none

        let origin = loadSavedOrigin(forSize: initialSize)
            ?? Self.defaultOrigin(forSize: initialSize)
        setFrameOrigin(origin)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDidMove(_:)),
            name: NSWindow.didMoveNotification,
            object: self
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }

    /// Resize the panel in place, anchoring at the current bottom-left and
    /// clamping back onto a visible screen if the new frame would spill off.
    func applySize(_ newSize: NSSize) {
        let candidate = NSRect(origin: frame.origin, size: newSize)
        let clamped = Self.clamp(frame: candidate)
        setFrame(clamped, display: true, animate: false)
    }

    @objc private func handleDidMove(_ notification: Notification) {
        saveOrigin(frame.origin)
    }

    // MARK: - Origin persistence

    private func loadSavedOrigin(forSize size: NSSize) -> NSPoint? {
        let defaults = UserDefaults.standard
        guard let dict = defaults.dictionary(forKey: originDefaultsKey),
              let x = dict["x"] as? Double,
              let y = dict["y"] as? Double
        else { return nil }
        let candidate = NSRect(origin: NSPoint(x: x, y: y), size: size)
        return Self.clamp(frame: candidate).origin
    }

    private func saveOrigin(_ point: NSPoint) {
        let defaults = UserDefaults.standard
        defaults.set(["x": Double(point.x), "y": Double(point.y)], forKey: originDefaultsKey)
    }

    static func defaultOrigin(forSize size: NSSize) -> NSPoint {
        guard let screen = NSScreen.main else { return .zero }
        let visible = screen.visibleFrame
        let margin: CGFloat = 24
        return NSPoint(
            x: visible.maxX - size.width - margin,
            y: visible.minY + margin
        )
    }

    /// Keep the supplied frame inside some visible screen. If it doesn't
    /// intersect any, fall back to the default bottom-right placement.
    static func clamp(frame: NSRect) -> NSRect {
        let screens = NSScreen.screens
        if screens.contains(where: { $0.visibleFrame.intersects(frame) }) {
            return frame
        }
        return NSRect(origin: defaultOrigin(forSize: frame.size), size: frame.size)
    }
}
