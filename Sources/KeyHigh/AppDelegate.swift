import AppKit
import SwiftUI
import Combine

final class AppDelegate: NSObject, NSApplicationDelegate {

    private var panelManager: PanelManager?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Background-style app: no Dock icon, no menu bar item.
        NSApp.setActivationPolicy(.accessory)

        let library = VideoLoader.loadLibrary()
        if library.isEmpty {
            fputs("KeyHigh: no <name>_idle.* videos found in Resources — placeholder will show.\n", stderr)
        }

        let manager = PanelManager(library: library)
        manager.restoreOrCreateDefault()
        self.panelManager = manager
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }
}
