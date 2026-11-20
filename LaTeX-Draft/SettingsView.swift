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
            // MARK: Live preview
            Group {
                Text("Preview")
                    .font(.headline)
                PreviewLabel(latex: "\\int_0^\\infty e^{-x^2}\\,dx = \\frac{\\sqrt{\\pi}}{2}",
                             theme: settings.theme)
                    .frame(height: 90)
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

/// A small MTMathUILabel wrapper that re-renders when the theme changes.
/// Only font size and colors come from the theme — MTMathUILabel's `font`
/// expects an MTFont, and the default manager font matches the editor's.
private struct PreviewLabel: UIViewRepresentable {
    let latex: String
    let theme: EditorThemeModel
    @Environment(\.colorScheme) private var colorScheme

    func makeUIView(context: Context) -> MTMathUILabel {
        let label = MTMathUILabel()
        label.displayErrorInline = false
        label.textAlignment = .center
        return label
    }

    func updateUIView(_ uiView: MTMathUILabel, context: Context) {
        uiView.latex = latex
        uiView.fontSize = theme.fontSize + 4
        uiView.textColor = theme.baseColor(isDark: colorScheme == .dark)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(SettingsModel())
    }
}
