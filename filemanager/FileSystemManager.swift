//
//  FileSystemManager.swift
//  filemanager
//

import AppKit
import Foundation

public struct VolumeInfo: Identifiable, Hashable, Sendable {
    public var id: URL { url }
    public let url: URL
    public let name: String
    public let totalBytes: Int64
    public let freeBytes: Int64
    public let isRemovable: Bool
    public let isRoot: Bool
    
    public var usedBytes: Int64 {
        max(0, totalBytes - freeBytes)
    }
    
    public var freePercentage: Double {
        guard totalBytes > 0 else { return 0 }
        return Double(freeBytes) / Double(totalBytes)
    }
    
    @MainActor
    public var formattedDescription: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useGB, .useTB]
        formatter.countStyle = .file
        let freeStr = formatter.string(fromByteCount: freeBytes)
        let totalStr = formatter.string(fromByteCount: totalBytes)
        return LocalizationManager.shared.tr("volume_free_description", freeStr, totalStr)
    }
}

public final class FileSystemManager: Sendable {
    public static let shared = FileSystemManager()
    
    private init() {}
    
    /// Loads children for a given directory URL.
    public func contents(of directoryURL: URL, showHidden: Bool = false) -> [FileItem] {
        let fileManager = FileManager.default
        let options: FileManager.DirectoryEnumerationOptions = showHidden ? [] : [.skipsHiddenFiles]
        
        do {
            let urls = try fileManager.contentsOfDirectory(
                at: directoryURL,
                includingPropertiesForKeys: [
                    .isDirectoryKey,
                    .isPackageKey,
                    .isVolumeKey,
                    .fileSizeKey,
                    .creationDateKey,
                    .contentModificationDateKey,
                    .localizedTypeDescriptionKey
                ],
                options: options
            )
            
            return urls.map { FileItem(url: $0) }
        } catch {
            print("Failed to load contents of \(directoryURL.path): \(error)")
            return []
        }
    }
    
    /// Returns mounted local volumes (disks).
    public func getMountedVolumes() -> [VolumeInfo] {
        let fileManager = FileManager.default
        let keys: [URLResourceKey] = [
            .volumeNameKey,
            .volumeTotalCapacityKey,
            .volumeAvailableCapacityKey,
            .volumeIsRemovableKey,
            .volumeIsRootFileSystemKey
        ]
        guard let volumeURLs = fileManager.mountedVolumeURLs(includingResourceValuesForKeys: keys, options: [.skipHiddenVolumes]) else {
            return []
        }
        
        var list: [VolumeInfo] = []
        for url in volumeURLs {
            let values = try? url.resourceValues(forKeys: Set(keys))
            let name = values?.volumeName ?? url.lastPathComponent
            let total = Int64(values?.volumeTotalCapacity ?? 0)
            let free = Int64(values?.volumeAvailableCapacity ?? 0)
            let isRemovable = values?.volumeIsRemovable ?? false
            let isRoot = values?.volumeIsRootFileSystem ?? false
            
            list.append(VolumeInfo(
                url: url,
                name: name,
                totalBytes: total,
                freeBytes: free,
                isRemovable: isRemovable,
                isRoot: isRoot
            ))
        }
        return list
    }
    
    /// Create new folder.
    public func createFolder(in parentURL: URL, name: String = "新資料夾") throws -> URL {
        let fileManager = FileManager.default
        var folderName = name
        var targetURL = parentURL.appendingPathComponent(folderName)
        var counter = 2
        
        while fileManager.fileExists(atPath: targetURL.path) {
            folderName = "\(name) (\(counter))"
            targetURL = parentURL.appendingPathComponent(folderName)
            counter += 1
        }
        
        try fileManager.createDirectory(at: targetURL, withIntermediateDirectories: false)
        return targetURL
    }
    
    /// Create new file (e.g. text document).
    public func createFile(in parentURL: URL, name: String = "新增文字文件.txt", content: Data = Data()) throws -> URL {
        let fileManager = FileManager.default
        var fileName = name
        var targetURL = parentURL.appendingPathComponent(fileName)
        var counter = 2
        
        let ext = (name as NSString).pathExtension
        let base = (name as NSString).deletingPathExtension
        
        while fileManager.fileExists(atPath: targetURL.path) {
            if ext.isEmpty {
                fileName = "\(base) (\(counter))"
            } else {
                fileName = "\(base) (\(counter)).\(ext)"
            }
            targetURL = parentURL.appendingPathComponent(fileName)
            counter += 1
        }
        
        fileManager.createFile(atPath: targetURL.path, contents: content)
        return targetURL
    }
    
    /// Rename file or folder.
    public func rename(itemURL: URL, newName: String) throws -> URL {
        let fileManager = FileManager.default
        let newURL = itemURL.deletingLastPathComponent().appendingPathComponent(newName)
        if newURL != itemURL {
            try fileManager.moveItem(at: itemURL, to: newURL)
        }
        return newURL
    }
    
    /// Move items to Trash or permanently delete.
    public func delete(items: [URL], moveToTrash: Bool = true) throws {
        let fileManager = FileManager.default
        for url in items {
            if moveToTrash {
                try fileManager.trashItem(at: url, resultingItemURL: nil)
            } else {
                try fileManager.removeItem(at: url)
            }
        }
    }
    
    /// Copy items to a directory.
    public func copy(items: [URL], to destinationDirectory: URL) throws {
        let fileManager = FileManager.default
        for url in items {
            var destURL = destinationDirectory.appendingPathComponent(url.lastPathComponent)
            var counter = 2
            let ext = url.pathExtension
            let base = (url.lastPathComponent as NSString).deletingPathExtension
            
            while fileManager.fileExists(atPath: destURL.path) {
                if ext.isEmpty {
                    destURL = destinationDirectory.appendingPathComponent("\(base) - 複製本 (\(counter))")
                } else {
                    destURL = destinationDirectory.appendingPathComponent("\(base) - 複製本 (\(counter)).\(ext)")
                }
                counter += 1
            }
            try fileManager.copyItem(at: url, to: destURL)
        }
    }
    
    /// Move items to a directory.
    public func move(items: [URL], to destinationDirectory: URL) throws {
        let fileManager = FileManager.default
        for url in items {
            let destURL = destinationDirectory.appendingPathComponent(url.lastPathComponent)
            try fileManager.moveItem(at: url, to: destURL)
        }
    }
    
    /// Duplicate items in the same folder.
    public func duplicate(items: [URL]) throws {
        for url in items {
            let parent = url.deletingLastPathComponent()
            try copy(items: [url], to: parent)
        }
    }
    
    /// Open in default app.
    @MainActor
    public func openFile(url: URL) {
        NSWorkspace.shared.open(url)
    }
    
    /// Reveal in Finder.
    @MainActor
    public func revealInFinder(url: URL) {
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
    
    /// Open in Terminal.
    @MainActor
    public func openInTerminal(url: URL) {
        let isDir = (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
        let dirURL = isDir ? url : url.deletingLastPathComponent()
        if let terminalAppURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.Terminal") {
            let config = NSWorkspace.OpenConfiguration()
            NSWorkspace.shared.open([dirURL], withApplicationAt: terminalAppURL, configuration: config)
        }
    }
}
