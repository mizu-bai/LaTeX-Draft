# LaTeX Draft

A little LaTeX equation scratchpad — type TeX, see it rendered live, and grab symbols from a built-in quick reference. Misses the classic iOS app *LaTeX Help* (which no longer runs on modern iOS), and now lives on both iOS and macOS via Mac Catalyst.

![Platforms](https://img.shields.io/badge/platform-macOS%20%7C%20iOS-blue) ![Swift](https://img.shields.io/badge/Swift-5-orange) ![License](https://img.shields.io/badge/license-BSD--2--Clause-green)

## Features

- **Live equation editor** — type LaTeX and see it typeset instantly (powered by [iosMath](https://github.com/kostub/iosMath)), with inline/display mode switching
- **Syntax highlighting** — the TeX source is highlighted with semantic coloring (comments, `\begin`/`\end`, commands, numbers, brackets); three themes: GitHub, Monokai, Solarized, each with light and dark variants
- **Quick reference** — 170+ symbols in 8 categories plus supported environments, all rendered live (every entry is verified against the parser — nothing in the list shows a red error), searchable, click to insert into the editor, right-click to copy
- **Editor niceties** — line-number gutter, `\begin{env}` autocompletion, friendly parse-error hints instead of red screens, copy/paste/clear toolbar actions
- **Settings** — font size (12–28pt), monospaced font choice (SF Mono, Menlo, Monaco, Courier New), highlight theme, all applied live and persisted
- **Mac Catalyst** — the same codebase runs natively on macOS (universal binary: Apple Silicon + Intel)

## Building

Requirements: Xcode 15+ (built with Xcode 26), [CocoaPods](https://cocoapods.org).

```bash
git clone https://github.com/mizu-bai/LaTeX-Draft-Archive.git
cd LaTeX-Draft-Archive
pod install
open LaTeX-Draft.xcworkspace   # then pick My Mac (Catalyst destination) and run
```

### Command line (Mac Catalyst)

```bash
xcodebuild -workspace LaTeX-Draft.xcworkspace -scheme LaTeX-Draft \
  -configuration Release \
  -destination 'platform=macOS,variant=Mac Catalyst' \
  ARCHS="arm64 x86_64" ONLY_ACTIVE_ARCH=NO \
  CODE_SIGNING_ALLOWED=NO ENABLE_DEBUG_DYLIB=NO build
```

The universal app lands in `build/DD/Build/Products/Release-maccatalyst/`.

## Project structure

```
LaTeX-Draft/
├── LaTeX_DraftApp.swift      # SwiftUI app entry
├── ContentView.swift         # TabView: Editor / Reference / Settings
├── EditorModel.swift         # shared editor state (cross-tab inserts)
├── EditorView.swift          # preview card + toolbar
├── MathUILabel.swift         # UIViewRepresentable bridge to iosMath
├── MathUILabelModel.swift    # render label configuration
├── InputTextView.swift       # highlighted editor + line numbers
├── EditorThemeModel.swift    # theme model (colors, rules, font)
├── SettingsModel.swift       # persisted user settings
├── SettingsView.swift        # settings UI with live previews
├── ReferenceView.swift       # searchable symbol grid
├── LaTeXReferenceData.swift  # 170+ verified symbol entries
├── theme_*.json              # highlight themes (GitHub/Monokai/Solarized)
└── Menlo-Regular.ttf
```

## Notes

- iosMath's engine implements core TeX math (matrices, `cases`, `aligned`, `gather`…), not the full amsmath package — `align` itself is not supported, use `aligned`.
- 16 commands unsupported by iosMath's font tables (e.g. `\surd`, `\diamond`, `\bigtriangleup`) render via Unicode fallbacks in the reference, while showing and copying the real command name.
- The app is ad-hoc signed; right-click → Open on first launch (or allow it in Privacy & Security).

## Acknowledgements

- [iosMath](https://github.com/kostub/iosMath) — LaTeX math typesetting for iOS
- The original *LaTeX Help* app by kenleewrites, for the inspiration

## License

BSD 2-Clause — see [LICENSE](LICENSE).
