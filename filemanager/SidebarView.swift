//
//  SidebarView.swift
//  filemanager
//

import AppKit
import SwiftUI

public struct SidebarView: View {
    @ObservedObject var viewModel: ExplorerViewModel
    @ObservedObject var tab: TabModel
    @ObservedObject var lang = LocalizationManager.shared
    
    public var body: some View {
        List {
            // Section 1: Home / Quick Access (首頁 / 快速存取)
            Section(header: Text(lang.tr("home_quick_access")).font(.system(size: 11, weight: .bold)).foregroundColor(.secondary)) {
                SidebarRowItem(
                    title: lang.tr("home"),
                    icon: "house.fill",
                    color: .blue,
                    isSelected: tab.currentURL.path == FileManager.default.homeDirectoryForCurrentUser.path,
                    onTap: {
                        tab.navigateTo(url: FileManager.default.homeDirectoryForCurrentUser)
                    }
                )
                
                ForEach(viewModel.pinnedFolders, id: \.self) { url in
                    SidebarRowItem(
                        title: folderDisplayName(url: url),
                        icon: folderIconName(url: url),
                        color: folderColor(url: url),
                        isSelected: tab.currentURL.path == url.path,
                        trailingIcon: "pin.fill",
                        onTap: {
                            tab.navigateTo(url: url)
                        },
                        contextMenu: {
                            Button(lang.tr("menu_open_in_new_tab")) {
                                viewModel.addNewTab(url: url)
                            }
                            Button(lang.tr("menu_unpin_quick_access")) {
                                viewModel.togglePin(folderURL: url)
                            }
                            Divider()
                            Button(lang.tr("menu_reveal_in_finder")) {
                                FileSystemManager.shared.revealInFinder(url: url)
                            }
                        }
                    )
                }
            }
            
            // Section 2: This PC / 本機 (電腦磁碟)
            Section(header: Text(lang.tr("this_pc")).font(.system(size: 11, weight: .bold)).foregroundColor(.secondary)) {
                // System Applications folder
                let appsURL = URL(fileURLWithPath: "/Applications")
                SidebarRowItem(
                    title: lang.tr("applications"),
                    icon: "app.badge.fill",
                    color: .blue,
                    isSelected: tab.currentURL.path == appsURL.path,
                    onTap: {
                        tab.navigateTo(url: appsURL)
                    }
                )
                
                // Disks & Mounted Volumes with storage bar
                ForEach(viewModel.mountedVolumes) { volume in
                    VStack(alignment: .leading, spacing: 4) {
                        SidebarRowItem(
                            title: volume.name,
                            icon: volume.isRoot ? "internaldrive.fill" : "externaldrive.fill",
                            color: volume.isRoot ? .indigo : .teal,
                            isSelected: tab.currentURL.path == volume.url.path,
                            onTap: {
                                tab.navigateTo(url: volume.url)
                            },
                            contextMenu: {
                                Button(lang.tr("menu_open_in_new_tab")) {
                                    viewModel.addNewTab(url: volume.url)
                                }
                                Button(lang.tr("cmd_properties")) {
                                    viewModel.showProperties(for: FileItem(url: volume.url))
                                }
                            }
                        )
                        
                        // Storage capacity meter (Win11 disk bar style)
                        if volume.totalBytes > 0 {
                            VStack(alignment: .leading, spacing: 2) {
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(Color.primary.opacity(0.1))
                                            .frame(height: 4)
                                        
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(volume.freePercentage < 0.1 ? Color.red : Windows11Theme.accentColor)
                                            .frame(width: geo.size.width * max(0.02, (1.0 - volume.freePercentage)), height: 4)
                                    }
                                }
                                .frame(height: 4)
                                
                                Text(volume.formattedDescription)
                                    .font(.system(size: 9))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.leading, 26)
                            .padding(.bottom, 4)
                        }
                    }
                }
            }
            
            // Section 3: Trash (資源回收筒)
            Section(header: Text(lang.tr("other")).font(.system(size: 11, weight: .bold)).foregroundColor(.secondary)) {
                let trashURL = URL(fileURLWithPath: (NSHomeDirectory() as NSString).appendingPathComponent(".Trash"))
                SidebarRowItem(
                    title: lang.tr("trash"),
                    icon: "trash.fill",
                    color: .gray,
                    isSelected: tab.currentURL.path == trashURL.path,
                    onTap: {
                        tab.navigateTo(url: trashURL)
                    }
                )
            }
        }
        .listStyle(.sidebar)
        .frame(minWidth: 190, idealWidth: 230, maxWidth: 300)
    }
    
    private func folderDisplayName(url: URL) -> String {
        lang.folderDisplayName(folderName: url.lastPathComponent)
    }
    
    private func folderIconName(url: URL) -> String {
        switch url.lastPathComponent.lowercased() {
        case "desktop": return "display"
        case "documents": return "doc.fill"
        case "downloads": return "arrow.down.circle.fill"
        case "pictures": return "photo.fill"
        case "music": return "music.note"
        case "movies": return "film.fill"
        default: return "folder.fill"
        }
    }
    
    private func folderColor(url: URL) -> Color {
        switch url.lastPathComponent.lowercased() {
        case "desktop": return .blue
        case "documents": return .orange
        case "downloads": return .green
        case "pictures": return .purple
        case "music": return .pink
        case "movies": return .red
        default: return .yellow
        }
    }
}

private struct SidebarRowItem<MenuContent: View>: View {
    let title: String
    let icon: String
    let color: Color
    let isSelected: Bool
    var trailingIcon: String?
    let onTap: () -> Void
    let contextMenu: () -> MenuContent
    
    init(
        title: String,
        icon: String,
        color: Color,
        isSelected: Bool,
        trailingIcon: String? = nil,
        onTap: @escaping () -> Void,
        @ViewBuilder contextMenu: @escaping () -> MenuContent
    ) {
        self.title = title
        self.icon = icon
        self.color = color
        self.isSelected = isSelected
        self.trailingIcon = trailingIcon
        self.onTap = onTap
        self.contextMenu = contextMenu
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundColor(color)
                .frame(width: 18)
            
            Text(title)
                .font(.system(size: 12))
                .lineLimit(1)
            
            Spacer()
            
            if let trailingIcon = trailingIcon {
                Image(systemName: trailingIcon)
                    .font(.system(size: 9))
                    .foregroundColor(.secondary.opacity(0.5))
            }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 6)
        .background(isSelected ? Windows11Theme.selectedBackground : Color.clear)
        .cornerRadius(Windows11Theme.buttonCornerRadius)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
        .contextMenu {
            contextMenu()
        }
    }
}

extension SidebarRowItem where MenuContent == EmptyView {
    init(
        title: String,
        icon: String,
        color: Color,
        isSelected: Bool,
        trailingIcon: String? = nil,
        onTap: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.color = color
        self.isSelected = isSelected
        self.trailingIcon = trailingIcon
        self.onTap = onTap
        self.contextMenu = { EmptyView() }
    }
}
