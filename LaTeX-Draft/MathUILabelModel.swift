//
// Created by mizu bai on 2021/12/13.
//

import SwiftUI
import Combine

class MathUILabelModel: ObservableObject {
    @Published var labelMode: MTMathUILabelMode   = .display
    @Published var textAlignment: MTTextAlignment = .center
    /// One shared MTFont instance; loading it is not free and the default
    /// never changes during a session.
    private static let defaultFont = MTFontManager().defaultFont()

    @Published var fontSize: CGFloat              = defaultFont.fontSize
    @Published var font: MTFont                   = defaultFont
    /// Dynamic color: adapts to light/dark mode automatically.
    @Published var textColor: UIColor = UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .light ? .black : .white
    }
}
