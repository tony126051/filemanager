//
//  Windows11Theme.swift
//  filemanager
//

import SwiftUI

public enum ViewMode: String, CaseIterable, Identifiable, Sendable {
    case details = "details"
    case largeIcons = "largeIcons"
    case mediumIcons = "mediumIcons"
    case smallIcons = "smallIcons"
    case list = "list"
    case tiles = "tiles"
    
    public var id: String { rawValue }
    
    @MainActor
    public var localizedTitle: String {
        switch self {
        case .details: return LocalizationManager.shared.tr("view_details")
        case .largeIcons: return LocalizationManager.shared.tr("view_large_icons")
        case .mediumIcons: return LocalizationManager.shared.tr("view_medium_icons")
        case .smallIcons: return LocalizationManager.shared.tr("view_small_icons")
        case .list: return LocalizationManager.shared.tr("view_list")
        case .tiles: return LocalizationManager.shared.tr("view_tiles")
        }
    }
    
    public var iconName: String {
        switch self {
        case .details: return "list.bullet.indent"
        case .largeIcons: return "square.grid.2x2"
        case .mediumIcons: return "square.grid.3x3"
        case .smallIcons: return "square.grid.4x3.fill"
        case .list: return "list.dash"
        case .tiles: return "rectangle.split.2x1"
        }
    }
}

public enum SortField: String, CaseIterable, Identifiable, Sendable {
    case name = "name"
    case dateModified = "dateModified"
    case type = "type"
    case size = "size"
    
    public var id: String { rawValue }
    
    @MainActor
    public var localizedTitle: String {
        switch self {
        case .name: return LocalizationManager.shared.tr("sort_name")
        case .dateModified: return LocalizationManager.shared.tr("sort_date_modified")
        case .type: return LocalizationManager.shared.tr("sort_type")
        case .size: return LocalizationManager.shared.tr("sort_size")
        }
    }
}

public enum RightPaneMode: String, CaseIterable, Sendable {
    case none
    case preview = "preview"
    case details = "details"
    
    @MainActor
    public var localizedTitle: String {
        switch self {
        case .none: return ""
        case .preview: return LocalizationManager.shared.tr("cmd_show_preview")
        case .details: return LocalizationManager.shared.tr("cmd_show_details")
        }
    }
}

public struct Windows11Theme {
    // Windows 11 Fluent Accent Blue
    public static let accentColor = Color(red: 0.0, green: 0.47, blue: 0.84) // #0078D4
    public static let hoverBackground = Color.primary.opacity(0.06)
    public static let selectedBackground = Color(red: 0.0, green: 0.47, blue: 0.84).opacity(0.18)
    public static let subtleBorder = Color.primary.opacity(0.09)
    public static let toolbarBackground = Color(NSColor.windowBackgroundColor)
    public static let sidebarBackground = Color(NSColor.controlBackgroundColor).opacity(0.7)
    public static let statusBackground = Color(NSColor.windowBackgroundColor)
    
    public static let cardCornerRadius: CGFloat = 6
    public static let buttonCornerRadius: CGFloat = 5
}
