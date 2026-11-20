//
//  MathImageRenderer.swift
//  LaTeX-Draft
//
//  Created by mizu bai on 2026/11/20.
//

import UIKit
import iosMath

enum MathImageRenderer {

    /// Render LaTeX into a crisp UIImage at the device's native scale,
    /// off-screen (the label never needs to be in a window).
    /// - Parameters:
    ///   - latex: the expression to typeset
    ///   - fontSize: display font size
    ///   - textColor: glyph color (pass the background-contrast color)
    ///   - labelMode: inline vs display layout
    ///   - padding: transparent margin around the glyphs, in points
    /// - Returns: nil when the input fails to parse.
    static func renderImage(latex: String,
                            fontSize: CGFloat,
                            textColor: UIColor,
                            labelMode: MTMathUILabelMode = .display,
                            padding: CGFloat = 8) -> UIImage? {
        // Parse first so failures return nil instead of drawing nothing.
        // (Uses the instance API: the class convenience's error out-parameter
        // imports awkwardly into Swift.)
        let builder = MTMathListBuilder(string: latex)
        guard let mathList = builder.build() else {
            return nil
        }

        let label = MTMathUILabel()
        label.displayErrorInline = false
        label.mathList = mathList
        label.fontSize = fontSize
        label.textColor = textColor
        label.labelMode = labelMode
        label.backgroundColor = .clear

        // Measure, then draw the layer at the device scale, offset by the
        // transparent padding. Drawing off-screen works because layer.render
        // does not require the view to be attached to a window.
        let fitSize = label.sizeThatFits(.zero)
        let scale = UIScreen.main.scale
        let padded = CGSize(width: fitSize.width + padding * 2,
                            height: fitSize.height + padding * 2)

        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        let renderer = UIGraphicsImageRenderer(size: padded, format: format)

        return renderer.image { context in
            context.cgContext.clear(CGRect(origin: .zero, size: padded))
            context.cgContext.translateBy(x: padding, y: padding)
            context.cgContext.scaleBy(x: scale, y: scale)
            label.layer.render(in: context.cgContext)
        }
    }

    /// Render and copy to the general pasteboard as an image.
    @discardableResult
    static func copyToPasteboard(latex: String,
                                 fontSize: CGFloat,
                                 textColor: UIColor,
                                 labelMode: MTMathUILabelMode = .display) -> Bool {
        guard let image = renderImage(latex: latex,
                                      fontSize: fontSize,
                                      textColor: textColor,
                                      labelMode: labelMode) else {
            return false
        }
        UIPasteboard.general.image = image
        return true
    }
}
