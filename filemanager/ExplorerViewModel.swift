//
//  ExplorerViewModel.swift
//  filemanager
//

import AppKit
import Combine
import Foundation
import SwiftUI

@MainActor
public final class ExplorerViewModel: ObservableObject {
    @Published public var tabs: [TabModel] = []
    @Published public var activeTabIndex: Int = 0
    
    @Published public var clipboardURLs: [URL] = []
    @Published public var isCutOperation: Bool = false
    
    @Published public var showHiddenFiles: Bool = false {
        didSet {
            activeTab?.refresh(showHidden: showHiddenFiles)
        }
    }
    
    @Published public var rightPaneMode: RightPaneMode = .none
    
    @Published public var pinnedFolders: [URL] = []
    @Published public var recentFolders: [URL] = []
    @Published public var mountedVolumes: [VolumeInfo] = []
    
    // Dialog states
    @Published public var showingPropertiesDialog: Bool = false
    @Published public var propertiesItem: FileItem? = nil
    
    @Published public var showingNewFolderDialog: Bool = false
    @Published public var newFolderNameInput: String = LocalizationManager.shared.tr("dialog_new_folder_default")
    
    @Published public var showingRenameDialog: Bool = false
    @Published public var renamingItem: FileItem? = nil
    @Published public var renameInput: String = ""
    
    @Published public var showingAboutDialog: Bool = false
    
    @Published public var statusMessage: String? = nil
    
    public init() {
        // Setup initial default pinned locations (Windows 11 Quick Access standard)
        let fm = FileManager.default
        let home = fm.homeDirectoryForCurrentUser
        
        let defaults: [URL] = [
            home.appendingPathComponent("Desktop"),
            home.appendingPathComponent("Downloads"),
            home.appendingPathComponent("Documents"),
            home.appendingPathComponent("Pictures"),
            home.appendingPathComponent("Music"),
            home.appendingPathComponent("Movies")
        ].filter { fm.fileExists(atPath: $0.path) }
        
        self.pinnedFolders = defaults
        self.recentFolders = [home]
        
        // Initial Tab
        let initialTab = TabModel(initialURL: home)
        self.tabs = [initialTab]
        self.activeTabIndex = 0
        
        refreshVolumes()
    }
    
    public var activeTab: TabModel? {
        guard !tabs.isEmpty, activeTabIndex >= 0, activeTabIndex < tabs.count else {
            return nil
        }
        return tabs[activeTabIndex]
    }
    
    public func refreshVolumes() {
        self.mountedVolumes = FileSystemManager.shared.getMountedVolumes()
    }
    
    // MARK: - Tab Operations
    
    public func addNewTab(url: URL? = nil) {
        let targetURL = url ?? activeTab?.currentURL ?? FileManager.default.homeDirectoryForCurrentUser
        let newTab = TabModel(initialURL: targetURL)
        tabs.append(newTab)
        activeTabIndex = tabs.count - 1
    }
    
    public func closeTab(at index: Int) {
        guard tabs.count > 1 else { return } // Keep at least one tab
        tabs.remove(at: index)
        if activeTabIndex >= tabs.count {
            activeTabIndex = tabs.count - 1
        }
    }
    
    public func selectTab(at index: Int) {
        guard index >= 0, index < tabs.count else { return }
        activeTabIndex = index
    }
    
    // MARK: - Clipboard & File Actions
    
    public func cutSelectedItems(items: [URL]? = nil) {
        guard let tab = activeTab else { return }
        let urls = items ?? Array(tab.selectedURLs)
        guard !urls.isEmpty else { return }
        clipboardURLs = urls
        isCutOperation = true
        showStatus(LocalizationManager.shared.tr("menu_cut_count", urls.count))
    }
    
    public func copySelectedItems(items: [URL]? = nil) {
        guard let tab = activeTab else { return }
        let urls = items ?? Array(tab.selectedURLs)
        guard !urls.isEmpty else { return }
        clipboardURLs = urls
        isCutOperation = false
        
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.writeObjects(urls as [NSURL])
        
        showStatus(LocalizationManager.shared.tr("menu_copy_count", urls.count))
    }
    
    public func copyPaths(urls: [URL]) {
        guard !urls.isEmpty else { return }
        let pathsString = urls.map { $0.path }.joined(separator: "\n")
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(pathsString, forType: .string)
        showStatus(LocalizationManager.shared.tr("menu_path_copied"))
    }
    
    public func openItems(urls: [URL]) {
        guard let tab = activeTab else { return }
        for url in urls {
            var isDir: ObjCBool = false
            if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir), isDir.boolValue {
                if urls.count == 1 {
                    tab.navigateTo(url: url)
                } else {
                    addNewTab(url: url)
                }
            } else {
                FileSystemManager.shared.openFile(url: url)
            }
        }
    }
    
    public func pasteItems() {
        guard let tab = activeTab else { return }
        let destination = tab.currentURL
        
        var urlsToPaste = clipboardURLs
        if urlsToPaste.isEmpty {
            // Check system pasteboard
            let pasteboard = NSPasteboard.general
            if let objects = pasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL] {
                urlsToPaste = objects
            }
        }
        
        guard !urlsToPaste.isEmpty else { return }
        
        do {
            if isCutOperation {
                try FileSystemManager.shared.move(items: urlsToPaste, to: destination)
                clipboardURLs.removeAll()
                isCutOperation = false
                showStatus("已移動 \(urlsToPaste.count) 個項目")
            } else {
                try FileSystemManager.shared.copy(items: urlsToPaste, to: destination)
                showStatus("已貼上 \(urlsToPaste.count) 個項目")
            }
            tab.refresh(showHidden: showHiddenFiles)
        } catch {
            showStatus("操作失敗: \(error.localizedDescription)")
        }
    }
    
    public func deleteSelectedItems(items: [URL]? = nil, moveToTrash: Bool = true) {
        guard let tab = activeTab else { return }
        let itemsToDelete = items ?? Array(tab.selectedURLs)
        guard !itemsToDelete.isEmpty else { return }
        
        do {
            try FileSystemManager.shared.delete(items: itemsToDelete, moveToTrash: moveToTrash)
            tab.selectedURLs.subtract(itemsToDelete)
            tab.refresh(showHidden: showHiddenFiles)
            showStatus(LocalizationManager.shared.tr("menu_delete_count", itemsToDelete.count))
        } catch {
            showStatus("刪除失敗: \(error.localizedDescription)")
        }
    }
    
    public func duplicateSelectedItems(items: [URL]? = nil) {
        guard let tab = activeTab else { return }
        let items = items ?? Array(tab.selectedURLs)
        guard !items.isEmpty else { return }
        do {
            try FileSystemManager.shared.duplicate(items: items)
            tab.refresh(showHidden: showHiddenFiles)
            showStatus(LocalizationManager.shared.tr("menu_duplicate_count", items.count))
        } catch {
            showStatus("重製失敗: \(error.localizedDescription)")
        }
    }
    
    public func startNewFolder() {
        newFolderNameInput = LocalizationManager.shared.tr("dialog_new_folder_default")
        showingNewFolderDialog = true
    }
    
    public func confirmNewFolder() {
        guard let tab = activeTab else { return }
        do {
            let newURL = try FileSystemManager.shared.createFolder(in: tab.currentURL, name: newFolderNameInput)
            tab.refresh(showHidden: showHiddenFiles)
            tab.selectedURLs = [newURL]
            showStatus("已建立資料夾: \(newURL.lastPathComponent)")
        } catch {
            showStatus("建立資料夾失敗: \(error.localizedDescription)")
        }
    }
    
    public func createNewTextDocument() {
        guard let tab = activeTab else { return }
        do {
            let newURL = try FileSystemManager.shared.createFile(in: tab.currentURL, name: "新增文字文件.txt")
            tab.refresh(showHidden: showHiddenFiles)
            tab.selectedURLs = [newURL]
            showStatus("已建立文字文件")
        } catch {
            showStatus("建立文件失敗: \(error.localizedDescription)")
        }
    }
    
    public func startRename(item: FileItem) {
        renamingItem = item
        renameInput = item.name
        showingRenameDialog = true
    }
    
    public func confirmRename() {
        guard let item = renamingItem, let tab = activeTab, !renameInput.isEmpty else { return }
        do {
            let newURL = try FileSystemManager.shared.rename(itemURL: item.url, newName: renameInput)
            tab.refresh(showHidden: showHiddenFiles)
            tab.selectedURLs = [newURL]
            showStatus("已重新命名為 \(newURL.lastPathComponent)")
        } catch {
            showStatus("重新命名失敗: \(error.localizedDescription)")
        }
    }
    
    public func showProperties(for item: FileItem?) {
        if let item = item {
            self.propertiesItem = item
        } else if let tab = activeTab, let firstSelected = tab.selectedURLs.first {
            self.propertiesItem = FileItem(url: firstSelected)
        } else if let tab = activeTab {
            self.propertiesItem = FileItem(url: tab.currentURL)
        }
        self.showingPropertiesDialog = true
    }
    
    public func togglePin(folderURL: URL) {
        if let index = pinnedFolders.firstIndex(of: folderURL) {
            pinnedFolders.remove(at: index)
            showStatus("已從快速存取取消釘選")
        } else {
            pinnedFolders.append(folderURL)
            showStatus("已釘選至快速存取")
        }
    }
    
    public func showStatus(_ message: String) {
        self.statusMessage = message
        Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            if self.statusMessage == message {
                self.statusMessage = nil
            }
        }
    }
}
