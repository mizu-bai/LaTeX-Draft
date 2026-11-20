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

    /// Shared control-column width: every row's control aligns to the same
    /// right edge, and pickers never change width with their content.
    private let controlWidth: CGFloat = 220

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
            // MARK: Live previews
            Group {
                Text("Preview")
                    .font(.headline)

                // Rendered formula: follows the font size only.
                PreviewLabel(latex: "\\left[-\\frac{1}{2}\\nabla^2 - \\frac{1}{r}\\right]\\psi(\\mathbf{r}) = E\\psi(\\mathbf{r})",
                             fontSize: settings.fontSize)
                    .frame(height: 150)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.primary.opacity(0.05))
                    )

                // Highlighted LaTeX source: follows the highlight theme.
                HighlightPreview(text: "% comment \\begin{cases} x = 42 \\end{cases}\n\\alpha + \\beta_{\\gamma} = \\sqrt[3]{2}",
                                 theme: settings.theme,
                                 isDark: colorScheme == .dark)
                    .frame(height: 110)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.primary.opacity(0.05))
                    )
            }
            .padding(.horizontal)

            // MARK: Font size stepper
            SettingsRow(label: "Font Size", controlWidth: controlWidth) {
                HStack(spacing: 10) {
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
            }

            // MARK: Font picker
            SettingsRow(label: "Font Name", controlWidth: controlWidth) {
                Picker("Font", selection: $settings.fontName) {
                    ForEach(EditorFontChoice.allCases.sorted(by: { $0.displayName < $1.displayName })) { choice in
                        Text(choice.displayName).tag(choice.rawValue)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: controlWidth)
            }

            // MARK: Theme picker
            SettingsRow(label: "Highlight Theme", controlWidth: controlWidth) {
                Picker("Theme", selection: $settings.themeName) {
                    ForEach(EditorThemeName.allCases.sorted(by: { $0.rawValue < $1.rawValue })) { theme in
                        Text(theme.rawValue).tag(theme)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: controlWidth)
            }
            }
        }
        .padding(.vertical)
        // Any settings change re-loads the theme (colors, rules, font).
        .onChange(of: settings.fontSize) { _ in settings.reloadTheme() }
        .onChange(of: settings.fontName) { _ in settings.reloadTheme() }
        .onChange(of: settings.themeName) { _ in settings.reloadTheme() }
    }
}

// MARK: - Settings Row

/// One settings row: label on the left, control pinned to a shared right
/// edge (fixed width), so all rows line up like a native form.
private struct SettingsRow<Control: View>: View {
    let label: String
    let controlWidth: CGFloat
    @ViewBuilder let control: Control

    var body: some View {
        HStack(alignment: .center) {
            Text(label)
            Spacer()
            control
                .frame(width: controlWidth, alignment: .trailing)
        }
        .padding(.horizontal)
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
