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

// MARK: - Line Numbers

/// A SwiftUI canvas that paints line numbers directly — no per-line views,
/// so scrolling and typing stay O(visible lines) instead of O(total lines).
struct LineNumbersView: View {
    /// Total number of lines in the editor text.
    let lineCount: Int
    /// Vertical offset of the text view's content (scroll sync).
    let contentOffsetY: CGFloat
    /// Line height of the editor font — must match the UITextView font exactly.
    let lineHeight: CGFloat
    /// Top text inset of the text view, so numbers align with the first line.
    let topInset: CGFloat
    /// Height of the visible editor area.
    let viewportHeight: CGFloat

    var body: some View {
        Canvas { context, size in
            // First visible line (may be scrolled past the top).
            let firstVisible = max(0, Int(floor(-contentOffsetY / lineHeight)))
            // Last line still (partially) inside the viewport.
            let lastVisible = min(lineCount - 1,
                                  Int(floor((viewportHeight - topInset - contentOffsetY) / lineHeight)))

            let font = Font.system(size: 12, design: .monospaced)

            for line in firstVisible...max(firstVisible, lastVisible) {
                let y = topInset + CGFloat(line) * lineHeight + contentOffsetY
                // Numbers right-aligned in the gutter with a small margin.
                let text = Text("\(line + 1)").font(font).foregroundColor(.secondary.opacity(0.7))
                context.draw(text, at: CGPoint(x: size.width - 8, y: y + lineHeight / 2), anchor: .trailing)
            }
        }
    }
}

struct InputTextView: View {
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

    /// Font metrics for the line-number column (must match the text view font).
    private var lineHeight: CGFloat {
        editorTheme.font.lineHeight
    }

    /// Live scroll offset of the inner UITextView, published by the coordinator.
    @State private var contentOffsetY: CGFloat = 0
    @State private var viewportHeight: CGFloat = 0

    init(_ text: Binding<String>) {
        self._text = text
    }

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            LineNumbersView(
                lineCount: (text as NSString).numberOfLines,
                contentOffsetY: contentOffsetY,
                lineHeight: lineHeight,
                topInset: 8,
                viewportHeight: viewportHeight
            )
            .frame(width: 34)

            GeometryReader { geometry in
                EditorTextView(
                    text: $text,
                    editorTheme: editorTheme,
                    colorScheme: colorScheme,
                    onScroll: { contentOffsetY = $0 },
                    onLayout: { viewportHeight = $0 }
                )
                .onAppear { viewportHeight = geometry.size.height }
                .onChange(of: geometry.size.height) { viewportHeight = $0 }
            }
        }
    }
}

private extension NSString {
    /// Number of lines (a trailing newline does not start a new drawn line
    /// unless more text follows; for the gutter this simplification is fine).
    var numberOfLines: Int {
        components(separatedBy: "\n").count
    }
}

// MARK: - The UITextView wrapper

struct EditorTextView: UIViewRepresentable {
    let text: Binding<String>
    let editorTheme: EditorThemeModel
    let colorScheme: ColorScheme
    let onScroll: (CGFloat) -> Void
    let onLayout: (CGFloat) -> Void

    func makeUIView(context: Context) -> UITextView {
        let inputTextView = UITextView()
        inputTextView.delegate = context.coordinator
        inputTextView.font = editorTheme.font
        inputTextView.autocapitalizationType = .none
        inputTextView.autocorrectionType = .no
        inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 6, bottom: 8, right: 8)

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
        let needsUpdate = (coordinator.appliedText != text.wrappedValue)
            || (coordinator.appliedIsDark != isDark)
        guard needsUpdate else { return }

        let selectedRange = textView.selectedRange
        textView.attributedText = text.wrappedValue.setSyntaxHighlight(with: editorTheme, isDark: isDark)
        textView.selectedRange = selectedRange

        coordinator.appliedText = text.wrappedValue
        coordinator.appliedIsDark = isDark
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // MARK: - Coordinator
    class Coordinator: NSObject, UITextViewDelegate {

        var parent: EditorTextView
        /// Last state applied to the text view, to avoid redundant re-highlighting.
        var appliedText: String?
        var appliedIsDark: Bool?

        init(_ parent: EditorTextView) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            Self.autocompleteIfNeeded(in: textView)
            parent.text.wrappedValue = textView.text
        }

        /// When the user finishes typing `\begin{env}`, append a matching
        /// `\end{env}` and leave the cursor on the empty line in between.
        /// Only fires right after the closing brace of \begin — typing it
        /// again (or editing elsewhere) does nothing.
        private static func autocompleteIfNeeded(in textView: UITextView) {
            let source = textView.text as NSString
            let cursor = textView.selectedRange.location
            guard cursor > 0, cursor <= source.length,
                  source.substring(with: NSRange(location: cursor - 1, length: 1)) == "}" else {
                return
            }

            let head = source.substring(to: cursor)

            // The just-typed "}" must close a \begin{...} right at the cursor.
            guard head.hasSuffix("\\begin{") == false, // sanity: name not empty below
                  let openBrace = head.range(of: "\\begin{", options: .backwards),
                  openBrace.upperBound < head.endIndex else {
                return
            }
            // Name spans from after "\begin{" up to (excluding) the final "}".
            let nameStart = openBrace.upperBound
            let nameEnd = head.index(before: head.endIndex)
            guard nameStart < nameEnd else { return }
            let environment = String(head[nameStart..<nameEnd])
            guard !environment.isEmpty, !environment.contains(" "), !environment.contains("}") else { return }

            let insertion = "\n\t\n\\end{\(environment)}"
            textView.insertText(insertion)
            // Park the caret on the middle line: cursor + "\n\t".
            textView.selectedRange = NSRange(location: cursor + 2, length: 0)
        }

        /// Keep the line-number column in sync while scrolling.
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            parent.onScroll(scrollView.contentOffset.y)
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
