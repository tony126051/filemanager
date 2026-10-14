//
//  filemanagerApp.swift
//  filemanager
//

import SwiftUI

@main
struct filemanagerApp: App {
    @ObservedObject var lang = LocalizationManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            SidebarCommands()
            CommandGroup(replacing: .appInfo) {
                Button(lang.tr("about_filemanager")) {
                    NotificationCenter.default.post(name: NSNotification.Name("ShowAboutDialog"), object: nil)
                }
            }
            CommandMenu(lang.tr("language")) {
                ForEach(AppLanguage.allCases) { item in
                    Button(action: {
                        lang.currentLanguage = item
                    }) {
                        HStack {
                            Text(item.displayName)
                            if lang.currentLanguage == item {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
        }
    }
}
