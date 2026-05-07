import Foundation

/// A single character's video asset.
struct CharacterAssets: Identifiable, Equatable {
    let id: String              // e.g. "dog", "mouse"
    let displayName: String     // e.g. "Dog", "Mouse"
    let idleURL: URL
}

/// Scans the bundle's Resources for `<name>_idle.*` videos and produces a
/// sorted library of selectable characters. Adding a new character is just a
/// matter of dropping another file into Sources/KeyHigh/Resources.
enum VideoLoader {

    private static let extensions: Set<String> = ["mov", "mp4", "m4v"]

    static func loadLibrary() -> [CharacterAssets] {
        // Collect all candidate directories:
        //  1. SPM resource bundle (Bundle.module → …/KeyHigh_KeyHigh.bundle/Resources/)
        //  2. App bundle Resources  (Bundle.main  → …/Contents/Resources/)
        var searchDirs: [URL] = []
        #if SWIFT_PACKAGE
        searchDirs.append(Bundle.module.resourceURL ?? Bundle.module.bundleURL)
        #endif
        if let mainRes = Bundle.main.resourceURL {
            searchDirs.append(mainRes)
        }

        var seen = Set<String>()
        var assets: [CharacterAssets] = []

        for dir in searchDirs {
            let files = (try? FileManager.default.contentsOfDirectory(
                at: dir,
                includingPropertiesForKeys: nil
            )) ?? []

            for url in files {
                guard extensions.contains(url.pathExtension.lowercased()) else { continue }
                let stem = url.deletingPathExtension().lastPathComponent
                guard stem.hasSuffix("_idle") else { continue }
                let key = String(stem.dropLast("_idle".count))
                guard !seen.contains(key) else { continue }
                seen.insert(key)
                assets.append(CharacterAssets(
                    id: key,
                    displayName: key.prefix(1).uppercased() + key.dropFirst(),
                    idleURL: url
                ))
            }
        }

        return assets.sorted { $0.id < $1.id }
    }
}
