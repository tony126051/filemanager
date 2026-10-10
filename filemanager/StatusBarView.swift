//
//  StatusBarView.swift
//  filemanager
//

import SwiftUI

public struct StatusBarView: View {
    @ObservedObject var viewModel: ExplorerViewModel
    @ObservedObject var tab: TabModel
    @ObservedObject var lang = LocalizationManager.shared
    
    private var totalItemsCount: Int {
        tab.displayedItems.count
    }
    
    private var selectedItemsCount: Int {
        tab.selectedURLs.count
    }
    
    private var selectedItemsSizeText: String {
        let selectedFiles = tab.items.filter { tab.selectedURLs.contains($0.url) && !$0.isDirectory }
        let totalBytes = selectedFiles.reduce(Int64(0)) { $0 + $1.fileSize }
        guard totalBytes > 0 else { return "" }
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: totalBytes)
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            // Item count & selection
            HStack(spacing: 8) {
                Text(lang.tr("status_items_count", totalItemsCount))
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                
                if selectedItemsCount > 0 {
                    Divider().frame(height: 12)
                    
                    let sizeStr = selectedItemsSizeText
                    let selectionText = sizeStr.isEmpty
                        ? lang.tr("status_selected_count", selectedItemsCount)
                        : lang.tr("status_selected_with_size", selectedItemsCount, sizeStr)
                    
                    Text(selectionText)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }
            
            // Temporary status toast
            if let status = viewModel.statusMessage {
                Divider().frame(height: 12)
                Text(status)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Windows11Theme.accentColor)
                    .transition(.opacity)
            }
            
            Spacer()
            
            // View Mode Quick Switchers (Windows 11 bottom-right buttons)
            HStack(spacing: 2) {
                Button(action: { tab.viewMode = .details }) {
                    Image(systemName: "list.bullet.indent")
                        .font(.system(size: 11))
                        .foregroundColor(tab.viewMode == .details ? Windows11Theme.accentColor : .secondary)
                        .frame(width: 22, height: 20)
                        .background(tab.viewMode == .details ? Color.primary.opacity(0.08) : Color.clear)
                        .cornerRadius(3)
                }
                .buttonStyle(.plain)
                .help(lang.tr("view_details"))
                
                Button(action: { tab.viewMode = .largeIcons }) {
                    Image(systemName: "square.grid.2x2")
                        .font(.system(size: 11))
                        .foregroundColor(tab.viewMode == .largeIcons ? Windows11Theme.accentColor : .secondary)
                        .frame(width: 22, height: 20)
                        .background(tab.viewMode == .largeIcons ? Color.primary.opacity(0.08) : Color.clear)
                        .cornerRadius(3)
                }
                .buttonStyle(.plain)
                .help(lang.tr("view_large_icons"))
            }
        }
        .padding(.horizontal, 10)
        .frame(height: 24)
        .background(Color(NSColor.windowBackgroundColor))
        .overlay(Divider(), alignment: .top)
    }
}
