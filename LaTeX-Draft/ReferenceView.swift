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
/// Tapping the cell copies the command to the clipboard.
struct SymbolCellView: View {
    let symbol: LaTeXSymbol
    /// Called when the cell is tapped; parent shows the "Copied" feedback.
    let onCopy: (String) -> Void

    var body: some View {
        VStack(spacing: 6) {
            MathUILabel(latex: symbol.renderAs)
                .frame(minHeight: 32)
                .frame(maxWidth: .infinity)
            Text(symbol.latex)
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 4)
        .contentShape(Rectangle()) // make the whole cell tappable, not just the text
        .onTapGesture {
            onCopy(symbol.latex)
        }
    }
}

// MARK: - Section View

struct SymbolSectionView: View {
    let section: LaTeXSymbolSection
    let onCopy: (String) -> Void

    /// Two-column adaptive grid: 200pt is the ideal cell width on iPhone,
    /// more columns appear automatically on wider windows (iPad / Mac).
    private let columns = [GridItem(.adaptive(minimum: 200), spacing: 8)]

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
            ForEach(section.symbols) { symbol in
                SymbolCellView(symbol: symbol, onCopy: onCopy)
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
    @State private var copiedCommand: String?

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
                            SymbolSectionView(section: section, onCopy: copy)
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
                if let copied = copiedCommand {
                    Text("Copied \(copied)")
                        .font(.footnote.weight(.medium))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(.thinMaterial, in: Capsule())
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .task {
                            // New concurrency: Task { } replaces DispatchQueue.main.asyncAfter.
                            try? await Task.sleep(for: .seconds(1.2))
                            withAnimation { copiedCommand = nil }
                        }
                }
            }
            .animation(.easeOut(duration: 0.2), value: copiedCommand)
        }
        .environment(\.sizeCategory, .large)
    }

    // Copy feedback helper used by cells (kept simple for now).
    private func copy(_ command: String) {
        UIPasteboard.general.string = command
        withAnimation { copiedCommand = command }
    }
}

struct ReferenceView_Previews: PreviewProvider {
    static var previews: some View {
        ReferenceView()
    }
}
