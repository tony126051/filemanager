//
//  ContentView.swift
//  filemanager
//

import AppKit
import SwiftUI

public struct ContentView: View {
    @StateObject private var viewModel = ExplorerViewModel()
    @ObservedObject var lang = LocalizationManager.shared
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            // Top Tabs Bar
            TabsBarView(viewModel: viewModel)
            
            if let tab = viewModel.activeTab {
                // Address Bar & History & Search
                AddressBarView(viewModel: viewModel, tab: tab)
                
                // Windows 11 Command Bar (Ribbon)
                CommandBarView(viewModel: viewModel, tab: tab)
                
                // Main Split View
                HSplitView {
                    // Left Sidebar (Navigation Pane)
                    SidebarView(viewModel: viewModel, tab: tab)
                    
                    // Center Content View
                    FileContentView(viewModel: viewModel, tab: tab)
                        .frame(minWidth: 400, maxWidth: .infinity, maxHeight: .infinity)
                    
                    // Right Pane (Preview / Details)
                    if viewModel.rightPaneMode != .none {
                        PreviewPaneView(viewModel: viewModel, tab: tab)
                    }
                }
                
                // Bottom Status Bar
                StatusBarView(viewModel: viewModel, tab: tab)
            } else {
                Spacer()
                Text(lang.tr("no_open_tabs"))
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .frame(minWidth: 800, minHeight: 520)
        // Sheets
        .sheet(isPresented: $viewModel.showingPropertiesDialog) {
            if let item = viewModel.propertiesItem {
                PropertiesDialogView(item: item) {
                    viewModel.showingPropertiesDialog = false
                }
            }
        }
        .sheet(isPresented: $viewModel.showingNewFolderDialog) {
            NewFolderDialog(
                folderName: $viewModel.newFolderNameInput,
                onConfirm: {
                    viewModel.confirmNewFolder()
                    viewModel.showingNewFolderDialog = false
                },
                onCancel: {
                    viewModel.showingNewFolderDialog = false
                }
            )
        }
        .sheet(isPresented: $viewModel.showingRenameDialog) {
            RenameDialog(
                newName: $viewModel.renameInput,
                onConfirm: {
                    viewModel.confirmRename()
                    viewModel.showingRenameDialog = false
                },
                onCancel: {
                    viewModel.showingRenameDialog = false
                }
            )
        }
        // Keyboard Shortcuts
        .background(
            Group {
                Button("") { viewModel.addNewTab() }
                    .keyboardShortcut("t", modifiers: .command)
                Button("") { viewModel.closeTab(at: viewModel.activeTabIndex) }
                    .keyboardShortcut("w", modifiers: .command)
                Button("") { viewModel.activeTab?.refresh(showHidden: viewModel.showHiddenFiles) }
                    .keyboardShortcut("r", modifiers: .command)
                Button("") { viewModel.activeTab?.selectAll() }
                    .keyboardShortcut("a", modifiers: .command)
                Button("") { viewModel.activeTab?.deselectAll() }
                    .keyboardShortcut("a", modifiers: [.command, .shift])
                Button("") { viewModel.activeTab?.invertSelection() }
                    .keyboardShortcut("i", modifiers: .command)
                Button("") { viewModel.copySelectedItems() }
                    .keyboardShortcut("c", modifiers: .command)
                Button("") { viewModel.cutSelectedItems() }
                    .keyboardShortcut("x", modifiers: .command)
                Button("") { viewModel.pasteItems() }
                    .keyboardShortcut("v", modifiers: .command)
                Button("") { viewModel.deleteSelectedItems(moveToTrash: true) }
                    .keyboardShortcut(.delete, modifiers: .command)
                Button("") { viewModel.startNewFolder() }
                    .keyboardShortcut("n", modifiers: [.command, .shift])
            }
            .opacity(0)
            .allowsHitTesting(false)
        )
    }
    
    private func selectAll() {
        guard let tab = viewModel.activeTab else { return }
        tab.selectedURLs = Set(tab.displayedItems.map { $0.url })
    }
}

private struct NewFolderDialog: View {
    @Binding var folderName: String
    let onConfirm: () -> Void
    let onCancel: () -> Void
    @ObservedObject var lang = LocalizationManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(lang.tr("dialog_new_folder_title"))
                .font(.system(size: 14, weight: .bold))
            
            TextField(lang.tr("dialog_new_folder_placeholder"), text: $folderName)
                .textFieldStyle(.roundedBorder)
                .onSubmit(onConfirm)
            
            HStack {
                Spacer()
                Button(lang.tr("cancel"), action: onCancel)
                    .keyboardShortcut(.cancelAction)
                Button(lang.tr("create"), action: onConfirm)
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding(16)
        .frame(width: 320)
    }
}

private struct RenameDialog: View {
    @Binding var newName: String
    let onConfirm: () -> Void
    let onCancel: () -> Void
    @ObservedObject var lang = LocalizationManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(lang.tr("dialog_rename_title"))
                .font(.system(size: 14, weight: .bold))
            
            TextField(lang.tr("dialog_rename_placeholder"), text: $newName)
                .textFieldStyle(.roundedBorder)
                .onSubmit(onConfirm)
            
            HStack {
                Spacer()
                Button(lang.tr("cancel"), action: onCancel)
                    .keyboardShortcut(.cancelAction)
                Button(lang.tr("ok"), action: onConfirm)
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding(16)
        .frame(width: 340)
    }
}
