//
//  EditorModel.swift
//  LaTeX-Draft
//
//  Created by mizu bai on 2026/11/20.
//

import SwiftUI
import iosMath

/// Shared app state: owns the editor text and serves cross-tab actions
/// (Reference inserts symbols into the Editor).
///
/// Owned by ContentView and injected via .environmentObject, so both tabs
/// observe the same instance — the SwiftUI way to share state between
/// sibling views that have no parent-child relationship.
@MainActor
final class EditorModel: ObservableObject {

    /// The LaTeX source being edited.
    @Published var latex: String = ""

    /// Render preview mode (inline vs display), kept across tab switches.
    @Published var labelMode: MTMathUILabelMode = .display

    /// Render-preview configuration (mode, font size, adaptive color).
    /// One stable instance for the whole app session.
    ///
    /// `var` (not `let`) so `$editorModel.previewModel.labelMode` can project
    /// a writable Binding path into the class instance.
    var previewModel: MathUILabelModel = {
        let model = MathUILabelModel()
        model.fontSize = 24 // larger on Mac; the old 20pt default reads small
        model.textColor = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .light ? .black : .white
        }
        return model
    }()

    /// Insert a LaTeX fragment at the current cursor position (or replace
    /// the selection). Falls back to appending when the editor was never focused.
    func insert(_ fragment: String) {
        latex += fragment
    }
}
