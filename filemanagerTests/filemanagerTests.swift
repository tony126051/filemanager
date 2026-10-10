//
//  filemanagerTests.swift
//  filemanagerTests
//

import Foundation
import Testing
@testable import filemanager

@MainActor
struct filemanagerTests {

    @Test func testFileItemInitialization() throws {
        let tempDir = FileManager.default.temporaryDirectory
        let testFileURL = tempDir.appendingPathComponent("test_file_\(UUID().uuidString).txt")
        try "Windows 11 Explorer macOS Test Content".write(to: testFileURL, atomically: true, encoding: .utf8)
        defer {
            try? FileManager.default.removeItem(at: testFileURL)
        }
        
        let item = FileItem(url: testFileURL)
        #expect(item.name == testFileURL.lastPathComponent)
        #expect(item.extensionName == "txt")
        #expect(!item.isDirectory)
        #expect(item.fileSize > 0)
        #expect(!item.formattedSize.isEmpty)
        #expect(!item.kindDescription.isEmpty)
    }

    @Test func testFileSystemManagerCRUD() throws {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent("fm_test_\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer {
            try? FileManager.default.removeItem(at: tempDir)
        }
        
        let fs = FileSystemManager.shared
        
        // Create folder
        let folderURL = try fs.createFolder(in: tempDir, name: "測試資料夾")
        #expect(FileManager.default.fileExists(atPath: folderURL.path))
        
        // Create file
        let fileURL = try fs.createFile(in: folderURL, name: "測試文件.txt", content: "Hello Win11".data(using: .utf8)!)
        #expect(FileManager.default.fileExists(atPath: fileURL.path))
        
        // Rename file
        let renamedURL = try fs.rename(itemURL: fileURL, newName: "已重新命名.txt")
        #expect(FileManager.default.fileExists(atPath: renamedURL.path))
        #expect(!FileManager.default.fileExists(atPath: fileURL.path))
        
        // Copy file
        try fs.copy(items: [renamedURL], to: tempDir)
        let copiedURL = tempDir.appendingPathComponent("已重新命名.txt")
        #expect(FileManager.default.fileExists(atPath: copiedURL.path))
        
        // Delete item
        try fs.delete(items: [copiedURL], moveToTrash: false)
        #expect(!FileManager.default.fileExists(atPath: copiedURL.path))
    }

    @Test func testTabModelNavigationAndHistory() async throws {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let tab = TabModel(initialURL: home)
        
        #expect(tab.currentURL == home)
        #expect(!tab.canGoBack)
        #expect(!tab.canGoForward)
        
        let subURL = home.appendingPathComponent("Downloads")
        if FileManager.default.fileExists(atPath: subURL.path) {
            tab.navigateTo(url: subURL)
            #expect(tab.currentURL == subURL)
            #expect(tab.canGoBack)
            
            tab.goBack()
            #expect(tab.currentURL == home)
            #expect(tab.canGoForward)
            
            tab.goForward()
            #expect(tab.currentURL == subURL)
        }
    }

    @Test func testTabModelSearchAndSort() throws {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent("sort_test_\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer {
            try? FileManager.default.removeItem(at: tempDir)
        }
        
        let fs = FileSystemManager.shared
        _ = try fs.createFile(in: tempDir, name: "apple.txt")
        _ = try fs.createFile(in: tempDir, name: "banana.txt")
        _ = try fs.createFile(in: tempDir, name: "cherry.txt")
        
        let tab = TabModel(initialURL: tempDir)
        tab.loadContents()
        
        #expect(tab.items.count == 3)
        
        // Test Search Filter
        tab.searchQuery = "banana"
        #expect(tab.displayedItems.count == 1)
        #expect(tab.displayedItems.first?.name == "banana.txt")
        
        tab.searchQuery = ""
        #expect(tab.displayedItems.count == 3)
        
        // Test Sort
        tab.sortField = .name
        tab.sortAscending = true
        #expect(tab.displayedItems.first?.name == "apple.txt")
        
        tab.sortAscending = false
        #expect(tab.displayedItems.first?.name == "cherry.txt")
    }

    @Test func testExplorerViewModelTabsAndClipboard() throws {
        let vm = ExplorerViewModel()
        #expect(vm.tabs.count == 1)
        
        vm.addNewTab()
        #expect(vm.tabs.count == 2)
        #expect(vm.activeTabIndex == 1)
        
        vm.closeTab(at: 1)
        #expect(vm.tabs.count == 1)
        #expect(vm.activeTabIndex == 0)
    }

    @Test func testMountedVolumes() throws {
        let volumes = FileSystemManager.shared.getMountedVolumes()
        #expect(!volumes.isEmpty)
        #expect(volumes.contains(where: { $0.isRoot }))
    }

    @Test func testLocalizationManagerAllLanguages() throws {
        let lm = LocalizationManager.shared
        
        // Traditional Chinese
        lm.currentLanguage = .zhHant
        #expect(lm.resolvedLanguage == .zhHant)
        #expect(lm.tr("app_name") == "檔案總管")
        #expect(lm.tr("cmd_new") == "新增")
        #expect(lm.folderDisplayName(folderName: "Downloads") == "下載")
        
        // English
        lm.currentLanguage = .en
        #expect(lm.resolvedLanguage == .en)
        #expect(lm.tr("app_name") == "File Explorer")
        #expect(lm.tr("cmd_new") == "New")
        #expect(lm.folderDisplayName(folderName: "Downloads") == "Downloads")
        
        // Simplified Chinese
        lm.currentLanguage = .zhHans
        #expect(lm.resolvedLanguage == .zhHans)
        #expect(lm.tr("app_name") == "文件资源管理器")
        #expect(lm.tr("cmd_new") == "新建")
        #expect(lm.folderDisplayName(folderName: "Downloads") == "下载")
        
        // Japanese
        lm.currentLanguage = .ja
        #expect(lm.resolvedLanguage == .ja)
        #expect(lm.tr("app_name") == "ファイル エクスプローラー")
        #expect(lm.tr("cmd_new") == "新規作成")
        #expect(lm.folderDisplayName(folderName: "Downloads") == "ダウンロード")
        
        // Argument formatting
        let formatted = lm.tr("status_items_count", 42)
        #expect(formatted.contains("42"))
        
        // Reset to system or default
        lm.currentLanguage = .system
        #expect(AppLanguage.allCases.count >= 5)
    }

    @Test func testMultiSelectionOperations() throws {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent("multi_sel_test_\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer {
            try? FileManager.default.removeItem(at: tempDir)
        }
        
        let fs = FileSystemManager.shared
        let u1 = try fs.createFile(in: tempDir, name: "item1.txt")
        let u2 = try fs.createFile(in: tempDir, name: "item2.txt")
        let u3 = try fs.createFile(in: tempDir, name: "item3.txt")
        let u4 = try fs.createFile(in: tempDir, name: "item4.txt")
        
        let tab = TabModel(initialURL: tempDir)
        tab.loadContents()
        
        let items = tab.displayedItems
        #expect(items.count == 4)
        
        // 1. Single click selection
        tab.select(item: items[0], isToggle: false, isRange: false)
        #expect(tab.selectedURLs.count == 1)
        #expect(tab.selectedURLs.contains(u1))
        #expect(tab.anchorURL == u1)
        
        // 2. Cmd/Ctrl Toggle selection
        tab.select(item: items[2], isToggle: true, isRange: false)
        #expect(tab.selectedURLs.count == 2)
        #expect(tab.selectedURLs.contains(u1))
        #expect(tab.selectedURLs.contains(u3))
        #expect(tab.anchorURL == u3)
        
        // 3. Shift range selection from u3 to u0
        tab.select(item: items[0], isToggle: false, isRange: true)
        #expect(tab.selectedURLs.count == 4) // All items 0 to 3
        
        // 4. Invert selection
        tab.invertSelection()
        #expect(tab.selectedURLs.isEmpty)
        
        // 5. Select All
        tab.selectAll()
        #expect(tab.selectedURLs.count == 4)
        
        // 6. Deselect All
        tab.deselectAll()
        #expect(tab.selectedURLs.isEmpty)
        #expect(tab.anchorURL == nil)
    }

    @Test func testBatchFileOperations() throws {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent("batch_test_\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer {
            try? FileManager.default.removeItem(at: tempDir)
        }
        
        let fs = FileSystemManager.shared
        let f1 = try fs.createFile(in: tempDir, name: "batch1.txt", content: "data1".data(using: .utf8)!)
        let f2 = try fs.createFile(in: tempDir, name: "batch2.txt", content: "data2".data(using: .utf8)!)
        
        let vm = ExplorerViewModel()
        guard let tab = vm.activeTab else { return }
        tab.navigateTo(url: tempDir)
        
        // Select both
        tab.selectAll()
        #expect(tab.selectedURLs.count == 2)
        
        // Batch copy
        vm.copySelectedItems()
        #expect(vm.clipboardURLs.count == 2)
        #expect(!vm.isCutOperation)
        
        // Batch duplicate
        vm.duplicateSelectedItems()
        tab.refresh()
        #expect(tab.displayedItems.count == 4)
        
        // Batch delete
        vm.deleteSelectedItems(items: [f1, f2], moveToTrash: false)
        tab.refresh()
        #expect(!FileManager.default.fileExists(atPath: f1.path))
        #expect(!FileManager.default.fileExists(atPath: f2.path))
    }
}
