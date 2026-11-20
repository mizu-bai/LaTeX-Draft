//
//  InputTextView.swift
//  LaTeX-Draft
//
//  Created by mizu bai on 2022/1/28.
//

import SwiftUI
import UIKit
import Combine
import UIColor_Hex_Swift

extension UITextView {
    // MARK: - Add Tool Bar
    func toolBar(_ barItems: [UIBarButtonItem]) {
        let toolBar = UIToolbar(frame: CGRect(
                x: 0.0,
                y: 0.0,
                width: UIScreen.main.bounds.size.width,
                height: 44.0))
        toolBar.setItems(barItems, animated: false)
        inputAccessoryView = toolBar
    }

    @objc func doneButtonDidClick(button: UIBarButtonItem) {
        resignFirstResponder()
    }
}

extension String {
    func setSyntaxHighlight(with editorTheme: EditorThemeModel, isDark: Bool) -> NSMutableAttributedString {

        let attributedString = NSMutableAttributedString(string: self)

        attributedString.setAttributes(
                [
                    .font: editorTheme.font,
                    .foregroundColor: editorTheme.baseColor(isDark: isDark),
                ],
                range: NSRange(location: 0, length: count))

        do {
            for rule in editorTheme.highlightRules {
                let regularExpression = try NSRegularExpression(pattern: rule.pattern)
                let results = regularExpression.matches(in: self, range: NSRange(location: 0, length: count))
                for item in results {
                    attributedString.setAttributes(
                            [
                                .font: rule.font(for: editorTheme, isDark: isDark),
                                .foregroundColor: rule.color(isDark: isDark),
                            ],
                            range: item.range)
                }
            }
        } catch {
            print(error)
        }

        return attributedString
    }
}

struct InputTextView: UIViewRepresentable {
    typealias Context = UIViewRepresentableContext<InputTextView>

    @Binding var text: String

    @Environment(\.colorScheme) private var colorScheme

    /// Theme loaded once; failures fall back to sane defaults instead of crashing.
    private let editorTheme: EditorThemeModel = {
        guard
            let url = Bundle.main.url(forResource: "editor_theme_default", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let theme = try? JSONDecoder.decode(EditorThemeModel.self, from: data, keyStrategy: .convertFromSnakeCase)
        else {
            return EditorThemeModel(
                themeName: "fallback",
                fontName: "Menlo-Regular",
                fontSize: 16,
                fontColorHex: "#000000",
                highlightRules: [])
        }
        return theme
    }()

    init(_ text: Binding<String>) {
        self._text = text
    }

    // MARK: - Life Circle Methods
    func makeUIView(context: Context) -> UITextView {
        let inputTextView = UITextView()
        inputTextView.delegate = context.coordinator
        inputTextView.font = editorTheme.font
        inputTextView.autocapitalizationType = .none
        inputTextView.autocorrectionType = .no

        inputTextView.toolBar([
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(
                    image: UIImage(systemName: "keyboard.chevron.compact.down"),
                    style: .plain,
                    target: inputTextView,
                    action: #selector(UITextView.doneButtonDidClick(button:))),
        ])
        return inputTextView
    }

    func updateUIView(_ textView: UITextView, context: Context) {
        textView.backgroundColor = .clear
        let isDark = colorScheme == .dark

        // Re-highlight when the text changed since the last applied pass, or
        // when light/dark appearance flipped. Comparing against the coordinator's
        // last-applied state (not textView.text) is the key: after typing, the
        // text view and the binding are already equal, yet a re-highlight is due.
        let coordinator = context.coordinator
        let needsUpdate = (coordinator.appliedText != text)
            || (coordinator.appliedIsDark != isDark)
        guard needsUpdate else { return }

        let selectedRange = textView.selectedRange
        textView.attributedText = text.setSyntaxHighlight(with: editorTheme, isDark: isDark)
        textView.selectedRange = selectedRange

        coordinator.appliedText = text
        coordinator.appliedIsDark = isDark
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // MARK: - Coordinator
    class Coordinator: NSObject, UITextViewDelegate {

        var parent: InputTextView
        /// Last state applied to the text view, to avoid redundant re-highlighting.
        var appliedText: String?
        var appliedIsDark: Bool?

        init(_ parent: InputTextView) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
    }
}

// MARK: - Decoding helper

private extension JSONDecoder {
    /// Decode with a chosen key strategy in one call.
    static func decode<T: Decodable>(_ type: T.Type, from data: Data, keyStrategy: JSONDecoder.KeyDecodingStrategy) throws -> T {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = keyStrategy
        return try decoder.decode(type, from: data)
    }
}
