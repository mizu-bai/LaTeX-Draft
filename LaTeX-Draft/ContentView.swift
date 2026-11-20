//
//  ContentView.swift
//  LaTeX-Draft
//
//  Created by mizu bai on 2021/12/12.
//
//

import SwiftUI

struct ContentView: View {
    /// The single shared state instances for the whole app.
    @StateObject private var editorModel = EditorModel()
    @StateObject private var settingsModel = SettingsModel()

    var body: some View {
        TabView {
            EditorView()
                .tabItem {
                    Image(systemName: "pencil")
                    Text("Editor")
                }

            ReferenceView()
                .tabItem {
                    Image(systemName: "tablecells")
                    Text("Reference")
                }

            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
        }
        // Sibling tabs share one model: tapping a Reference symbol mutates
        // editorModel.latex, and the Editor tab updates automatically.
        .environmentObject(editorModel)
        .environmentObject(settingsModel)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
