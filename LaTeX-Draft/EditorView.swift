//
// Created by mizu bai on 2022/1/27.
//

import SwiftUI
import iosMath

struct EditorView: View {

    // Shared state injected by ContentView — survives tab switches and
    // receives symbol insertions from the Reference tab.
    @EnvironmentObject var editorModel: EditorModel
    @EnvironmentObject var settings: SettingsModel

    @Environment(\.colorScheme) var colorScheme
    /// Brief feedback after copying the rendered formula as an image.
    @State private var copiedImage = false

    init() {
        UITextView.appearance().backgroundColor = .clear
    }

    var body: some View {
        VStack(spacing: 0) {
            // MARK: Render preview card
            RenderPreview(latex: $editorModel.latex, labelMode: $editorModel.labelMode)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            // MARK: Toolbar: mode switcher + editing actions
            HStack(spacing: 12) {
                Picker("Mode", selection: $editorModel.labelMode) {
                    Text("Inline").tag(MTMathUILabelMode.text)
                    Text("Display").tag(MTMathUILabelMode.display)
                }
                .pickerStyle(.segmented)
                .font(.body.weight(.medium))
                .controlSize(.large)
                .frame(width: 200)
                .labelsHidden()

                Spacer()

                HStack(spacing: 2) {
                    IconButton(systemImage: "photo.on.rectangle",
                               help: "Copy rendered formula as image") {
                        let isDark = colorScheme == .dark
                        let ok = MathImageRenderer.copyToPasteboard(
                            latex: editorModel.latex,
                            fontSize: settings.theme.fontSize + 7,
                            textColor: isDark ? UIColor.white : UIColor.black,
                            labelMode: editorModel.labelMode)
                        if ok {
                            copiedImage = true
                        }
                    }
                    .disabled(editorModel.latex.isEmpty)
                    IconButton(systemImage: "doc.on.doc",
                               help: "Copy LaTeX source") {
                        if !editorModel.latex.isEmpty {
                            UIPasteboard.general.string = editorModel.latex
                        }
                    }
                    .disabled(editorModel.latex.isEmpty)
                    IconButton(systemImage: "clipboard",
                               help: "Paste LaTeX source") {
                        if let text = UIPasteboard.general.string {
                            editorModel.latex = text
                        }
                    }
                    IconButton(systemImage: "trash",
                               help: "Clear editor") {
                        editorModel.latex = ""
                    }
                    .disabled(editorModel.latex.isEmpty)
                }
            }
            .padding(.horizontal)
            .padding(.top, 6)
            // Breathing room between the toolbar and the input card below.
            .padding(.bottom, 14)

            // MARK: Input card
            InputTextView($editorModel.latex)
                .padding(8)
                .frame(minHeight: 160, alignment: .topLeading)
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
        .overlay(alignment: .bottom) {
            if copiedImage {
                Text("Formula copied as image")
                    .font(.footnote.weight(.medium))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(.thinMaterial, in: Capsule())
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .task {
                        try? await Task.sleep(for: .seconds(1.4))
                        withAnimation { copiedImage = false }
                    }
            }
        }
        .animation(.easeOut(duration: 0.2), value: copiedImage)
    }
}

// MARK: - Render Preview

/// The live preview area: rendered formula, or a friendly hint when the input
/// doesn't parse yet (iosMath's inline red error text is disabled — its
/// message surfaces in a capsule; .zIndex keeps it above the UIKit view,
/// which otherwise covers SwiftUI siblings by default).
struct RenderPreview: View {
    @Binding var latex: String
    @Binding var labelMode: MTMathUILabelMode
    @EnvironmentObject var settings: SettingsModel
    @Environment(\.colorScheme) var colorScheme

    /// The parse error reported by the preview label, if any.
    @State private var parseError: String?

    /// Preview label model derived from the current settings: editor font
    /// size + 7 for display prominence, colors from the theme.
    private func makeLabelModel() -> MathUILabelModel {
        let model = MathUILabelModel()
        model.labelMode = labelMode
        model.fontSize = settings.theme.fontSize + 7
        model.textColor = settings.theme.baseColor(isDark: colorScheme == .dark)
        return model
    }

    var body: some View {
        ZStack {
            MathUILabel($latex,
                        labelModel: makeLabelModel(),
                        parseError: $parseError)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            if let message = parseError, !latex.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                VStack {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle")
                        Text(message)
                            .lineLimit(2)
                    }
                    .font(.callout.weight(.medium))
                    .foregroundColor(.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.thinMaterial, in: Capsule())
                    .shadow(color: .black.opacity(0.15), radius: 4, y: 1)
                    Spacer()
                }
                .padding(.top, 4)
                .zIndex(1) // above the UIViewRepresentable
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

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isHovered ? .primary : .secondary)
                .frame(width: 36, height: 32)
                .background(
                    RoundedRectangle(cornerRadius: 7)
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
            .environmentObject(EditorModel())
    }
}
