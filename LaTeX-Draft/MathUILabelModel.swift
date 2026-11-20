//
// Created by mizu bai on 2021/12/13.
//

import SwiftUI
import Combine

class MathUILabelModel: ObservableObject {
    @Published var labelMode: MTMathUILabelMode   = .display
    @Published var textAlignment: MTTextAlignment = .center
    @Published var fontSize: CGFloat              = MTFontManager().defaultFont().fontSize
    @Published var font: MTFont                   = MTFontManager().defaultFont()
    /// Dynamic color: adapts to light/dark mode automatically.
    @Published var textColor: UIColor = UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .light ? .black : .white
    }
}
