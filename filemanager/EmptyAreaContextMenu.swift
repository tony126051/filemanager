//
//  EmptyAreaContextMenu.swift
//  filemanager
//

import AppKit
import SwiftUI

public struct EmptyAreaContextMenu: View {
    @ObservedObject var viewModel: ExplorerViewModel
    @ObservedObject var tab: TabModel
    
    private var lang: LocalizationManager {
        LocalizationManager.shared
    }
    
    public init(viewModel: ExplorerViewModel, tab: TabModel) {
        self.viewModel = viewModel
        self.tab = tab
    }
    
    public var body: some View {
        Group {
            // View Mode Submenu
            Menu(lang.tr("cmd_view")) {
                ForEach(ViewMode.allCases) { mode in
                    Button(action: {
                        tab.viewMode = mode
                    }) {
                        HStack {
                            Label(mode.localizedTitle, systemImage: mode.iconName)
                            if tab.viewMode == mode {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
                
                Divider()
                
                Button(action: {
                    tab.showItemCheckboxes.toggle()
                }) {
                    HStack {
                        Text(lang.tr("item_checkboxes"))
                        if tab.showItemCheckboxes {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                
                Button(action: {
                    viewModel.showHiddenFiles.toggle()
                }) {
                    HStack {
                        Text(lang.tr("cmd_show_hidden"))
                        if viewModel.showHiddenFiles {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                
                Button(action: {
                    viewModel.rightPaneMode = (viewModel.rightPaneMode == .preview) ? .none : .preview
                }) {
                    HStack {
                        Text(lang.tr("cmd_show_preview"))
                        if viewModel.rightPaneMode == .preview {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                
                Button(action: {
                    viewModel.rightPaneMode = (viewModel.rightPaneMode == .details) ? .none : .details
                }) {
                    HStack {
                        Text(lang.tr("cmd_show_details"))
                        if viewModel.rightPaneMode == .details {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
            
            // Sort Submenu
            Menu(lang.tr("cmd_sort")) {
                ForEach(SortField.allCases) { field in
                    Button(action: {
                        tab.sortField = field
                        tab.refresh(showHidden: viewModel.showHiddenFiles)
                    }) {
                        HStack {
                            Text(field.localizedTitle)
                            if tab.sortField == field {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
                
                Divider()
                
                Button(action: {
                    tab.sortAscending = true
                    tab.refresh(showHidden: viewModel.showHiddenFiles)
                }) {
                    HStack {
                        Text(lang.tr("cmd_ascending"))
                        if tab.sortAscending {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                
                Button(action: {
                    tab.sortAscending = false
                    tab.refresh(showHidden: viewModel.showHiddenFiles)
                }) {
                    HStack {
                        Text(lang.tr("cmd_descending"))
                        if !tab.sortAscending {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
            
            Button(action: {
                tab.refresh(showHidden: viewModel.showHiddenFiles)
            }) {
                Label(lang.tr("nav_refresh"), systemImage: "arrow.clockwise")
            }
            
            Divider()
            
            Button(action: {
                viewModel.pasteItems()
            }) {
                Label(lang.tr("cmd_paste"), systemImage: "doc.on.clipboard")
            }
            .disabled(viewModel.clipboardURLs.isEmpty && NSPasteboard.general.pasteboardItems?.isEmpty != false)
            
            Menu(lang.tr("cmd_new")) {
                Button(action: {
                    viewModel.startNewFolder()
                }) {
                    Label(lang.tr("cmd_new_folder"), systemImage: "folder.badge.plus")
                }
                
                Button(action: {
                    viewModel.createNewTextDocument()
                }) {
                    Label(lang.tr("cmd_new_txt"), systemImage: "doc.text")
                }
                
                Button(action: {
                    try? FileSystemManager.shared.createFile(in: tab.currentURL, name: "README.md")
                    tab.refresh(showHidden: viewModel.showHiddenFiles)
                }) {
                    Label(lang.tr("cmd_new_md"), systemImage: "text.document")
                }
                
                Button(action: {
                    try? FileSystemManager.shared.createFile(in: tab.currentURL, name: "main.swift")
                    tab.refresh(showHidden: viewModel.showHiddenFiles)
                }) {
                    Label(lang.tr("cmd_new_swift"), systemImage: "swift")
                }
            }
            
            Divider()
            
            Button(action: {
                tab.selectAll()
            }) {
                Label(lang.tr("select_all"), systemImage: "checkmark.circle")
            }
            
            if !tab.selectedURLs.isEmpty {
                Button(action: {
                    tab.deselectAll()
                }) {
                    Label(lang.tr("select_none"), systemImage: "circle")
                }
                
                Button(action: {
                    tab.invertSelection()
                }) {
                    Label(lang.tr("invert_selection"), systemImage: "arrow.left.arrow.right")
                }
            }
            
            Divider()
            
            Button(action: {
                FileSystemManager.shared.openInTerminal(url: tab.currentURL)
            }) {
                Label(lang.tr("cmd_open_terminal"), systemImage: "terminal")
            }
            
            Button(action: {
                FileSystemManager.shared.revealInFinder(url: tab.currentURL)
            }) {
                Label(lang.tr("menu_reveal_in_finder"), systemImage: "folder")
            }
            
            Divider()
            
            Button(action: {
                viewModel.showProperties(for: FileItem(url: tab.currentURL))
            }) {
                Label(lang.tr("cmd_properties"), systemImage: "info.circle")
            }
        }
    }
}
