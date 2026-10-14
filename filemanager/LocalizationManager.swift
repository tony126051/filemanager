//
//  LocalizationManager.swift
//  filemanager
//

import AppKit
import Combine
import Foundation
import SwiftUI

/// Supported Application Languages
public enum AppLanguage: String, CaseIterable, Identifiable {
    case system = "system"
    case zhHant = "zh-Hant"
    case zhHans = "zh-Hans"
    case en = "en"
    case ja = "ja"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .system:
            return LocalizationManager.shared.tr("lang_system")
        case .zhHant:
            return "繁體中文 (Traditional Chinese)"
        case .zhHans:
            return "简体中文 (Simplified Chinese)"
        case .en:
            return "English"
        case .ja:
            return "日本語 (Japanese)"
        }
    }
    
    public var shortName: String {
        switch self {
        case .system: return "Auto"
        case .zhHant: return "繁中"
        case .zhHans: return "简中"
        case .en: return "EN"
        case .ja: return "日文"
        }
    }
}

/// Dynamic Localization Manager supporting runtime language switching.
@MainActor
public final class LocalizationManager: ObservableObject {
    public static let shared = LocalizationManager()
    
    private let userDefaultsKey = "preferred_app_language"
    
    @Published public var currentLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: userDefaultsKey)
        }
    }
    
    public init() {
        let saved = UserDefaults.standard.string(forKey: userDefaultsKey) ?? AppLanguage.system.rawValue
        self.currentLanguage = AppLanguage(rawValue: saved) ?? .system
    }
    
    /// The actual language being displayed after resolving `.system`.
    public var resolvedLanguage: AppLanguage {
        if currentLanguage != .system {
            return currentLanguage
        }
        
        // Inspect system preferred languages
        let preferred = Locale.preferredLanguages.first ?? "en"
        let lower = preferred.lowercased()
        if lower.starts(with: "zh-hant") || lower.starts(with: "zh-tw") || lower.starts(with: "zh-hk") {
            return .zhHant
        } else if lower.starts(with: "zh") {
            return .zhHans
        } else if lower.starts(with: "ja") {
            return .ja
        } else {
            return .en
        }
    }
    
    /// Translate a key into the active language with optional format arguments.
    public func tr(_ key: String, _ args: CVarArg...) -> String {
        let lang = resolvedLanguage
        let table = translations[lang] ?? translations[.en] ?? [:]
        let rawFormat = table[key] ?? translations[.zhHant]?[key] ?? translations[.en]?[key] ?? key
        
        if args.isEmpty {
            return rawFormat
        }
        return String(format: rawFormat, arguments: args)
    }
    
    /// Localized name for common user folders
    public func folderDisplayName(folderName: String) -> String {
        switch folderName.lowercased() {
        case "desktop": return tr("folder_desktop")
        case "documents": return tr("folder_documents")
        case "downloads": return tr("folder_downloads")
        case "pictures": return tr("folder_pictures")
        case "music": return tr("folder_music")
        case "movies": return tr("folder_movies")
        default: return folderName
        }
    }
    
    // MARK: - Translation Tables
    private let translations: [AppLanguage: [String: String]] = [
        // MARK: Traditional Chinese (繁體中文)
        .zhHant: [
            // General
            "app_name": "檔案總管",
            "ok": "確定",
            "cancel": "取消",
            "create": "建立",
            "yes": "是",
            "no": "否",
            "other": "其他",
            "none": "無",
            "bytes": "個位元組",
            "folder": "資料夾",
            "file": "檔案",
            "default_app": "系統預設應用程式",
            
            // Languages
            "language": "語言",
            "lang_system": "跟隨系統語言",
            
            // Tabs & Navigation
            "home": "首頁",
            "this_pc": "本機 (This PC)",
            "applications": "應用程式",
            "trash": "資源回收筒",
            "quick_access": "快速存取",
            "home_quick_access": "首頁 (快速存取)",
            "no_open_tabs": "沒有開啟的分頁",
            "new_tab": "新增分頁",
            "close_tab": "關閉分頁",
            
            // Standard Folders
            "folder_desktop": "桌面",
            "folder_documents": "文件",
            "folder_downloads": "下載",
            "folder_pictures": "圖片",
            "folder_music": "音樂",
            "folder_movies": "影片",
            
            // Address Bar
            "nav_back": "返回 (Cmd+[)",
            "nav_forward": "前進 (Cmd+])",
            "nav_up": "上一層 (Cmd+Up)",
            "nav_refresh": "重新整理 (Cmd+R)",
            "enter_path": "輸入路徑...",
            "search_placeholder": "搜尋 %@",
            
            // Command Bar
            "cmd_new": "新增",
            "cmd_new_folder": "資料夾",
            "cmd_new_txt": "文字文件 (.txt)",
            "cmd_new_md": "Markdown 文件 (.md)",
            "cmd_new_swift": "Swift 檔案 (.swift)",
            "cmd_cut": "剪下",
            "cmd_copy": "複製",
            "cmd_paste": "貼上",
            "cmd_rename": "重新命名",
            "cmd_share": "分享",
            "cmd_delete": "移至垃圾桶",
            "cmd_sort": "排序",
            "cmd_sort_by": "排序依據",
            "cmd_sort_order": "排序順序",
            "cmd_ascending": "遞增",
            "cmd_descending": "遞減",
            "cmd_view": "檢視",
            "cmd_view_mode": "檢視模式",
            "cmd_show": "顯示",
            "cmd_show_hidden": "隱藏項目 (Hidden Files)",
            "cmd_show_preview": "預覽窗格 (Preview)",
            "cmd_show_details": "詳細資料窗格 (Details)",
            "cmd_open_terminal": "在終端機中開啟",
            "cmd_properties": "內容 (Properties)",
            
            // View Modes
            "view_details": "詳細資料",
            "view_large_icons": "大圖示",
            "view_medium_icons": "中圖示",
            "view_small_icons": "小圖示",
            "view_list": "清單",
            "view_tiles": "並排",
            
            // Sort Fields / Columns
            "sort_name": "名稱",
            "sort_date_modified": "修改日期",
            "sort_type": "類型",
            "sort_size": "大小",
            
            // Context Menu
            "menu_open": "開啟",
            "menu_open_in_new_tab": "在新增分頁中開啟",
            "menu_pin_quick_access": "釘選到快速存取",
            "menu_unpin_quick_access": "從快速存取取消釘選",
            "menu_reveal_in_finder": "在 Finder 中顯示",
            "menu_copy_path": "複製路徑",
            "menu_copy_paths": "複製所有路徑",
            "menu_path_copied": "已複製路徑",
            "menu_duplicate": "製作複本",
            "select_all": "全選",
            "select_none": "取消全選",
            "invert_selection": "反向選取",
            "item_checkboxes": "項目核取方塊",
            "menu_open_count": "開啟 %d 個項目",
            "menu_cut_count": "剪下 %d 個項目",
            "menu_copy_count": "複製 %d 個項目",
            "menu_delete_count": "移至垃圾桶 (%d 個項目)",
            "menu_duplicate_count": "製作複本 (%d 個項目)",
            "menu_share_count": "分享 %d 個項目",
            "menu_properties_count": "內容 (%d 個項目)",
            
            // Status Bar
            "status_items_count": "%d 個項目",
            "status_selected_count": "已選取 %d 個項目",
            "status_selected_with_size": "已選取 %d 個項目 %@",
            
            // Volumes
            "volume_free_description": "%@ 可用，共 %@",
            
            // Dialogs
            "dialog_new_folder_title": "新建資料夾",
            "dialog_new_folder_placeholder": "資料夾名稱",
            "dialog_new_folder_default": "新資料夾",
            "dialog_rename_title": "重新命名",
            "dialog_rename_placeholder": "名稱",
            
            // Properties Dialog
            "prop_title": "%@ 內容",
            "prop_tab_general": "一般",
            "prop_tab_security": "安全性與權限",
            "prop_file_type": "檔案類型:",
            "prop_opens_with": "開啟方式:",
            "prop_location": "位置:",
            "prop_size": "大小:",
            "prop_created": "建立時間:",
            "prop_modified": "修改時間:",
            "prop_attributes": "屬性:",
            "prop_hidden": "隱藏項目",
            "prop_readonly": "唯讀",
            "prop_object_name": "物件名稱: %@",
            "prop_posix_permissions": "權限資訊 (POSIX):",
            "prop_octal_code": "八進位權限碼:",
            "prop_readable": "可讀取:",
            "prop_writable": "可寫入:",
            "prop_executable": "可執行:",
            "prop_advanced_note": "若要變更進階存取權限，請透過系統設定或終端機 (chmod / chown)。",
            
            // Preview Pane
            "preview_title": "預覽",
            "details_title": "詳細資料",
            "preview_placeholder": "選取項目以檢視其預覽或詳細資料",
            "preview_unavailable": "無法預覽此檔案",
            
            // About & Updates
            "about_filemanager": "關於檔案總管",
            "about_app_name": "Windows 11 檔案總管 (macOS 版)",
            "about_version": "版本",
            "about_build": "內部版本",
            "about_author": "開發者",
            "about_github": "GitHub 專案庫",
            "about_updates": "軟體更新",
            "update_check": "檢查更新",
            "update_recheck": "重新檢查",
            "update_checking": "正在檢查更新...",
            "update_up_to_date": "您使用的已是最新版本",
            "update_available": "發現新版本：%@",
            "update_download": "前往下載更新",
            "update_view_release": "查看 GitHub Release",
            "update_failed": "檢查更新失敗：%@",
            "update_idle_hint": "點擊下方按鈕以檢查 GitHub 最新版本。"
        ],
        
        // MARK: Simplified Chinese (简体中文)
        .zhHans: [
            // General
            "app_name": "文件资源管理器",
            "ok": "确定",
            "cancel": "取消",
            "create": "创建",
            "yes": "是",
            "no": "否",
            "other": "其他",
            "none": "无",
            "bytes": "字节",
            "folder": "文件夹",
            "file": "文件",
            "default_app": "系统默认应用程序",
            
            // Languages
            "language": "语言",
            "lang_system": "跟随系统语言",
            
            // Tabs & Navigation
            "home": "主页",
            "this_pc": "此电脑 (This PC)",
            "applications": "应用程序",
            "trash": "回收站",
            "quick_access": "快速访问",
            "home_quick_access": "主页 (快速访问)",
            "no_open_tabs": "没有打开的标签页",
            "new_tab": "新建标签页",
            "close_tab": "关闭标签页",
            
            // Standard Folders
            "folder_desktop": "桌面",
            "folder_documents": "文档",
            "folder_downloads": "下载",
            "folder_pictures": "图片",
            "folder_music": "音乐",
            "folder_movies": "视频",
            
            // Address Bar
            "nav_back": "后退 (Cmd+[)",
            "nav_forward": "前进 (Cmd+])",
            "nav_up": "上一级 (Cmd+Up)",
            "nav_refresh": "刷新 (Cmd+R)",
            "enter_path": "输入路径...",
            "search_placeholder": "搜索 %@",
            
            // Command Bar
            "cmd_new": "新建",
            "cmd_new_folder": "文件夹",
            "cmd_new_txt": "文本文档 (.txt)",
            "cmd_new_md": "Markdown 文档 (.md)",
            "cmd_new_swift": "Swift 源文件 (.swift)",
            "cmd_cut": "剪切",
            "cmd_copy": "复制",
            "cmd_paste": "粘贴",
            "cmd_rename": "重命名",
            "cmd_share": "共享",
            "cmd_delete": "移到废纸篓",
            "cmd_sort": "排序",
            "cmd_sort_by": "排序依据",
            "cmd_sort_order": "排序顺序",
            "cmd_ascending": "递增",
            "cmd_descending": "递减",
            "cmd_view": "查看",
            "cmd_view_mode": "查看模式",
            "cmd_show": "显示",
            "cmd_show_hidden": "隐藏项目 (Hidden Files)",
            "cmd_show_preview": "预览窗格 (Preview)",
            "cmd_show_details": "详细信息窗格 (Details)",
            "cmd_open_terminal": "在终端中打开",
            "cmd_properties": "属性 (Properties)",
            
            // View Modes
            "view_details": "详细信息",
            "view_large_icons": "大图标",
            "view_medium_icons": "中等图标",
            "view_small_icons": "小图标",
            "view_list": "列表",
            "view_tiles": "平铺",
            
            // Sort Fields / Columns
            "sort_name": "名称",
            "sort_date_modified": "修改日期",
            "sort_type": "类型",
            "sort_size": "大小",
            
            // Context Menu
            "menu_open": "打开",
            "menu_open_in_new_tab": "在新标签页中打开",
            "menu_pin_quick_access": "固定到快速访问",
            "menu_unpin_quick_access": "从快速访问取消固定",
            "menu_reveal_in_finder": "在访达中显示",
            "menu_copy_path": "复制路径",
            "menu_copy_paths": "复制所有路径",
            "menu_path_copied": "已复制路径",
            "menu_duplicate": "创建副本",
            "select_all": "全选",
            "select_none": "取消全选",
            "invert_selection": "反向选择",
            "item_checkboxes": "项目复选框",
            "menu_open_count": "打开 %d 个项目",
            "menu_cut_count": "剪切 %d 个项目",
            "menu_copy_count": "复制 %d 个项目",
            "menu_delete_count": "移至回收站 (%d 个项目)",
            "menu_duplicate_count": "制作副本 (%d 个项目)",
            "menu_share_count": "共享 %d 个项目",
            "menu_properties_count": "属性 (%d 个项目)",
            
            // Status Bar
            "status_items_count": "%d 个项目",
            "status_selected_count": "已选择 %d 个项目",
            "status_selected_with_size": "已选择 %d 个项目 %@",
            
            // Volumes
            "volume_free_description": "%@ 可用，共 %@",
            
            // Dialogs
            "dialog_new_folder_title": "新建文件夹",
            "dialog_new_folder_placeholder": "文件夹名称",
            "dialog_new_folder_default": "新建文件夹",
            "dialog_rename_title": "重命名",
            "dialog_rename_placeholder": "名称",
            
            // Properties Dialog
            "prop_title": "%@ 属性",
            "prop_tab_general": "常规",
            "prop_tab_security": "安全与权限",
            "prop_file_type": "文件类型:",
            "prop_opens_with": "打开方式:",
            "prop_location": "位置:",
            "prop_size": "大小:",
            "prop_created": "创建时间:",
            "prop_modified": "修改时间:",
            "prop_attributes": "属性:",
            "prop_hidden": "隐藏项目",
            "prop_readonly": "只读",
            "prop_object_name": "对象名称: %@",
            "prop_posix_permissions": "权限信息 (POSIX):",
            "prop_octal_code": "八进制权限码:",
            "prop_readable": "可读:",
            "prop_writable": "可写:",
            "prop_executable": "可执行:",
            "prop_advanced_note": "如需更改高级访问权限，请使用系统设置或终端 (chmod / chown)。",
            
            // Preview Pane
            "preview_title": "预览",
            "details_title": "详细信息",
            "preview_placeholder": "选择项目以查看其预览或详细信息",
            "preview_unavailable": "无法预览此文件",
            
            // About & Updates
            "about_filemanager": "关于文件资源管理器",
            "about_app_name": "Windows 11 文件资源管理器 (macOS 版)",
            "about_version": "版本",
            "about_build": "内部版本",
            "about_author": "开发者",
            "about_github": "GitHub 仓库",
            "about_updates": "软件更新",
            "update_check": "检查更新",
            "update_recheck": "重新检查",
            "update_checking": "正在检查更新...",
            "update_up_to_date": "您使用的已是最新版本",
            "update_available": "发现新版本：%@",
            "update_download": "前往下载更新",
            "update_view_release": "查看 GitHub Release",
            "update_failed": "检查更新失败：%@",
            "update_idle_hint": "点击下方按钮以检查 GitHub 最新版本。"
        ],
        
        // MARK: English
        .en: [
            // General
            "app_name": "File Explorer",
            "ok": "OK",
            "cancel": "Cancel",
            "create": "Create",
            "yes": "Yes",
            "no": "No",
            "other": "Other",
            "none": "None",
            "bytes": "bytes",
            "folder": "Folder",
            "file": "File",
            "default_app": "System Default Application",
            
            // Languages
            "language": "Language",
            "lang_system": "System Default",
            
            // Tabs & Navigation
            "home": "Home",
            "this_pc": "This PC",
            "applications": "Applications",
            "trash": "Trash",
            "quick_access": "Quick Access",
            "home_quick_access": "Home (Quick Access)",
            "no_open_tabs": "No open tabs",
            "new_tab": "New Tab",
            "close_tab": "Close Tab",
            
            // Standard Folders
            "folder_desktop": "Desktop",
            "folder_documents": "Documents",
            "folder_downloads": "Downloads",
            "folder_pictures": "Pictures",
            "folder_music": "Music",
            "folder_movies": "Movies",
            
            // Address Bar
            "nav_back": "Back (Cmd+[)",
            "nav_forward": "Forward (Cmd+])",
            "nav_up": "Up (Cmd+Up)",
            "nav_refresh": "Refresh (Cmd+R)",
            "enter_path": "Enter path...",
            "search_placeholder": "Search %@",
            
            // Command Bar
            "cmd_new": "New",
            "cmd_new_folder": "Folder",
            "cmd_new_txt": "Text Document (.txt)",
            "cmd_new_md": "Markdown Document (.md)",
            "cmd_new_swift": "Swift File (.swift)",
            "cmd_cut": "Cut",
            "cmd_copy": "Copy",
            "cmd_paste": "Paste",
            "cmd_rename": "Rename",
            "cmd_share": "Share",
            "cmd_delete": "Move to Trash",
            "cmd_sort": "Sort",
            "cmd_sort_by": "Sort by",
            "cmd_sort_order": "Sort order",
            "cmd_ascending": "Ascending",
            "cmd_descending": "Descending",
            "cmd_view": "View",
            "cmd_view_mode": "View Mode",
            "cmd_show": "Show",
            "cmd_show_hidden": "Hidden items",
            "cmd_show_preview": "Preview pane",
            "cmd_show_details": "Details pane",
            "cmd_open_terminal": "Open in Terminal",
            "cmd_properties": "Properties",
            
            // View Modes
            "view_details": "Details",
            "view_large_icons": "Large icons",
            "view_medium_icons": "Medium icons",
            "view_small_icons": "Small icons",
            "view_list": "List",
            "view_tiles": "Tiles",
            
            // Sort Fields / Columns
            "sort_name": "Name",
            "sort_date_modified": "Date modified",
            "sort_type": "Type",
            "sort_size": "Size",
            
            // Context Menu
            "menu_open": "Open",
            "menu_open_in_new_tab": "Open in new tab",
            "menu_pin_quick_access": "Pin to Quick Access",
            "menu_unpin_quick_access": "Unpin from Quick Access",
            "menu_reveal_in_finder": "Reveal in Finder",
            "menu_copy_path": "Copy path",
            "menu_copy_paths": "Copy all paths",
            "menu_path_copied": "Path copied",
            "menu_duplicate": "Duplicate",
            "select_all": "Select all",
            "select_none": "Select none",
            "invert_selection": "Invert selection",
            "item_checkboxes": "Item check boxes",
            "menu_open_count": "Open %d items",
            "menu_cut_count": "Cut %d items",
            "menu_copy_count": "Copy %d items",
            "menu_delete_count": "Move %d items to Trash",
            "menu_duplicate_count": "Duplicate %d items",
            "menu_share_count": "Share %d items",
            "menu_properties_count": "Properties (%d items)",
            
            // Status Bar
            "status_items_count": "%d items",
            "status_selected_count": "%d items selected",
            "status_selected_with_size": "%d items selected %@",
            
            // Volumes
            "volume_free_description": "%@ free of %@",
            
            // Dialogs
            "dialog_new_folder_title": "New Folder",
            "dialog_new_folder_placeholder": "Folder Name",
            "dialog_new_folder_default": "New folder",
            "dialog_rename_title": "Rename",
            "dialog_rename_placeholder": "Name",
            
            // Properties Dialog
            "prop_title": "%@ Properties",
            "prop_tab_general": "General",
            "prop_tab_security": "Security & Permissions",
            "prop_file_type": "Type of file:",
            "prop_opens_with": "Opens with:",
            "prop_location": "Location:",
            "prop_size": "Size:",
            "prop_created": "Created:",
            "prop_modified": "Modified:",
            "prop_attributes": "Attributes:",
            "prop_hidden": "Hidden",
            "prop_readonly": "Read-only",
            "prop_object_name": "Object name: %@",
            "prop_posix_permissions": "Permissions (POSIX):",
            "prop_octal_code": "Octal code:",
            "prop_readable": "Readable:",
            "prop_writable": "Writable:",
            "prop_executable": "Executable:",
            "prop_advanced_note": "To change advanced access permissions, use System Settings or Terminal (chmod / chown).",
            
            // Preview Pane
            "preview_title": "Preview",
            "details_title": "Details",
            "preview_placeholder": "Select an item to view its preview or details",
            "preview_unavailable": "No preview available for this file",
            
            // About & Updates
            "about_filemanager": "About File Manager",
            "about_app_name": "Windows 11 File Manager for macOS",
            "about_version": "Version",
            "about_build": "Build",
            "about_author": "Developer",
            "about_github": "GitHub Repository",
            "about_updates": "Software Update",
            "update_check": "Check for Updates",
            "update_recheck": "Check Again",
            "update_checking": "Checking for updates...",
            "update_up_to_date": "You're up to date",
            "update_available": "New version available: %@",
            "update_download": "Download Update",
            "update_view_release": "View on GitHub",
            "update_failed": "Failed to check for updates: %@",
            "update_idle_hint": "Click the button below to check for GitHub updates."
        ],
        
        // MARK: Japanese (日本語)
        .ja: [
            // General
            "app_name": "ファイル エクスプローラー",
            "ok": "OK",
            "cancel": "キャンセル",
            "create": "作成",
            "yes": "はい",
            "no": "いいえ",
            "other": "その他",
            "none": "なし",
            "bytes": "バイト",
            "folder": "フォルダー",
            "file": "ファイル",
            "default_app": "システムの既定のアプリ",
            
            // Languages
            "language": "言語",
            "lang_system": "システムの既定",
            
            // Tabs & Navigation
            "home": "ホーム",
            "this_pc": "この PC (This PC)",
            "applications": "アプリケーション",
            "trash": "ごみ箱",
            "quick_access": "クイック アクセス",
            "home_quick_access": "ホーム (クイック アクセス)",
            "no_open_tabs": "開いているタブはありません",
            "new_tab": "新しいタブ",
            "close_tab": "タブを閉じる",
            
            // Standard Folders
            "folder_desktop": "デスクトップ",
            "folder_documents": "ドキュメント",
            "folder_downloads": "ダウンロード",
            "folder_pictures": "ピクチャ",
            "folder_music": "ミュージック",
            "folder_movies": "ビデオ",
            
            // Address Bar
            "nav_back": "戻る (Cmd+[)",
            "nav_forward": "進む (Cmd+])",
            "nav_up": "上の階層へ (Cmd+Up)",
            "nav_refresh": "最新の情報に更新 (Cmd+R)",
            "enter_path": "パスを入力...",
            "search_placeholder": "%@ を検索",
            
            // Command Bar
            "cmd_new": "新規作成",
            "cmd_new_folder": "フォルダー",
            "cmd_new_txt": "テキスト ドキュメント (.txt)",
            "cmd_new_md": "Markdown ドキュメント (.md)",
            "cmd_new_swift": "Swift ソース ファイル (.swift)",
            "cmd_cut": "切り取り",
            "cmd_copy": "コピー",
            "cmd_paste": "貼り付け",
            "cmd_rename": "名前の変更",
            "cmd_share": "共有",
            "cmd_delete": "ごみ箱に移動",
            "cmd_sort": "並べ替え",
            "cmd_sort_by": "並べ替えの基準",
            "cmd_sort_order": "並べ替えの順序",
            "cmd_ascending": "昇順",
            "cmd_descending": "降順",
            "cmd_view": "表示",
            "cmd_view_mode": "表示モード",
            "cmd_show": "表示設定",
            "cmd_show_hidden": "隠しファイル (Hidden Files)",
            "cmd_show_preview": "プレビュー ウィンドウ",
            "cmd_show_details": "詳細ウィンドウ",
            "cmd_open_terminal": "ターミナルで開く",
            "cmd_properties": "プロパティ (Properties)",
            
            // View Modes
            "view_details": "詳細",
            "view_large_icons": "大アイコン",
            "view_medium_icons": "中アイコン",
            "view_small_icons": "小アイコン",
            "view_list": "一覧",
            "view_tiles": "並べて表示",
            
            // Sort Fields / Columns
            "sort_name": "名前",
            "sort_date_modified": "更新日時",
            "sort_type": "種類",
            "sort_size": "サイズ",
            
            // Context Menu
            "menu_open": "開く",
            "menu_open_in_new_tab": "新しいタブで開く",
            "menu_pin_quick_access": "クイック アクセスにピン留め",
            "menu_unpin_quick_access": "クイック アクセスからピン留めを解除",
            "menu_reveal_in_finder": "Finder で表示",
            "menu_copy_path": "パスのコピー",
            "menu_copy_paths": "すべてのパスをコピー",
            "menu_path_copied": "パスをコピーしました",
            "menu_duplicate": "複製を作成",
            "select_all": "すべて選択",
            "select_none": "選択を解除",
            "invert_selection": "選択を反転",
            "item_checkboxes": "項目のチェック ボックス",
            "menu_open_count": "%d 個の項目を開く",
            "menu_cut_count": "%d 個の項目を切り取り",
            "menu_copy_count": "%d 個の項目をコピー",
            "menu_delete_count": "%d 個の項目をゴミ箱に移動",
            "menu_duplicate_count": "%d 個の項目の複製を作成",
            "menu_share_count": "%d 個の項目を共有",
            "menu_properties_count": "プロパティ (%d 個の項目)",
            
            // Status Bar
            "status_items_count": "%d 個の項目",
            "status_selected_count": "%d 個の項目を選択",
            "status_selected_with_size": "%d 個の項目を選択 %@",
            
            // Volumes
            "volume_free_description": "%@ 空き、合計 %@",
            
            // Dialogs
            "dialog_new_folder_title": "新しいフォルダー",
            "dialog_new_folder_placeholder": "フォルダー名",
            "dialog_new_folder_default": "新しいフォルダー",
            "dialog_rename_title": "名前の変更",
            "dialog_rename_placeholder": "名前",
            
            // Properties Dialog
            "prop_title": "%@ のプロパティ",
            "prop_tab_general": "全般",
            "prop_tab_security": "セキュリティとアクセス権",
            "prop_file_type": "ファイルの種類:",
            "prop_opens_with": "プログラム:",
            "prop_location": "場所:",
            "prop_size": "サイズ:",
            "prop_created": "作成日時:",
            "prop_modified": "更新日時:",
            "prop_attributes": "属性:",
            "prop_hidden": "隠しファイル",
            "prop_readonly": "読み取り専用",
            "prop_object_name": "オブジェクト名: %@",
            "prop_posix_permissions": "アクセス権 (POSIX):",
            "prop_octal_code": "8進数アクセス権:",
            "prop_readable": "読み取り可能:",
            "prop_writable": "書き込み可能:",
            "prop_executable": "実行可能:",
            "prop_advanced_note": "詳細なアクセス権を変更するには、システム設定またはターミナル (chmod / chown) を使用してください。",
            
            // Preview Pane
            "preview_title": "プレビュー",
            "details_title": "詳細",
            "preview_placeholder": "項目を選択するとプレビューまたは詳細が表示されます",
            "preview_unavailable": "このファイルのプレビューは利用できません",
            
            // About & Updates
            "about_filemanager": "ファイルマネージャーについて",
            "about_app_name": "Windows 11 ファイルマネージャー (macOS 版)",
            "about_version": "バージョン",
            "about_build": "ビルド",
            "about_author": "開発者",
            "about_github": "GitHub リポジトリ",
            "about_updates": "ソフトウェアの更新",
            "update_check": "アップデートを確認",
            "update_recheck": "再確認",
            "update_checking": "アップデートを確認中...",
            "update_up_to_date": "最新バージョンです",
            "update_available": "新しいバージョンがあります: %@",
            "update_download": "アップデートをダウンロード",
            "update_view_release": "GitHub で確認",
            "update_failed": "アップデートの確認に失敗しました: %@",
            "update_idle_hint": "下のボタンをクリックして GitHub の最新情報を確認します。"
        ]
    ]
}

/// Convenience global translation helper
@MainActor
public func tr(_ key: String, _ args: CVarArg...) -> String {
    LocalizationManager.shared.tr(key, args)
}
