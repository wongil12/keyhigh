import SwiftUI

struct CharacterView: View {

    @ObservedObject var selection: CharacterSelectionModel
    @ObservedObject var sizeModel: SizeSelectionModel

    private var currentURL: URL? {
        selection.current?.idleURL
    }

    private var sideLength: CGFloat {
        CGFloat(sizeModel.current.rawValue)
    }

    var body: some View {
        ZStack {
            if let currentURL {
                ChromaKeyVideoView(videoURL: currentURL, rate: 1.0)
            } else {
                placeholder
            }
        }
        .frame(width: sideLength, height: sideLength)
        .contentShape(Rectangle())
        .contextMenu { menu }
    }

    @ViewBuilder
    private var menu: some View {
        if !selection.library.isEmpty {
            Section("Character") {
                ForEach(selection.library) { character in
                    Button {
                        selection.select(character)
                    } label: {
                        if character.id == selection.current?.id {
                            Label(character.displayName, systemImage: "checkmark")
                        } else {
                            Text(character.displayName)
                        }
                    }
                }
            }
        }
        Section("Size") {
            ForEach(CharacterSize.allCases) { size in
                Button {
                    sizeModel.select(size)
                } label: {
                    if size == sizeModel.current {
                        Label(size.displayName, systemImage: "checkmark")
                    } else {
                        Text(size.displayName)
                    }
                }
            }
        }
        Divider()
        Button("Quit KeyHigh") {
            NSApp.terminate(nil)
        }
    }

    private var placeholder: some View {
        VStack(spacing: 4) {
            Text("KeyHigh")
                .font(.system(size: 14, weight: .semibold))
            Text("drop <name>_idle.mov\ninto Resources/")
                .font(.system(size: 10))
                .multilineTextAlignment(.center)
                .opacity(0.85)
        }
        .padding(10)
        .foregroundStyle(.white)
        .background(.black.opacity(0.55), in: RoundedRectangle(cornerRadius: 12))
    }
}
