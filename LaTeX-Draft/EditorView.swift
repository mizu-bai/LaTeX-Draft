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

            // MARK: Toolbar: mode switcher + editing actions
            HStack(spacing: 12) {
                Picker("Mode", selection: $mathUILabelModel.labelMode) {
                    Text("Inline").tag(MTMathUILabelMode.text)
                    Text("Display").tag(MTMathUILabelMode.display)
                }
                .pickerStyle(.segmented)
                .frame(width: 160)
                .labelsHidden()

                Spacer()

                HStack(spacing: 2) {
                    IconButton(systemImage: "doc.on.doc",
                               help: "Copy LaTeX source") {
                        if !latex.isEmpty {
                            UIPasteboard.general.string = latex
                        }
                    }
                    .disabled(latex.isEmpty)
                    IconButton(systemImage: "clipboard",
                               help: "Paste LaTeX source") {
                        if let text = UIPasteboard.general.string {
                            latex = text
                        }
                    }
                    IconButton(systemImage: "trash",
                               help: "Clear editor") {
                        latex = ""
                    }
                    .disabled(latex.isEmpty)
                }
            }
            .padding(.horizontal)
            .padding(.top, 6)
            // Breathing room between the toolbar and the input card below.
            .padding(.bottom, 14)

            // MARK: Input card
            InputTextView($latex)
                .padding(8)
                .frame(minHeight: 140, alignment: .topLeading)
                // Outlined card so the editable region reads as a text field:
                // subtle fill + a visible border in both appearances.
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.primary.opacity(0.06))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color.primary.opacity(0.35), lineWidth: 1)
                )
                .padding(.horizontal)
                .padding(.bottom)
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

// MARK: - Icon Button

/// A small square icon button for the editor toolbar, with a hover tooltip.
struct IconButton: View {
    let systemImage: String
    let help: String
    let action: () -> Void

    @State private var isHovered = false
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(isHovered ? .primary : .secondary)
                .frame(width: 30, height: 26)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.primary.opacity(isHovered ? 0.08 : 0))
                )
        }
        .buttonStyle(.plain)
        .help(help)
        .onHover { isHovered = $0 }
    }
}

struct EditorView_Previews: PreviewProvider {
    static var previews: some View {
        EditorView()
    }
}
