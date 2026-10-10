//
//  filemanagerApp.swift
//  filemanager
//
//  Created by Tony Huang on 2026/10/10.
//

import SwiftUI

@main
struct filemanagerApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: filemanagerDocument()) { file in
            ContentView(document: file.$document)
        }
    }
}
