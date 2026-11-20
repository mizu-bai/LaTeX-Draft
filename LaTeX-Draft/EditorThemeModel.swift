//
// Created by mizu bai on 2022/1/29.
//

import UIKit

struct EditorThemeModel: Codable {
    var themeName: String
    var fontName: String
    var fontSize: CGFloat
    var fontColorHex: String
    /// Optional base color for dark mode; falls back to plain white.
    var fontColorHexDark: String?
    var highlightRules: [HighlightModel]

    /// Resolved font; falls back to the system monospaced font if the bundled
    /// font is unavailable, so a bad theme name can never crash the editor.
    var font: UIFont {
        UIFont(name: fontName, size: fontSize) ?? .monospacedSystemFont(ofSize: fontSize, weight: .regular)
    }

    /// Base text color for the given appearance.
    func baseColor(isDark: Bool) -> UIColor {
        if isDark {
            return UIColor(fontColorHexDark ?? "#FFFFFF")
        }
        return UIColor(fontColorHex)
    }
}

struct HighlightModel: Codable {
    var description: String
    var pattern: String
    var fontColorHex: String
    /// Optional brighter variant used in dark mode; falls back to `fontColorHex`.
    var fontColorHexDark: String?
    /// Optional style toggles; default to off.
    var bold: Bool?
    var italic: Bool?

    /// Rule color for the given appearance.
    func color(isDark: Bool) -> UIColor {
        if isDark, let darkHex = fontColorHexDark {
            return UIColor(darkHex)
        }
        return UIColor(fontColorHex)
    }

    /// Font for this rule: the theme font with bold/italic traits applied.
    /// Cached by (isDark) — traits don't change mid-session, so just build it.
    func font(for theme: EditorThemeModel, isDark: Bool) -> UIFont {
        let base = theme.font
        var traits: UIFontDescriptor.SymbolicTraits = []
        if bold == true { traits.insert(.traitBold) }
        if italic == true { traits.insert(.traitItalic) }
        guard !traits.isEmpty,
              let descriptor = base.fontDescriptor.withSymbolicTraits(traits) else {
            return base
        }
        return UIFont(descriptor: descriptor, size: base.pointSize)
    }
}
