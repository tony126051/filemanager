//
//  ContentView.swift
//  filemanager
//
//  Created by Tony Huang on 2026/10/10.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: filemanagerDocument

    var body: some View {
        TextEditor(text: $document.text)
    }
}

#Preview {
    ContentView(document: .constant(filemanagerDocument()))
}
