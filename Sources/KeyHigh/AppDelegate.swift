import AppKit
import SwiftUI
import Combine

final class AppDelegate: NSObject, NSApplicationDelegate {

    private var panel: CharacterPanel?
    private var selection: CharacterSelectionModel?
    private var sizeModel: SizeSelectionModel?
    private var cancellables: Set<AnyCancellable> = []

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Background-style app: no Dock icon, no menu bar item.
        NSApp.setActivationPolicy(.accessory)

        let library = VideoLoader.loadLibrary()
        if library.isEmpty {
            fputs("KeyHigh: no <name>_idle.* videos found in Resources — placeholder will show.\n", stderr)
        }

        let selection = CharacterSelectionModel(library: library, defaultID: "mouse")
        let sizeModel = SizeSelectionModel(defaultSize: .small)
        self.selection = selection
        self.sizeModel = sizeModel

        let view = CharacterView(selection: selection, sizeModel: sizeModel)
        let host = NSHostingView(rootView: view)
        host.frame = NSRect(origin: .zero, size: sizeModel.current.nsSize)
        host.autoresizingMask = [.width, .height]

        let panel = CharacterPanel(initialSize: sizeModel.current.nsSize)
        panel.contentView = host
        panel.orderFrontRegardless()
        self.panel = panel

        // Resize the panel whenever the user picks a new size from the menu.
        sizeModel.$current
            .removeDuplicates()
            .dropFirst()                                 // skip the initial value (panel was already built with it)
            .sink { [weak panel] newSize in
                panel?.applySize(newSize.nsSize)
            }
            .store(in: &cancellables)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }
}
