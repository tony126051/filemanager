//
//  AddressBarView.swift
//  filemanager
//

import AppKit
import SwiftUI

public struct AddressBarView: View {
    @ObservedObject var viewModel: ExplorerViewModel
    @ObservedObject var tab: TabModel
    @ObservedObject var lang = LocalizationManager.shared
    
    @State private var isEditingPath = false
    @State private var editPathString = ""
    @FocusState private var isPathFieldFocused: Bool
    
    public var body: some View {
        HStack(spacing: 6) {
            // Navigation History Buttons
            HStack(spacing: 2) {
                Button(action: { tab.goBack() }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 13, weight: .semibold))
                        .frame(width: 28, height: 28)
                        .foregroundColor(tab.canGoBack ? .primary : .secondary.opacity(0.4))
                }
                .buttonStyle(.plain)
                .disabled(!tab.canGoBack)
                .help(lang.tr("nav_back"))
                
                Button(action: { tab.goForward() }) {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 13, weight: .semibold))
                        .frame(width: 28, height: 28)
                        .foregroundColor(tab.canGoForward ? .primary : .secondary.opacity(0.4))
                }
                .buttonStyle(.plain)
                .disabled(!tab.canGoForward)
                .help(lang.tr("nav_forward"))
                
                Button(action: { tab.goUp() }) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 13, weight: .semibold))
                        .frame(width: 28, height: 28)
                        .foregroundColor(tab.canGoUp ? .primary : .secondary.opacity(0.4))
                }
                .buttonStyle(.plain)
                .disabled(!tab.canGoUp)
                .help(lang.tr("nav_up"))
                
                Button(action: { tab.refresh(showHidden: viewModel.showHiddenFiles) }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 12, weight: .semibold))
                        .frame(width: 28, height: 28)
                        .foregroundColor(.primary)
                }
                .buttonStyle(.plain)
                .help(lang.tr("nav_refresh"))
            }
            
            // Win11 Breadcrumb / Path Address Box
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(NSColor.controlBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.primary.opacity(0.12), lineWidth: 1)
                    )
                
                if isEditingPath {
                    HStack {
                        Image(nsImage: tab.icon)
                            .resizable()
                            .frame(width: 16, height: 16)
                            .padding(.leading, 8)
                        
                        TextField(lang.tr("enter_path"), text: $editPathString)
                            .textFieldStyle(.plain)
                            .font(.system(size: 12))
                            .focused($isPathFieldFocused)
                            .onSubmit {
                                commitPathEdit()
                            }
                            .onExitCommand {
                                isEditingPath = false
                            }
                        
                        Button(action: { commitPathEdit() }) {
                            Image(systemName: "arrow.forward.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(Windows11Theme.accentColor)
                        }
                        .buttonStyle(.plain)
                        .padding(.trailing, 8)
                    }
                } else {
                    HStack(spacing: 2) {
                        Image(nsImage: tab.icon)
                            .resizable()
                            .frame(width: 16, height: 16)
                            .padding(.leading, 8)
                        
                        // Breadcrumbs
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 2) {
                                ForEach(breadcrumbs, id: \.url) { crumb in
                                    HStack(spacing: 2) {
                                        Button(action: {
                                            tab.navigateTo(url: crumb.url)
                                        }) {
                                            Text(crumb.name)
                                                .font(.system(size: 12))
                                                .padding(.horizontal, 4)
                                                .padding(.vertical, 3)
                                                .background(Color.primary.opacity(0.001))
                                                .cornerRadius(4)
                                        }
                                        .buttonStyle(.plain)
                                        
                                        if crumb.url != tab.currentURL {
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 9, weight: .bold))
                                                .foregroundColor(.secondary.opacity(0.6))
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                        
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        editPathString = tab.currentURL.path
                        isEditingPath = true
                        isPathFieldFocused = true
                    }
                }
            }
            .frame(height: 30)
            
            // Search Box (Windows 11 style)
            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .padding(.leading, 8)
                
                TextField(lang.tr("search_placeholder", tab.title), text: $tab.searchQuery)
                    .textFieldStyle(.plain)
                    .font(.system(size: 12))
                
                if !tab.searchQuery.isEmpty {
                    Button(action: {
                        tab.searchQuery = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, 6)
                }
            }
            .frame(width: 220, height: 30)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.primary.opacity(0.12), lineWidth: 1)
            )
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    private struct BreadcrumbItem {
        let name: String
        let url: URL
    }
    
    private var breadcrumbs: [BreadcrumbItem] {
        var items: [BreadcrumbItem] = []
        var cur = tab.currentURL
        
        while true {
            let name: String
            if cur.path == FileManager.default.homeDirectoryForCurrentUser.path {
                name = lang.tr("home")
            } else if cur.path == "/" {
                name = lang.tr("this_pc")
            } else if cur.lastPathComponent.isEmpty {
                name = lang.tr("this_pc")
            } else {
                name = lang.folderDisplayName(folderName: cur.lastPathComponent)
            }
            
            items.insert(BreadcrumbItem(name: name, url: cur), at: 0)
            let parent = cur.deletingLastPathComponent()
            if parent == cur || cur.path == "/" {
                break
            }
            cur = parent
        }
        return items
    }
    
    private func commitPathEdit() {
        var cleaned = editPathString.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.hasPrefix("~") {
            cleaned = (cleaned as NSString).expandingTildeInPath
        }
        let url = URL(fileURLWithPath: cleaned)
        if FileManager.default.fileExists(atPath: url.path) {
            tab.navigateTo(url: url)
        } else {
            viewModel.showStatus("Path not found: \(cleaned)")
        }
        isEditingPath = false
    }
}
