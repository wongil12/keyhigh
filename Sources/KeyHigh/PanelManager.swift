import AppKit
import SwiftUI
import Combine

final class PanelManager {

    private struct ManagedPanel {
        let id: String
        let panel: CharacterPanel
        let selection: CharacterSelectionModel
        let sizeModel: SizeSelectionModel
        var cancellables: Set<AnyCancellable> = []
    }

    private let library: [CharacterAssets]
    private var panels: [String: ManagedPanel] = [:]

    private static let panelIDsKey = "panelIDs"

    init(library: [CharacterAssets]) {
        self.library = library
    }

    // MARK: - Public

    func restoreOrCreateDefault() {
        let savedIDs = UserDefaults.standard.stringArray(forKey: Self.panelIDsKey) ?? []
        if savedIDs.isEmpty {
            createPanel()
        } else {
            for id in savedIDs {
                createPanel(id: id)
            }
        }
    }

    @discardableResult
    func createPanel(id: String? = nil) -> String {
        let panelID = id ?? UUID().uuidString
        let suffix = "_\(panelID)"

        let selection = CharacterSelectionModel(
            library: library,
            defaultsKey: "selectedCharacter\(suffix)"
        )
        let sizeModel = SizeSelectionModel(
            defaultsKey: "characterSize\(suffix)"
        )

        let canClose = panels.count >= 1  // will have at least 2 after this one is added

        var view = CharacterView(selection: selection, sizeModel: sizeModel)
        view.canClose = canClose
        view.onNewWindow = { [weak self] in
            self?.createPanel()
        }
        view.onCloseWindow = { [weak self] in
            self?.closePanel(id: panelID)
        }

        let host = NSHostingView(rootView: view)
        host.frame = NSRect(origin: .zero, size: sizeModel.current.nsSize)
        host.autoresizingMask = [.width, .height]

        let origin = offsetOrigin(for: sizeModel.current.nsSize)
        let panel = CharacterPanel(
            initialSize: sizeModel.current.nsSize,
            persistenceKey: "characterOrigin\(suffix)"
        )
        // Only apply offset origin for brand-new panels (no saved origin)
        if id == nil {
            let savedOrigin = UserDefaults.standard.dictionary(forKey: "characterOrigin\(suffix)")
            if savedOrigin == nil {
                panel.setFrameOrigin(origin)
            }
        }
        panel.contentView = host
        panel.orderFrontRegardless()

        var cancellables = Set<AnyCancellable>()
        sizeModel.$current
            .removeDuplicates()
            .dropFirst()
            .sink { [weak panel] newSize in
                panel?.applySize(newSize.nsSize)
            }
            .store(in: &cancellables)

        let managed = ManagedPanel(
            id: panelID,
            panel: panel,
            selection: selection,
            sizeModel: sizeModel,
            cancellables: cancellables
        )
        panels[panelID] = managed

        savePanelIDs()
        refreshAllCanClose()
        return panelID
    }

    func closePanel(id: String) {
        guard panels.count > 1 else { return }
        guard let managed = panels.removeValue(forKey: id) else { return }

        managed.panel.orderOut(nil)

        // Clean up UserDefaults for this panel
        let suffix = "_\(id)"
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "selectedCharacter\(suffix)")
        defaults.removeObject(forKey: "characterSize\(suffix)")
        defaults.removeObject(forKey: "characterOrigin\(suffix)")

        savePanelIDs()
        refreshAllCanClose()
    }

    // MARK: - Private

    private func savePanelIDs() {
        let ids = Array(panels.keys)
        UserDefaults.standard.set(ids, forKey: Self.panelIDsKey)
    }

    private func offsetOrigin(for size: NSSize) -> NSPoint {
        // Place new windows offset from the last created panel
        if let lastManaged = panels.values.first, panels.count > 0 {
            let lastPanel = lastManaged.panel
            let lastOrigin = lastPanel.frame.origin
            let candidate = NSPoint(x: lastOrigin.x - 40, y: lastOrigin.y + 40)
            let frame = NSRect(origin: candidate, size: size)
            return CharacterPanel.clamp(frame: frame).origin
        }
        return CharacterPanel.defaultOrigin(forSize: size)
    }

    private func refreshAllCanClose() {
        let canClose = panels.count > 1
        for (panelID, managed) in panels {
            let selection = managed.selection
            let sizeModel = managed.sizeModel
            let capturedID = panelID

            var view = CharacterView(selection: selection, sizeModel: sizeModel)
            view.canClose = canClose
            view.onNewWindow = { [weak self] in
                self?.createPanel()
            }
            view.onCloseWindow = { [weak self] in
                self?.closePanel(id: capturedID)
            }

            let host = NSHostingView(rootView: view)
            host.frame = NSRect(origin: .zero, size: sizeModel.current.nsSize)
            host.autoresizingMask = [.width, .height]
            managed.panel.contentView = host
        }
    }
}
