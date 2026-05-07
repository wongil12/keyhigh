import Foundation

/// A single character's video asset.
struct CharacterAssets: Identifiable, Equatable {
    let id: String              // e.g. "cat", "mouse"
    let displayName: String     // e.g. "Cat", "Mouse"
    let idleURL: URL
}

/// Scans the bundle's Resources for `<name>_idle.*` videos and produces a
/// sorted library of selectable characters. Adding a new character is just a
/// matter of dropping another file into Resources.
enum VideoLoader {

    private static let extensions: Set<String> = ["mov", "mp4", "m4v"]

    static func loadLibrary() -> [CharacterAssets] {
        guard let resourceURL = Bundle.main.resourceURL else { return [] }
        let files = (try? FileManager.default.contentsOfDirectory(
            at: resourceURL,
            includingPropertiesForKeys: nil
        )) ?? []

        var assets: [CharacterAssets] = []
        for url in files {
            guard extensions.contains(url.pathExtension.lowercased()) else { continue }
            let stem = url.deletingPathExtension().lastPathComponent
            guard stem.hasSuffix("_idle") else { continue }
            let key = String(stem.dropLast("_idle".count))
            assets.append(CharacterAssets(
                id: key,
                displayName: key.prefix(1).uppercased() + key.dropFirst(),
                idleURL: url
            ))
        }

        return assets.sorted { $0.id < $1.id }
    }
}
