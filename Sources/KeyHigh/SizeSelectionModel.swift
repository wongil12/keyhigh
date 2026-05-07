import Foundation
import AppKit

enum CharacterSize: Int, CaseIterable, Identifiable {
    case small  = 200
    case medium = 400
    case large  = 600

    var id: Int { rawValue }
    var nsSize: NSSize { NSSize(width: rawValue, height: rawValue) }

    var displayName: String {
        switch self {
        case .small:  return "Small (200)"
        case .medium: return "Medium (400)"
        case .large:  return "Large (600)"
        }
    }
}

final class SizeSelectionModel: ObservableObject {

    @Published private(set) var current: CharacterSize

    private let defaultsKey: String

    init(defaultSize: CharacterSize = .small, defaultsKey: String = "characterSize") {
        self.defaultsKey = defaultsKey
        let saved = (UserDefaults.standard.object(forKey: defaultsKey) as? Int)
            .flatMap(CharacterSize.init(rawValue:))
        self.current = saved ?? defaultSize
    }

    func select(_ size: CharacterSize) {
        current = size
        UserDefaults.standard.set(size.rawValue, forKey: defaultsKey)
    }
}
