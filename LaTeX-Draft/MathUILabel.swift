//
// Created by mizu bai on 2021/12/12.
//

import SwiftUI
import iosMath

struct MathUILabel: UIViewRepresentable {
    @Environment(\.colorScheme) var colorScheme

    @Binding var latex: String
    /// Optional binding that receives the parse error of the underlying
    /// MTMathUILabel after each update (nil when the input parses cleanly).
    var parseError: Binding<String?>?
    private var labelMode: MTMathUILabelMode   = .display
    private var textAlignment: MTTextAlignment = .left
    private var fontSize: CGFloat              = MathUILabel.cachedDefaultFont.fontSize
    private var font: MTFont                   = MathUILabel.cachedDefaultFont
    private var textColor: UIColor             = .black

    /// Shared default model. One instance keeps `textColor` (a dynamic-provider
    /// UIColor) identity-stable across cells, so updateUIView can skip it.
    static let defaultLabelModel = MathUILabelModel()

    private var _labelModel: MathUILabelModel = MathUILabelModel()
    var labelModel: MathUILabelModel {
        set {
            _labelModel   = newValue
            labelMode     = _labelModel.labelMode
            textAlignment = _labelModel.textAlignment
            fontSize      = _labelModel.fontSize
            font          = _labelModel.font
            textColor     = _labelModel.textColor
        }
        get {
            _labelModel
        }
    }

    /// Default font cached once: MTFontManager() does dictionary lookups and
    /// font loading per call, which is wasteful when the grid creates many cells.
    private static let cachedDefaultFont = MTFontManager().defaultFont()

    init(_ latex: Binding<String>,
         labelModel: MathUILabelModel = MathUILabel.defaultLabelModel,
         parseError: Binding<String?>? = nil
         ) {
        self._latex = latex
        self.parseError = parseError
        self.labelModel = labelModel
    }

    /// Convenience initializer for static, non-editable LaTeX rendering.
    init(latex: String, labelModel: MathUILabelModel = MathUILabel.defaultLabelModel) {
        self.init(.constant(latex), labelModel: labelModel)
    }

    func makeUIView(context: Context) -> MTMathUILabel {
        let label = MTMathUILabel()
        label.latex         = latex
        label.labelMode     = labelMode
        label.textAlignment = textAlignment
        label.fontSize      = fontSize
        label.font          = font
        label.textColor     = textColor
        // Parse errors are surfaced by our own overlay, not red inline text.
        label.displayErrorInline = false
        return label
    }

    /// Only touch the UIView when a value actually changed. Assigning `latex`
    /// re-parses and re-typesets the whole expression, so blindly writing it
    /// on every SwiftUI update made the reference grid stutter.
    /// Treat this like UICollectionViewCell reuse: cheap and idempotent.
    func updateUIView(_ uiView: MTMathUILabel, context: Context) {
        if uiView.latex != latex                       { uiView.latex = latex }
        if uiView.labelMode != labelMode               { uiView.labelMode = labelMode }
        if uiView.textAlignment != textAlignment       { uiView.textAlignment = textAlignment }
        if uiView.fontSize != fontSize                 { uiView.fontSize = fontSize }
        if uiView.font !== font                        { uiView.font = font }
        if uiView.textColor != textColor               { uiView.textColor = textColor }

        // Report parse errors to SwiftUI (if a binding was provided).
        if let parseError = parseError {
            let message = uiView.error?.localizedDescription
            if parseError.wrappedValue != message {
                parseError.wrappedValue = message
            }
        }
    }

    func then(_ body: (inout Self) -> Void) -> Self {
        var result = self
        body(&result)
        return result
    }

    func labelModel(_ labelModel: MathUILabelModel) -> Self {
        then {
            $0.labelModel = labelModel
        }
    }
}
