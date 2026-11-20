//
//  SettingsModel.swift
//  LaTeX-Draft
//
//  Created by mizu bai on 2026/11/20.
//

import SwiftUI
import UIKit

/// Available editor highlight themes bundled with the app.
enum EditorThemeName: String, CaseIterable, Identifiable {
    case github = "GitHub"
    case monokai = "Monokai"
    case solarized = "Solarized"

    var id: String { rawValue }

    /// Bundled JSON resource for the theme.
    var resource: String {
        switch self {
        case .github: return "theme_github"
        case .monokai: return "theme_monokai"
        case .solarized: return "theme_solarized"
        }
    }
}

/// Monospaced fonts commonly available on macOS/iOS, offered in Settings.
/// (Enumerating every system font is possible but noisy; a curated list of
/// coding fonts is friendlier.)
enum EditorFontChoice: String, CaseIterable, Identifiable {
    case menlo = "Menlo-Regular"
    case monaco = "Monaco"
    case courierNew = "CourierNewPSMT"
    case sfMono = "SFMono-Regular"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .menlo: return "Menlo"
        case .monaco: return "Monaco"
        case .courierNew: return "Courier New"
        case .sfMono: return "SF Mono"
        }
    }
}

/// User settings (font size, font, highlight theme), persisted to
/// UserDefaults and observed by the editor + settings views.
@MainActor
final class SettingsModel: ObservableObject {

    private enum Keys {
        static let fontSize = "editorFontSize"
        static let fontName = "editorFontName"
        static let themeName = "editorThemeName"
    }

    static let fontSizeRange: ClosedRange<CGFloat> = 12...28

    /// Editor font size. Persisted on change; the editor font is derived.
    @Published var fontSize: CGFloat {
        didSet { UserDefaults.standard.set(Double(fontSize), forKey: Keys.fontSize) }
    }

    /// Editor font name (a bundled/available monospaced font).
    @Published var fontName: String {
        didSet { UserDefaults.standard.set(fontName, forKey: Keys.fontName) }
    }

    /// Highlight theme. Persisted on change; `theme` reloads lazily.
    @Published var themeName: EditorThemeName {
        didSet { UserDefaults.standard.set(themeName.rawValue, forKey: Keys.themeName) }
    }

    /// The currently loaded editor theme (colors + rules + font).
    @Published private(set) var theme: EditorThemeModel

    init() {
        let defaults = UserDefaults.standard
        let size = CGFloat(defaults.double(forKey: Keys.fontSize))
        let initialSize = size == 0 ? 17 : min(max(size, SettingsModel.fontSizeRange.lowerBound),
                                               SettingsModel.fontSizeRange.upperBound)

        let savedFont = defaults.string(forKey: Keys.fontName) ?? EditorFontChoice.menlo.rawValue
        let initialFont = EditorFontChoice(rawValue: savedFont)?.rawValue ?? EditorFontChoice.menlo.rawValue

        let savedTheme = defaults.string(forKey: Keys.themeName) ?? EditorThemeName.github.rawValue
        let initialTheme = EditorThemeName(rawValue: savedTheme) ?? .github

        self.fontSize = initialSize
        self.fontName = initialFont
        self.themeName = initialTheme
        self.theme = Self.loadTheme(named: initialTheme, fontName: initialFont, fontSize: initialSize)
    }

    /// Font size step used by the +/- controls.
    func incrementFontSize() {
        fontSize = min(fontSize + 1, Self.fontSizeRange.upperBound)
    }

    func decrementFontSize() {
        fontSize = max(fontSize - 1, Self.fontSizeRange.lowerBound)
    }

    /// Rebuild the theme after any setting change.
    func reloadTheme() {
        theme = Self.loadTheme(named: themeName, fontName: fontName, fontSize: fontSize)
    }

    /// Load a bundled theme JSON; falls back to safe defaults on failure so a
    /// broken resource can never crash the editor.
    private static func loadTheme(named name: EditorThemeName, fontName: String, fontSize: CGFloat) -> EditorThemeModel {
        guard
            let url = Bundle.main.url(forResource: name.resource, withExtension: "json"),
            let data = try? Data(contentsOf: url),
            var loaded = try? JSONDecoder.decode(EditorThemeModel.self, from: data, keyStrategy: .convertFromSnakeCase)
        else {
            return EditorThemeModel(
                themeName: "fallback",
                fontName: fontName,
                fontSize: fontSize,
                fontColorHex: "#000000",
                fontColorHexDark: "#FFFFFF",
                highlightRules: [])
        }
        // Settings win over the JSON defaults.
        loaded.fontName = fontName
        loaded.fontSize = fontSize
        return loaded
    }
}

private extension JSONDecoder {
    /// Decode with a chosen key strategy in one call.
    static func decode<T: Decodable>(_ type: T.Type, from data: Data, keyStrategy: JSONDecoder.KeyDecodingStrategy) throws -> T {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = keyStrategy
        return try decoder.decode(type, from: data)
    }
}
