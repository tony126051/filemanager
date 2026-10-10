//
//  TabModel.swift
//  filemanager
//

import AppKit
import Combine
import Foundation
import SwiftUI

@MainActor
public final class TabModel: ObservableObject, Identifiable {
    public let id = UUID()
    
    @Published public var currentURL: URL
    @Published public var history: [URL] = []
    @Published public var historyIndex: Int = 0
    @Published public var items: [FileItem] = []
    @Published public var selectedURLs: Set<URL> = []
    @Published public var anchorURL: URL? = nil
    @Published public var showItemCheckboxes: Bool = false
    
    @Published public var sortField: SortField = .name
    @Published public var sortAscending: Bool = true
    @Published public var viewMode: ViewMode = .details
    @Published public var searchQuery: String = ""
    @Published public var isEditingAddress: Bool = false
    @Published public var addressText: String = ""
    
    public init(initialURL: URL = FileManager.default.homeDirectoryForCurrentUser) {
        self.currentURL = initialURL
        self.history = [initialURL]
        self.historyIndex = 0
        self.addressText = initialURL.path
        loadContents()
    }
    
    public var title: String {
        if currentURL.path == FileManager.default.homeDirectoryForCurrentUser.path {
            return LocalizationManager.shared.tr("home")
        }
        if currentURL.path == "/" || currentURL.lastPathComponent.isEmpty {
            return LocalizationManager.shared.tr("this_pc")
        }
        return LocalizationManager.shared.folderDisplayName(folderName: currentURL.lastPathComponent)
    }
    
    public var icon: NSImage {
        NSWorkspace.shared.icon(forFile: currentURL.path)
    }
    
    public var canGoBack: Bool {
        historyIndex > 0
    }
    
    public var canGoForward: Bool {
        historyIndex < history.count - 1
    }
    
    public var canGoUp: Bool {
        currentURL.path != "/"
    }
    
    public func navigateTo(url: URL, addToHistory: Bool = true) {
        var isDir: ObjCBool = false
        if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir), !isDir.boolValue {
            // It's a file, open it instead
            FileSystemManager.shared.openFile(url: url)
            return
        }
        
        currentURL = url
        addressText = url.path
        selectedURLs.removeAll()
        anchorURL = nil
        searchQuery = ""
        
        if addToHistory {
            // Truncate forward history if navigating to a new place
            if historyIndex + 1 < history.count {
                history = Array(history.prefix(historyIndex + 1))
            }
            history.append(url)
            historyIndex = history.count - 1
        }
        
        loadContents()
    }
    
    public func goBack() {
        guard canGoBack else { return }
        historyIndex -= 1
        navigateTo(url: history[historyIndex], addToHistory: false)
    }
    
    public func goForward() {
        guard canGoForward else { return }
        historyIndex += 1
        navigateTo(url: history[historyIndex], addToHistory: false)
    }
    
    public func goUp() {
        guard canGoUp else { return }
        let parentURL = currentURL.deletingLastPathComponent()
        navigateTo(url: parentURL)
    }
    
    public func refresh(showHidden: Bool = false) {
        loadContents(showHidden: showHidden)
    }
    
    public func loadContents(showHidden: Bool = false) {
        let rawItems = FileSystemManager.shared.contents(of: currentURL, showHidden: showHidden)
        self.items = sortAndFilterItems(rawItems)
    }
    
    public var displayedItems: [FileItem] {
        var result = items
        
        if !searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let query = searchQuery.lowercased()
            result = result.filter { $0.name.lowercased().contains(query) }
        }
        
        return sortAndFilterItems(result)
    }
    
    private func sortAndFilterItems(_ rawItems: [FileItem]) -> [FileItem] {
        return rawItems.sorted { a, b in
            // Folders first (Windows 11 default behavior)
            if a.isDirectory != b.isDirectory {
                return a.isDirectory && !b.isDirectory
            }
            
            let result: Bool
            switch sortField {
            case .name:
                result = a.name.localizedStandardCompare(b.name) == .orderedAscending
            case .dateModified:
                result = a.modificationDate < b.modificationDate
            case .type:
                result = a.kindDescription.localizedCompare(b.kindDescription) == .orderedAscending
            case .size:
                result = a.fileSize < b.fileSize
            }
            return sortAscending ? result : !result
        }
    }
    
    // MARK: - Selection Operations
    
    public func select(item: FileItem, isToggle: Bool = false, isRange: Bool = false) {
        let currentDisplayed = displayedItems
        if isRange, let anchor = anchorURL,
           let anchorIndex = currentDisplayed.firstIndex(where: { $0.url == anchor }),
           let targetIndex = currentDisplayed.firstIndex(where: { $0.url == item.url }) {
            let startIndex = min(anchorIndex, targetIndex)
            let endIndex = max(anchorIndex, targetIndex)
            let rangeSet = Set(currentDisplayed[startIndex...endIndex].map { $0.url })
            if isToggle {
                selectedURLs.formUnion(rangeSet)
            } else {
                selectedURLs = rangeSet
            }
        } else if isToggle {
            if selectedURLs.contains(item.url) {
                selectedURLs.remove(item.url)
            } else {
                selectedURLs.insert(item.url)
            }
            anchorURL = item.url
        } else {
            selectedURLs = [item.url]
            anchorURL = item.url
        }
    }
    
    public func selectAll() {
        selectedURLs = Set(displayedItems.map { $0.url })
        anchorURL = displayedItems.first?.url
    }
    
    public func deselectAll() {
        selectedURLs.removeAll()
        anchorURL = nil
    }
    
    public func invertSelection() {
        let all = Set(displayedItems.map { $0.url })
        selectedURLs = all.subtracting(selectedURLs)
        anchorURL = selectedURLs.first
    }
}
