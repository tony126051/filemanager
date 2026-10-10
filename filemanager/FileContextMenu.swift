//
//  FileContextMenu.swift
//  filemanager
//

import AppKit
import SwiftUI

public struct FileContextMenu: View {
    let item: FileItem
    let viewModel: ExplorerViewModel
    let tab: TabModel
    
    private var lang: LocalizationManager {
        LocalizationManager.shared
    }
    
    private var targetURLs: [URL] {
        if tab.selectedURLs.contains(item.url) {
            return Array(tab.selectedURLs)
        } else {
            return [item.url]
        }
    }
    
    private var isMultiSelection: Bool {
        targetURLs.count > 1
    }
    
    private func ensureSelected() {
        if !tab.selectedURLs.contains(item.url) {
            tab.selectedURLs = [item.url]
            tab.anchorURL = item.url
        }
    }
    
    public var body: some View {
        Group {
            if isMultiSelection {
                multiSelectionMenu
            } else {
                singleItemMenu
            }
        }
        .onAppear {
            ensureSelected()
        }
    }
    
    // MARK: - Multi Selection Menu
    
    @ViewBuilder
    private var multiSelectionMenu: some View {
        Button(action: {
            viewModel.openItems(urls: targetURLs)
        }) {
            Label(lang.tr("menu_open_count", targetURLs.count), systemImage: "arrow.up.forward.app")
        }
        
        Button(action: {
            NSWorkspace.shared.activateFileViewerSelecting(targetURLs)
        }) {
            Label(lang.tr("menu_reveal_in_finder"), systemImage: "folder")
        }
        
        Button(action: {
            shareItems(urls: targetURLs)
        }) {
            Label(lang.tr("menu_share_count", targetURLs.count), systemImage: "square.and.arrow.up")
        }
        
        Divider()
        
        Button(action: {
            viewModel.cutSelectedItems(items: targetURLs)
        }) {
            Label(lang.tr("menu_cut_count", targetURLs.count), systemImage: "scissors")
        }
        .keyboardShortcut("x", modifiers: .command)
        
        Button(action: {
            viewModel.copySelectedItems(items: targetURLs)
        }) {
            Label(lang.tr("menu_copy_count", targetURLs.count), systemImage: "doc.on.doc")
        }
        .keyboardShortcut("c", modifiers: .command)
        
        Button(action: {
            viewModel.copyPaths(urls: targetURLs)
        }) {
            Label(lang.tr("menu_copy_paths"), systemImage: "link")
        }
        
        Divider()
        
        Button(action: {
            viewModel.duplicateSelectedItems(items: targetURLs)
        }) {
            Label(lang.tr("menu_duplicate_count", targetURLs.count), systemImage: "plus.square.on.square")
        }
        
        Button(action: {
            viewModel.deleteSelectedItems(items: targetURLs, moveToTrash: true)
        }) {
            Label(lang.tr("menu_delete_count", targetURLs.count), systemImage: "trash")
        }
        .keyboardShortcut(.delete, modifiers: .command)
        
        Divider()
        
        Button(action: {
            viewModel.showProperties(for: item)
        }) {
            Label(lang.tr("menu_properties_count", targetURLs.count), systemImage: "info.circle")
        }
        
        Button(action: {
            tab.invertSelection()
        }) {
            Label(lang.tr("invert_selection"), systemImage: "arrow.left.arrow.right")
        }
        
        Button(action: {
            tab.deselectAll()
        }) {
            Label(lang.tr("select_none"), systemImage: "circle")
        }
    }
    
    // MARK: - Single Item Menu
    
    @ViewBuilder
    private var singleItemMenu: some View {
        Button(action: {
            if item.isDirectory && !item.isPackage {
                tab.navigateTo(url: item.url)
            } else {
                FileSystemManager.shared.openFile(url: item.url)
            }
        }) {
            Label(lang.tr("menu_open"), systemImage: "arrow.up.forward.app")
        }
        
        if item.isDirectory && !item.isPackage {
            Button(action: {
                viewModel.addNewTab(url: item.url)
            }) {
                Label(lang.tr("menu_open_in_new_tab"), systemImage: "plus.rectangle.on.rectangle")
            }
            
            Button(action: {
                viewModel.togglePin(folderURL: item.url)
            }) {
                Label(
                    viewModel.pinnedFolders.contains(item.url)
                        ? lang.tr("menu_unpin_quick_access")
                        : lang.tr("menu_pin_quick_access"),
                    systemImage: "pin"
                )
            }
        }
        
        Button(action: {
            FileSystemManager.shared.openInTerminal(url: item.url)
        }) {
            Label(lang.tr("cmd_open_terminal"), systemImage: "terminal")
        }
        
        Button(action: {
            FileSystemManager.shared.revealInFinder(url: item.url)
        }) {
            Label(lang.tr("menu_reveal_in_finder"), systemImage: "folder")
        }
        
        Button(action: {
            shareItems(urls: [item.url])
        }) {
            Label(lang.tr("cmd_share"), systemImage: "square.and.arrow.up")
        }
        
        Divider()
        
        Button(action: {
            viewModel.cutSelectedItems(items: [item.url])
        }) {
            Label(lang.tr("cmd_cut"), systemImage: "scissors")
        }
        .keyboardShortcut("x", modifiers: .command)
        
        Button(action: {
            viewModel.copySelectedItems(items: [item.url])
        }) {
            Label(lang.tr("cmd_copy"), systemImage: "doc.on.doc")
        }
        .keyboardShortcut("c", modifiers: .command)
        
        Button(action: {
            viewModel.copyPaths(urls: [item.url])
        }) {
            Label(lang.tr("menu_copy_path"), systemImage: "link")
        }
        
        Divider()
        
        Button(action: {
            viewModel.startRename(item: item)
        }) {
            Label(lang.tr("cmd_rename"), systemImage: "pencil")
        }
        
        Button(action: {
            viewModel.duplicateSelectedItems(items: [item.url])
        }) {
            Label(lang.tr("menu_duplicate"), systemImage: "plus.square.on.square")
        }
        
        Button(action: {
            viewModel.deleteSelectedItems(items: [item.url], moveToTrash: true)
        }) {
            Label(lang.tr("cmd_delete"), systemImage: "trash")
        }
        .keyboardShortcut(.delete, modifiers: .command)
        
        Divider()
        
        Button(action: {
            viewModel.showProperties(for: item)
        }) {
            Label(lang.tr("cmd_properties"), systemImage: "info.circle")
        }
        
        Button(action: {
            tab.selectAll()
        }) {
            Label(lang.tr("select_all"), systemImage: "checkmark.circle")
        }
    }
    
    private func shareItems(urls: [URL]) {
        let picker = NSSharingServicePicker(items: urls)
        if let window = NSApplication.shared.keyWindow,
           let contentView = window.contentView {
            picker.show(relativeTo: .zero, of: contentView, preferredEdge: .minY)
        }
    }
}
