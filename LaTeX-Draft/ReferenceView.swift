//
//  ReferenceView.swift
//  LaTeX-Draft
//
//  Created by mizu bai on 2022/1/28.
//  Rewritten 2026/11/20: real Quick Reference with live-rendered symbols.
//

import SwiftUI
import iosMath

// MARK: - Symbol Cell

/// One grid cell: the symbol rendered live by iosMath, plus its LaTeX command.
/// Tapping the cell inserts the command into the editor (via the shared
/// EditorModel); the cell shows a hint so the behavior is discoverable.
struct SymbolCellView: View {
    let symbol: LaTeXSymbol
    /// Called when the cell is tapped; parent shows the "Inserted" feedback.
    let onInsert: (String) -> Void

    @State private var isHovered = false

    var body: some View {
        VStack(spacing: 6) {
            MathUILabel(latex: symbol.renderAs)
                .frame(minHeight: 36)
                .frame(maxWidth: .infinity)
            Text(symbol.latex)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.primary.opacity(isHovered ? 0.09 : 0.04))
        )
        .overlay(alignment: .topTrailing) {
            // Subtle affordance: a little plus badge on hover.
            if isHovered {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.accentColor)
                    .padding(4)
                    .transition(.opacity)
            }
        }
        .contentShape(Rectangle()) // make the whole cell tappable, not just the text
        .onTapGesture {
            onInsert(symbol.latex)
        }
        .onHover { isHovered = $0 }
        .help("Insert \(symbol.latex) into the editor")
        .animation(.easeOut(duration: 0.15), value: isHovered)
        // Mac-native escape hatch: right-click (Ctrl-click) to copy instead of
        // inserting — for taking the command to another app.
        .contextMenu {
            Button("Copy \(symbol.latex)") {
                UIPasteboard.general.string = symbol.latex
            }
            Button("Insert into editor") {
                onInsert(symbol.latex)
            }
        }
    }
}

// MARK: - Section View

struct SymbolSectionView: View {
    let section: LaTeXSymbolSection
    let onInsert: (String) -> Void

    /// Two-column adaptive grid: 200pt is the ideal cell width on iPhone,
    /// more columns appear automatically on wider windows (iPad / Mac).
    private let columns = [GridItem(.adaptive(minimum: 200), spacing: 8)]

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
            ForEach(section.symbols) { symbol in
                SymbolCellView(symbol: symbol, onInsert: onInsert)
                    .background(Color.primary.opacity(0.04))
                    .cornerRadius(8)
            }
        }
    }
}

// MARK: - Main Reference View

struct ReferenceView: View {
    /// Search text from the system `.searchable` bar.
    @State private var searchText = ""
    /// Commands tapped in a cell, for the copy feedback overlay.
    /// Shared editor state — inserting a symbol reaches the Editor tab.
    @EnvironmentObject var editorModel: EditorModel
    @State private var insertedCommand: String?

    /// Sections filtered by search; empty search shows everything.
    private var filteredSections: [LaTeXSymbolSection] {
        guard !searchText.isEmpty else { return LaTeXReference.sections }
        let query = searchText.lowercased()
        return LaTeXReference.sections.compactMap { section in
            let symbols = section.symbols.filter {
                $0.latex.lowercased().contains(query) || $0.note.lowercased().contains(query)
            }
            return symbols.isEmpty ? nil : LaTeXSymbolSection(name: section.name, symbols: symbols)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16, pinnedViews: .sectionHeaders) {
                    ForEach(filteredSections) { section in
                        Section {
                            SymbolSectionView(section: section, onInsert: insert)
                                .padding(.horizontal)
                        } header: {
                            Text(section.name)
                                .font(.headline)
                                .padding(.horizontal)
                                .padding(.vertical, 6)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(.thinMaterial)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Reference")
            .searchable(text: $searchText, prompt: "Search command or name")
            .overlay(alignment: .center) {
                if filteredSections.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 36))
                            .foregroundColor(.secondary)
                        Text("No results for \"\(searchText)\"")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
            }
            .overlay(alignment: .bottom) {
                if let inserted = insertedCommand {
                    Text("Inserted \(inserted)")
                        .font(.footnote.weight(.medium))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(.thinMaterial, in: Capsule())
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .task {
                            // New concurrency: Task { } replaces DispatchQueue.main.asyncAfter.
                            try? await Task.sleep(for: .seconds(1.2))
                            withAnimation { insertedCommand = nil }
                        }
                }
            }
            .animation(.easeOut(duration: 0.2), value: insertedCommand)
        }
        .environment(\.sizeCategory, .large)
    }

    /// Insert a symbol command into the shared editor and show feedback.
    private func insert(_ command: String) {
        editorModel.insert(command)
        withAnimation { insertedCommand = command }
    }
}

struct ReferenceView_Previews: PreviewProvider {
    static var previews: some View {
        ReferenceView()
    }
}
