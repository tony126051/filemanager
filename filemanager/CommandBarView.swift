//
//  CommandBarView.swift
//  filemanager
//

import AppKit
import SwiftUI

public struct CommandBarView: View {
    @ObservedObject var viewModel: ExplorerViewModel
    @ObservedObject var tab: TabModel
    @ObservedObject var lang = LocalizationManager.shared
    
    private var hasSelection: Bool {
        !tab.selectedURLs.isEmpty
    }
    
    public var body: some View {
        HStack(spacing: 4) {
            // "New" Dropdown
            Menu {
                Button(action: { viewModel.startNewFolder() }) {
                    Label(lang.tr("cmd_new_folder"), systemImage: "folder.badge.plus")
                }
                .keyboardShortcut("n", modifiers: [.command, .shift])
                
                Divider()
                
                Button(action: { viewModel.createNewTextDocument() }) {
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
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "plus")
                        .foregroundColor(Windows11Theme.accentColor)
                    Text(lang.tr("cmd_new"))
                        .font(.system(size: 12, weight: .medium))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 8)
                .frame(height: 28)
                .background(Color.primary.opacity(0.04))
                .cornerRadius(Windows11Theme.buttonCornerRadius)
            }
            .menuStyle(.borderlessButton)
            .fixedSize()
            
            Divider()
                .frame(height: 18)
                .padding(.horizontal, 2)
            
            // Standard Win11 Action Icons
            Group {
                // Cut
                ToolbarIconButton(
                    icon: "scissors",
                    tooltip: "\(lang.tr("cmd_cut")) (Cmd+X)",
                    isEnabled: hasSelection
                ) {
                    viewModel.cutSelectedItems()
                }
                
                // Copy
                ToolbarIconButton(
                    icon: "doc.on.doc",
                    tooltip: "\(lang.tr("cmd_copy")) (Cmd+C)",
                    isEnabled: hasSelection
                ) {
                    viewModel.copySelectedItems()
                }
                
                // Paste
                ToolbarIconButton(
                    icon: "doc.on.clipboard",
                    tooltip: "\(lang.tr("cmd_paste")) (Cmd+V)",
                    isEnabled: !viewModel.clipboardURLs.isEmpty || NSPasteboard.general.pasteboardItems?.isEmpty == false
                ) {
                    viewModel.pasteItems()
                }
                
                // Rename
                ToolbarIconButton(
                    icon: "pencil",
                    tooltip: "\(lang.tr("cmd_rename")) (Enter)",
                    isEnabled: tab.selectedURLs.count == 1
                ) {
                    if let firstURL = tab.selectedURLs.first,
                       let item = tab.items.first(where: { $0.url == firstURL }) {
                        viewModel.startRename(item: item)
                    }
                }
                
                // Share
                ToolbarIconButton(
                    icon: "square.and.arrow.up",
                    tooltip: lang.tr("cmd_share"),
                    isEnabled: hasSelection
                ) {
                    shareSelectedItems()
                }
                
                // Delete
                ToolbarIconButton(
                    icon: "trash",
                    tooltip: "\(lang.tr("cmd_delete")) (Cmd+Delete)",
                    isEnabled: hasSelection
                ) {
                    viewModel.deleteSelectedItems(moveToTrash: true)
                }
            }
            
            Divider()
                .frame(height: 18)
                .padding(.horizontal, 2)
            
            // Sort Menu
            Menu {
                Section(lang.tr("cmd_sort_by")) {
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
                }
                
                Divider()
                
                Section(lang.tr("cmd_sort_order")) {
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
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 11))
                    Text(lang.tr("cmd_sort"))
                        .font(.system(size: 12))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 6)
                .frame(height: 28)
                .background(Color.primary.opacity(0.04))
                .cornerRadius(Windows11Theme.buttonCornerRadius)
            }
            .menuStyle(.borderlessButton)
            .fixedSize()
            
            // View Mode Menu
            Menu {
                Section(lang.tr("cmd_view_mode")) {
                    ForEach(ViewMode.allCases) { mode in
                        Button(action: { tab.viewMode = mode }) {
                            HStack {
                                Label(mode.localizedTitle, systemImage: mode.iconName)
                                if tab.viewMode == mode {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                }
                
                Divider()
                
                Section(lang.tr("cmd_show")) {
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
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: tab.viewMode.iconName)
                        .font(.system(size: 11))
                    Text(lang.tr("cmd_view"))
                        .font(.system(size: 12))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 6)
                .frame(height: 28)
                .background(Color.primary.opacity(0.04))
                .cornerRadius(Windows11Theme.buttonCornerRadius)
            }
            .menuStyle(.borderlessButton)
            .fixedSize()
            
            Spacer()
            
            // Multi-Language Selector Dropdown
            Menu {
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
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "globe")
                        .font(.system(size: 11))
                        .foregroundColor(Windows11Theme.accentColor)
                    Text(lang.currentLanguage.shortName)
                        .font(.system(size: 11, weight: .medium))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 6)
                .frame(height: 28)
                .background(Color.primary.opacity(0.04))
                .cornerRadius(Windows11Theme.buttonCornerRadius)
            }
            .menuStyle(.borderlessButton)
            .fixedSize()
            .help(lang.tr("language"))
            
            Divider()
                .frame(height: 18)
                .padding(.horizontal, 2)
            
            // Terminal button
            ToolbarIconButton(
                icon: "terminal",
                tooltip: lang.tr("cmd_open_terminal"),
                isEnabled: true
            ) {
                if let first = tab.selectedURLs.first {
                    FileSystemManager.shared.openInTerminal(url: first)
                } else {
                    FileSystemManager.shared.openInTerminal(url: tab.currentURL)
                }
            }
            
            // Properties dialog button
            ToolbarIconButton(
                icon: "info.circle",
                tooltip: lang.tr("cmd_properties"),
                isEnabled: true
            ) {
                viewModel.showProperties(for: nil)
            }
            
            // About dialog button
            ToolbarIconButton(
                icon: "questionmark.circle",
                tooltip: lang.tr("about_filemanager"),
                isEnabled: true
            ) {
                viewModel.showingAboutDialog = true
            }
        }
        .padding(.horizontal, 10)
        .frame(height: 36)
        .background(Color(NSColor.windowBackgroundColor))
        .overlay(
            Divider(), alignment: .bottom
        )
    }
    
    private func shareSelectedItems() {
        guard !tab.selectedURLs.isEmpty else { return }
        let picker = NSSharingServicePicker(items: Array(tab.selectedURLs))
        if let window = NSApplication.shared.keyWindow,
           let contentView = window.contentView {
            picker.show(relativeTo: .zero, of: contentView, preferredEdge: .minY)
        }
    }
}

private struct ToolbarIconButton: View {
    let icon: String
    let tooltip: String
    let isEnabled: Bool
    let action: () -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(isEnabled ? .primary : .secondary.opacity(0.4))
                .frame(width: 28, height: 28)
                .background(isHovering && isEnabled ? Color.primary.opacity(0.08) : Color.clear)
                .cornerRadius(Windows11Theme.buttonCornerRadius)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .help(tooltip)
        .onHover { hovering in
            isHovering = hovering
        }
    }
}
