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

// MARK: - Line Number Ruler

/// A thin ruler view that draws line numbers aligned with the text view's
/// visible lines. Attached as a subview; scrolls with the text via offset.
class LineNumberRulerView: UIView {

    weak var textView: UITextView?

    private let gutterWidth: CGFloat = 34

    override var intrinsicContentSize: CGSize {
        CGSize(width: gutterWidth, height: bounds.height)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        frame.origin.x = textView?.contentOffset.x ?? 0
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        guard let textView = textView,
              let attributedText = textView.attributedText,
              attributedText.length > 0 || !textView.text.isEmpty else {
            return
        }

        let layout = textView.layoutManager
        let font = textView.font ?? .systemFont(ofSize: 16)
        let text = textView.text as NSString

        // Draw a number for every visible line fragment.
        let visibleGlyphRange = layout.glyphRange(forBoundingRect: textView.bounds, in: textView.textContainer)
        var lineNumber = 1

        // Count lines before the visible range to get the first visible line number.
        let visibleStart = visibleGlyphRange.location
        if visibleStart > 0 {
            let before = text.substring(to: min(visibleStart, text.length))
            lineNumber = before.components(separatedBy: "\n").count
        }

        var charIndex = visibleStart
        let charEnd = visibleStart + visibleGlyphRange.length

        UIColor.secondaryLabel.setFill()

        while charIndex < charEnd {
            let lineRange = text.lineRange(for: NSRange(location: charIndex, length: 0))
            let glyphRange = layout.glyphRange(forCharacterRange: lineRange, actualCharacterRange: nil)
            guard glyphRange.length > 0 else { break }

            let fragmentRect = layout.lineFragmentRect(forGlyphAt: glyphRange.location, effectiveRange: nil)
            let y = fragmentRect.minY - textView.contentOffset.y

            let number = "\(lineNumber)" as NSString
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: UIColor.secondaryLabel,
            ]
            let size = number.size(withAttributes: attributes)
            number.draw(at: CGPoint(x: (bounds.width - size.width) - 6, y: y + (fragmentRect.height - size.height) / 2),
                        withAttributes: attributes)

            lineNumber += 1
            charIndex = NSMaxRange(lineRange)
        }
    }
}

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

        // Line-number gutter down the left edge.
        let ruler = LineNumberRulerView(frame: CGRect(x: 0, y: 0, width: 34, height: 0))
        ruler.textView = inputTextView
        inputTextView.addSubview(ruler)
        inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 38, bottom: 8, right: 8)
        context.coordinator.ruler = ruler
        context.coordinator.textView = inputTextView

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

        coordinator.ruler?.setNeedsDisplay()
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
        var ruler: LineNumberRulerView?
        weak var textView: UITextView?

        init(_ parent: InputTextView) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            ruler?.setNeedsDisplay()
        }

        /// Keep the gutter in sync while scrolling.
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            ruler?.setNeedsDisplay()
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
