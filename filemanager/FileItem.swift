//
//  FileItem.swift
//  filemanager
//

import AppKit
import Foundation
import UniformTypeIdentifiers

/// Represents a single file or directory item in the file explorer.
public struct FileItem: Identifiable, Hashable, Sendable {
    public var id: URL { url }
    
    public let url: URL
    public let name: String
    public let extensionName: String
    public let isDirectory: Bool
    public let isPackage: Bool
    public let isSymlink: Bool
    public let isVolume: Bool
    public let isHidden: Bool
    public let fileSize: Int64
    public let creationDate: Date
    public let modificationDate: Date
    public let kindDescription: String
    public let permissionsString: String

    public init(url: URL) {
        self.url = url
        self.name = url.lastPathComponent
        self.extensionName = url.pathExtension.lowercased()
        
        let path = url.path
        let fileManager = FileManager.default
        
        var isDir: ObjCBool = false
        fileManager.fileExists(atPath: path, isDirectory: &isDir)
        self.isDirectory = isDir.boolValue
        self.isHidden = url.lastPathComponent.hasPrefix(".")
        
        var isPkg = false
        if let values = try? url.resourceValues(forKeys: [.isPackageKey, .isVolumeKey]),
           let pkg = values.isPackage {
            isPkg = pkg
        }
        self.isPackage = isPkg
        self.isVolume = (try? url.resourceValues(forKeys: [.isVolumeKey]).isVolume) ?? false
        
        var isSym = false
        if let attrs = try? fileManager.attributesOfItem(atPath: path),
           let fileType = attrs[.type] as? FileAttributeType {
            isSym = (fileType == .typeSymbolicLink)
        }
        self.isSymlink = isSym
        
        if let attrs = try? fileManager.attributesOfItem(atPath: path) {
            self.fileSize = (attrs[.size] as? Int64) ?? 0
            self.creationDate = (attrs[.creationDate] as? Date) ?? Date.distantPast
            self.modificationDate = (attrs[.modificationDate] as? Date) ?? Date.distantPast
            if let posixPerms = attrs[.posixPermissions] as? NSNumber {
                self.permissionsString = String(format: "%o", posixPerms.intValue)
            } else {
                self.permissionsString = ""
            }
        } else {
            self.fileSize = 0
            self.creationDate = Date.distantPast
            self.modificationDate = Date.distantPast
            self.permissionsString = ""
        }
        
        // Resolve localized kind description (e.g. "Folder", "PDF document")
        if self.isDirectory && !self.isPackage {
            self.kindDescription = LocalizationManager.shared.tr("folder")
        } else if let uttype = UTType(filenameExtension: url.pathExtension) {
            self.kindDescription = uttype.localizedDescription ?? uttype.preferredFilenameExtension?.uppercased() ?? LocalizationManager.shared.tr("file")
        } else {
            self.kindDescription = LocalizationManager.shared.tr("file")
        }
    }
    
    /// Formatted human-readable file size (e.g., "1.4 MB", "42 KB")
    public var formattedSize: String {
        if isDirectory && !isPackage {
            return ""
        }
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: fileSize)
    }
    
    /// Formatted modification date string in Windows style (e.g. 2026/10/10 11:42)
    public var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter.string(from: modificationDate)
    }
    
    /// Formatted creation date
    public var formattedCreationDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter.string(from: creationDate)
    }
    
    /// System icon for the file or directory
    @MainActor
    public var systemIcon: NSImage {
        NSWorkspace.shared.icon(forFile: url.path)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }
    
    public static func == (lhs: FileItem, rhs: FileItem) -> Bool {
        lhs.url == rhs.url
    }
}
