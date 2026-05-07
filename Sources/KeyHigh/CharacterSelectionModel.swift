import Foundation
import Combine

/// Tracks which character the user has chosen and persists it across launches.
/// Initialised from a `VideoLoader` library; falling back to a default id
/// (mouse) and finally to the first available pair so the panel always has
/// something to render.
final class CharacterSelectionModel: ObservableObject {

    @Published private(set) var current: CharacterAssets?

    let library: [CharacterAssets]
    private let defaultsKey: String

    init(library: [CharacterAssets], defaultID: String = "mouse", defaultsKey: String = "selectedCharacter") {
        self.defaultsKey = defaultsKey
        self.library = library
        let savedID = UserDefaults.standard.string(forKey: defaultsKey)
        let chosen = library.first(where: { $0.id == savedID })
            ?? library.first(where: { $0.id == defaultID })
            ?? library.first
        self.current = chosen
    }

    func select(_ character: CharacterAssets) {
        guard library.contains(where: { $0.id == character.id }) else { return }
        current = character
        UserDefaults.standard.set(character.id, forKey: defaultsKey)
    }
}
