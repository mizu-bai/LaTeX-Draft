//
//  SettingsView.swift
//  LaTeX-Draft
//
//  Created by mizu bai on 2026/11/20.
//

import SwiftUI
import iosMath

/// Settings tab: live-rendered sample formula plus font size / font /
/// highlight-theme pickers. Every control applies immediately.
struct SettingsView: View {
    @EnvironmentObject var settings: SettingsModel
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // MARK: Live previews
            Group {
                Text("Preview")
                    .font(.headline)

                // Rendered formula: follows the font size only.
                PreviewLabel(latex: "\\int_0^\\infty e^{-x^2}\\,dx = \\frac{\\sqrt{\\pi}}{2}",
                             fontSize: settings.fontSize)
                    .frame(height: 80)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.primary.opacity(0.05))
                    )

                // Highlighted LaTeX source: follows the highlight theme.
                HighlightPreview(text: "% comment \\begin{cases} x = 42 \\end{cases}\n\\alpha + \\beta_{\\gamma} = \\sqrt[3]{2}",
                                 theme: settings.theme,
                                 isDark: colorScheme == .dark)
                    .frame(height: 72)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.primary.opacity(0.05))
                    )
            }
            .padding(.horizontal)

            // MARK: Font size stepper
            HStack {
                Text("Font size")
                Spacer()
                Button {
                    settings.decrementFontSize()
                } label: {
                    Image(systemName: "minus")
                }
                .buttonStyle(.bordered)
                .disabled(settings.fontSize <= SettingsModel.fontSizeRange.lowerBound)

                Text("\(Int(settings.fontSize))")
                    .monospacedDigit()
                    .frame(minWidth: 36)

                Button {
                    settings.incrementFontSize()
                } label: {
                    Image(systemName: "plus")
                }
                .buttonStyle(.bordered)
                .disabled(settings.fontSize >= SettingsModel.fontSizeRange.upperBound)
            }
            .padding(.horizontal)

            // MARK: Font picker
            HStack {
                Text("Font")
                Spacer()
                Picker("Font", selection: $settings.fontName) {
                    ForEach(EditorFontChoice.allCases) { choice in
                        Text(choice.displayName).tag(choice.rawValue)
                    }
                }
                .frame(width: 200)
            }
            .padding(.horizontal)

            // MARK: Theme picker
            HStack {
                Text("Highlight theme")
                Spacer()
                Picker("Theme", selection: $settings.themeName) {
                    ForEach(EditorThemeName.allCases) { theme in
                        Text(theme.rawValue).tag(theme)
                    }
                }
                .frame(width: 200)
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding(.vertical)
        // Any settings change re-loads the theme (colors, rules, font).
        .onChange(of: settings.fontSize) { _ in settings.reloadTheme() }
        .onChange(of: settings.fontName) { _ in settings.reloadTheme() }
        .onChange(of: settings.themeName) { _ in settings.reloadTheme() }
    }
}

// MARK: - Preview label

/// A small MTMathUILabel wrapper that re-renders when the font size changes.
/// Follows the font size only — the highlight theme colors the LaTeX source,
/// not the rendered formula.
private struct PreviewLabel: UIViewRepresentable {
    let latex: String
    let fontSize: CGFloat
    @Environment(\.colorScheme) private var colorScheme

    func makeUIView(context: Context) -> MTMathUILabel {
        let label = MTMathUILabel()
        label.displayErrorInline = false
        label.textAlignment = .center
        return label
    }

    func updateUIView(_ uiView: MTMathUILabel, context: Context) {
        uiView.latex = latex
        uiView.fontSize = fontSize + 4
        uiView.textColor = colorScheme == .dark ? .white : .black
    }
}

// MARK: - Highlight preview

/// A non-editable text view showing a sample of LaTeX source highlighted
/// with the current theme — so the theme picker previews what you actually
/// get in the editor.
private struct HighlightPreview: UIViewRepresentable {
    let text: String
    let theme: EditorThemeModel
    let isDark: Bool

    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        view.isEditable = false
        view.backgroundColor = .clear
        view.textContainerInset = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
        return view
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.attributedText = text.setSyntaxHighlight(with: theme, isDark: isDark)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(SettingsModel())
    }
}
