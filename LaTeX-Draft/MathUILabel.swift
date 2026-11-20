//
// Created by mizu bai on 2021/12/12.
//

import SwiftUI
import iosMath

struct MathUILabel: UIViewRepresentable {
    @Binding var latex: String
    private var labelMode: MTMathUILabelMode   = .display
    private var textAlignment: MTTextAlignment = .left
    private var fontSize: CGFloat              = MTFontManager().defaultFont().fontSize
    private var font: MTFont                   = MTFontManager().defaultFont()
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

    init(_ latex: Binding<String>,
         labelModel: MathUILabelModel = MathUILabel.defaultLabelModel
         ) {
        self._latex = latex
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
