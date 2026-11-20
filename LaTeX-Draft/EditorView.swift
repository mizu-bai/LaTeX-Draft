//
// Created by mizu bai on 2022/1/27.
//

import SwiftUI
import iosMath

struct EditorView: View {

    @State private var latex: String = ""
    // @StateObject: the model's lifetime is owned by this view. (@ObservedObject
    // would recreate the model every time the view body re-evaluates.)
    @StateObject var mathUILabelModel = MathUILabelModel()
    @Environment(\.colorScheme) var colorScheme

    init() {
        UITextView.appearance().backgroundColor = .clear
        mathUILabelModel.textColor = UIColor { (trainCollection) -> UIColor in
            trainCollection.userInterfaceStyle == .light ? .black : .white
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // MARK: Render preview card
            RenderPreview(latex: $latex, labelModel: mathUILabelModel)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            // MARK: Control bar
            HStack {
                Text("Display style:")
                Spacer()
                Button(mathUILabelModel.labelMode == .display ? "Display" : "Inline") {
                    if mathUILabelModel.labelMode == .display {
                        mathUILabelModel.labelMode = .text
                    } else {
                        mathUILabelModel.labelMode = .display
                    }
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            // MARK: Input card
            InputTextView($latex)
                .padding()
                .frame(minHeight: 140, alignment: .topLeading)
        }
    }
}

// MARK: - Render Preview

/// The live preview area: rendered formula on a tinted card, or a friendly
/// hint when the input doesn't parse yet (iosMath's inline red error text
/// is disabled — its message surfaces in a small capsule instead).
struct RenderPreview: View {
    @Binding var latex: String
    @ObservedObject var labelModel: MathUILabelModel

    /// The parse error reported by the preview label, if any.
    @State private var parseError: String?

    var body: some View {
        ZStack {
            MathUILabel($latex, labelModel: labelModel, parseError: $parseError)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            if let message = parseError, !latex.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                VStack {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle")
                        Text(message)
                            .lineLimit(2)
                    }
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.thinMaterial, in: Capsule())
                    Spacer()
                }
                .padding(.top, 4)
            }
        }
    }
}

struct EditorView_Previews: PreviewProvider {
    static var previews: some View {
        EditorView()
    }
}
