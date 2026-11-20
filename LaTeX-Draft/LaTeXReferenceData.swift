//
// Created by mizu bai on 2026/11/20.
//

import UIKit

/// A renderable LaTeX symbol entry for the Quick Reference.
struct LaTeXSymbol: Identifiable, Hashable {
    let id = UUID()
    /// The LaTeX command, e.g. `\alpha` — shown in the cell and copied on tap.
    let latex: String
    /// What iosMath actually renders. Defaults to `latex`; symbols that iosMath
    /// cannot parse fall back to their Unicode glyph while still teaching the
    /// real command name.
    let renderAs: String
    /// Short human-readable note, e.g. "lowercase alpha".
    let note: String

    init(_ latex: String, note: String = "", renderAs: String? = nil) {
        self.latex = latex
        self.renderAs = renderAs ?? latex
        self.note = note
    }
}

/// A category of symbols, mirroring the classic LaTeX reference layout.
struct LaTeXSymbolSection: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let symbols: [LaTeXSymbol]
}

enum LaTeXReference {
    /// All Quick Reference sections, in display order.
    static let sections: [LaTeXSymbolSection] = [
        LaTeXSymbolSection(name: "Greek Letters", symbols: [
            LaTeXSymbol("\\alpha", note: "α"),
            LaTeXSymbol("\\beta", note: "β"),
            LaTeXSymbol("\\gamma", note: "γ"),
            LaTeXSymbol("\\delta", note: "δ"),
            LaTeXSymbol("\\epsilon", note: "ϵ"),
            LaTeXSymbol("\\varepsilon", note: "ε"),
            LaTeXSymbol("\\zeta", note: "ζ"),
            LaTeXSymbol("\\eta", note: "η"),
            LaTeXSymbol("\\theta", note: "θ"),
            LaTeXSymbol("\\vartheta", note: "ϑ"),
            LaTeXSymbol("\\iota", note: "ι"),
            LaTeXSymbol("\\kappa", note: "κ"),
            LaTeXSymbol("\\lambda", note: "λ"),
            LaTeXSymbol("\\mu", note: "μ"),
            LaTeXSymbol("\\nu", note: "ν"),
            LaTeXSymbol("\\xi", note: "ξ"),
            LaTeXSymbol("\\pi", note: "π"),
            LaTeXSymbol("\\varpi", note: "ϖ"),
            LaTeXSymbol("\\rho", note: "ρ"),
            LaTeXSymbol("\\varrho", note: "ϱ"),
            LaTeXSymbol("\\sigma", note: "σ"),
            LaTeXSymbol("\\varsigma", note: "ς"),
            LaTeXSymbol("\\tau", note: "τ"),
            LaTeXSymbol("\\upsilon", note: "υ"),
            LaTeXSymbol("\\phi", note: "ϕ"),
            LaTeXSymbol("\\varphi", note: "φ"),
            LaTeXSymbol("\\chi", note: "χ"),
            LaTeXSymbol("\\psi", note: "ψ"),
            LaTeXSymbol("\\omega", note: "ω"),
            LaTeXSymbol("\\Gamma", note: "Γ"),
            LaTeXSymbol("\\Delta", note: "Δ"),
            LaTeXSymbol("\\Theta", note: "Θ"),
            LaTeXSymbol("\\Lambda", note: "Λ"),
            LaTeXSymbol("\\Xi", note: "Ξ"),
            LaTeXSymbol("\\Pi", note: "Π"),
            LaTeXSymbol("\\Sigma", note: "Σ"),
            LaTeXSymbol("\\Upsilon", note: "Υ"),
            LaTeXSymbol("\\Phi", note: "Φ"),
            LaTeXSymbol("\\Psi", note: "Ψ"),
            LaTeXSymbol("\\Omega", note: "Ω"),
        ]),
        LaTeXSymbolSection(name: "Binary Operations", symbols: [
            LaTeXSymbol("\\pm", note: "plus-minus"),
            LaTeXSymbol("\\mp", note: "minus-plus"),
            LaTeXSymbol("\\times", note: "multiply"),
            LaTeXSymbol("\\div", note: "divide"),
            LaTeXSymbol("\\ast", note: "asterisk"),
            LaTeXSymbol("\\star", note: "star"),
            LaTeXSymbol("\\circ", note: "circle"),
            LaTeXSymbol("\\bullet", note: "bullet"),
            LaTeXSymbol("\\cdot", note: "cdot"),
            LaTeXSymbol("\\cap", note: "intersect"),
            LaTeXSymbol("\\cup", note: "union"),
            LaTeXSymbol("\\uplus", note: "multiset union"),
            LaTeXSymbol("\\sqcap", note: "square intersect"),
            LaTeXSymbol("\\sqcup", note: "square union"),
            LaTeXSymbol("\\vee", note: "logical or"),
            LaTeXSymbol("\\wedge", note: "logical and"),
            LaTeXSymbol("\\setminus", note: "set difference"),
            LaTeXSymbol("\\diamond", note: "diamond", renderAs: "⋄"),
            LaTeXSymbol("\\bigtriangleup", note: "big triangle up", renderAs: "△"),
            LaTeXSymbol("\\bigtriangledown", note: "big triangle down", renderAs: "▽"),
            LaTeXSymbol("\\triangleleft", note: "triangle left", renderAs: "◃"),
            LaTeXSymbol("\\triangleright", note: "triangle right", renderAs: "▹"),
            LaTeXSymbol("\\oplus", note: "direct sum"),
            LaTeXSymbol("\\ominus", note: "minus circle"),
            LaTeXSymbol("\\otimes", note: "tensor"),
            LaTeXSymbol("\\oslash", note: "slash circle"),
            LaTeXSymbol("\\odot", note: "dot circle"),
            LaTeXSymbol("\\bigcirc", note: "big circle", renderAs: "○"),
            LaTeXSymbol("\\dagger", note: "dagger"),
            LaTeXSymbol("\\ddagger", note: "double dagger"),
            LaTeXSymbol("\\amalg", note: "amalg"),
        ]),
        LaTeXSymbolSection(name: "Relations", symbols: [
            LaTeXSymbol("\\leq", note: "less or equal"),
            LaTeXSymbol("\\geq", note: "greater or equal"),
            LaTeXSymbol("\\equiv", note: "identical"),
            LaTeXSymbol("\\neq", note: "not equal"),
            LaTeXSymbol("\\sim", note: "similar"),
            LaTeXSymbol("\\simeq", note: "similar equal"),
            LaTeXSymbol("\\approx", note: "approximately"),
            LaTeXSymbol("\\cong", note: "congruent"),
            LaTeXSymbol("\\propto", note: "proportional"),
            LaTeXSymbol("\\ll", note: "much less"),
            LaTeXSymbol("\\gg", note: "much greater"),
            LaTeXSymbol("\\doteq", note: "dot equal"),
            LaTeXSymbol("\\perp", note: "perpendicular"),
            LaTeXSymbol("\\parallel", note: "parallel"),
            LaTeXSymbol("\\subset", note: "subset"),
            LaTeXSymbol("\\supset", note: "superset"),
            LaTeXSymbol("\\subseteq", note: "subset or equal"),
            LaTeXSymbol("\\supseteq", note: "superset or equal"),
            LaTeXSymbol("\\sqsubset", note: "sq. subset"),
            LaTeXSymbol("\\sqsupset", note: "sq. superset"),
            LaTeXSymbol("\\sqsubseteq", note: "sq. subset eq"),
            LaTeXSymbol("\\sqsupseteq", note: "sq. superset eq"),
            LaTeXSymbol("\\in", note: "element of"),
            LaTeXSymbol("\\ni", note: "contains as member"),
            LaTeXSymbol("\\notin", note: "not element of"),
            LaTeXSymbol("\\vdash", note: "turnstile", renderAs: "⊢"),
            LaTeXSymbol("\\dashv", note: "dash vertical", renderAs: "⊣"),
            LaTeXSymbol("\\smile", note: "smile", renderAs: "⌣"),
            LaTeXSymbol("\\frown", note: "frown", renderAs: "⌢"),
            LaTeXSymbol("\\asymp", note: "asymptotically equal"),
        ]),
        LaTeXSymbolSection(name: "Arrows", symbols: [
            LaTeXSymbol("\\leftarrow", note: "left arrow"),
            LaTeXSymbol("\\Leftarrow", note: "double left"),
            LaTeXSymbol("\\rightarrow", note: "right arrow"),
            LaTeXSymbol("\\Rightarrow", note: "implies"),
            LaTeXSymbol("\\leftrightarrow", note: "left-right"),
            LaTeXSymbol("\\Leftrightarrow", note: "if and only if"),
            LaTeXSymbol("\\uparrow", note: "up arrow"),
            LaTeXSymbol("\\Uparrow", note: "double up"),
            LaTeXSymbol("\\downarrow", note: "down arrow"),
            LaTeXSymbol("\\Downarrow", note: "double down"),
            LaTeXSymbol("\\updownarrow", note: "up-down"),
            LaTeXSymbol("\\Updownarrow", note: "double up-down"),
            LaTeXSymbol("\\mapsto", note: "maps to"),
            LaTeXSymbol("\\longmapsto", note: "long maps to", renderAs: "⟼"),
            LaTeXSymbol("\\nearrow", note: "NE arrow"),
            LaTeXSymbol("\\searrow", note: "SE arrow"),
            LaTeXSymbol("\\swarrow", note: "SW arrow"),
            LaTeXSymbol("\\nwarrow", note: "NW arrow"),
            LaTeXSymbol("\\rightleftharpoons", note: "harpoons", renderAs: "⇌"),
        ]),
        LaTeXSymbolSection(name: "Delimiters", symbols: [
            LaTeXSymbol("\\{", note: "brace"),
            LaTeXSymbol("\\}", note: "brace"),
            LaTeXSymbol("\\langle", note: "angle bracket"),
            LaTeXSymbol("\\rangle", note: "angle bracket"),
            LaTeXSymbol("\\lceil", note: "ceiling"),
            LaTeXSymbol("\\rceil", note: "ceiling"),
            LaTeXSymbol("\\lfloor", note: "floor"),
            LaTeXSymbol("\\rfloor", note: "floor"),
            LaTeXSymbol("\\vert", note: "vertical bar"),
            LaTeXSymbol("\\Vert", note: "double bar"),
            LaTeXSymbol("\\backslash", note: "backslash"),
        ]),
        LaTeXSymbolSection(name: "Miscellaneous", symbols: [
            LaTeXSymbol("\\ldots", note: "lower dots"),
            LaTeXSymbol("\\cdots", note: "centered dots"),
            LaTeXSymbol("\\vdots", note: "vertical dots"),
            LaTeXSymbol("\\ddots", note: "diagonal dots"),
            LaTeXSymbol("\\aleph", note: "aleph"),
            LaTeXSymbol("\\hbar", note: "h-bar"),
            LaTeXSymbol("\\imath", note: "dotless i"),
            LaTeXSymbol("\\jmath", note: "dotless j"),
            LaTeXSymbol("\\ell", note: "script l"),
            LaTeXSymbol("\\wp", note: "Weierstrass p"),
            LaTeXSymbol("\\Re", note: "real part"),
            LaTeXSymbol("\\Im", note: "imaginary part"),
            LaTeXSymbol("\\prime", note: "prime"),
            LaTeXSymbol("\\emptyset", note: "empty set"),
            LaTeXSymbol("\\nabla", note: "nabla"),
            LaTeXSymbol("\\surd", note: "radical", renderAs: "√"),
            LaTeXSymbol("\\top", note: "top"),
            LaTeXSymbol("\\bot", note: "bottom"),
            LaTeXSymbol("\\forall", note: "for all"),
            LaTeXSymbol("\\exists", note: "exists"),
            LaTeXSymbol("\\neg", note: "negation"),
            LaTeXSymbol("\\flat", note: "flat", renderAs: "♭"),
            LaTeXSymbol("\\natural", note: "natural", renderAs: "♮"),
            LaTeXSymbol("\\sharp", note: "sharp", renderAs: "♯"),
            LaTeXSymbol("\\partial", note: "partial"),
        ]),
        LaTeXSymbolSection(name: "Accents", symbols: [
            LaTeXSymbol("\\hat{a}", note: "hat"),
            LaTeXSymbol("\\bar{a}", note: "bar"),
            LaTeXSymbol("\\vec{a}", note: "vector"),
            LaTeXSymbol("\\tilde{a}", note: "tilde"),
            LaTeXSymbol("\\dot{a}", note: "dot"),
            LaTeXSymbol("\\ddot{a}", note: "double dot"),
            LaTeXSymbol("\\breve{a}", note: "breve"),
            LaTeXSymbol("\\check{a}", note: "check"),
        ]),
        LaTeXSymbolSection(name: "Fonts", symbols: [
            LaTeXSymbol("\\mathbb{R}", note: "blackboard bold"),
            LaTeXSymbol("\\mathbb{N}", note: "naturals"),
            LaTeXSymbol("\\mathbb{Z}", note: "integers"),
            LaTeXSymbol("\\mathbb{Q}", note: "rationals"),
            LaTeXSymbol("\\mathbb{C}", note: "complex"),
            LaTeXSymbol("\\mathcal{F}", note: "calligraphic"),
            LaTeXSymbol("\\mathbf{x}", note: "bold"),
            LaTeXSymbol("\\mathit{x}", note: "italic"),
            LaTeXSymbol("\\mathrm{x}", note: "roman"),
            LaTeXSymbol("\\mathfrak{g}", note: "fraktur"),
        ]),
    ]
}
