//
//  DetailsView.swift
//  filemanager
//

import AppKit
import SwiftUI

public struct DetailsView: View {
    @ObservedObject var viewModel: ExplorerViewModel
    @ObservedObject var tab: TabModel
    @ObservedObject var lang = LocalizationManager.shared
    let items: [FileItem]
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header Row (Windows 11 Details Header)
            HStack(spacing: 0) {
                // Select All Checkbox Column
                Button(action: {
                    if !items.isEmpty && tab.selectedURLs.count == items.count {
                        tab.deselectAll()
                    } else {
                        tab.selectAll()
                    }
                }) {
                    Image(systemName: items.isEmpty || tab.selectedURLs.isEmpty ? "square" : (tab.selectedURLs.count == items.count ? "checkmark.square.fill" : "minus.square.fill"))
                        .font(.system(size: 13))
                        .foregroundColor(tab.selectedURLs.isEmpty ? .secondary.opacity(0.6) : Windows11Theme.accentColor)
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
                .padding(.leading, 6)
                .help(lang.tr("select_all"))
                
                // Name column
                HeaderColumn(title: lang.tr("sort_name"), field: .name, currentSort: tab.sortField, ascending: tab.sortAscending) {
                    toggleSort(.name)
                }
                .frame(minWidth: 200, maxWidth: .infinity, alignment: .leading)
                
                Divider().frame(height: 16)
                
                // Date Modified column
                HeaderColumn(title: lang.tr("sort_date_modified"), field: .dateModified, currentSort: tab.sortField, ascending: tab.sortAscending) {
                    toggleSort(.dateModified)
                }
                .frame(width: 150, alignment: .leading)
                
                Divider().frame(height: 16)
                
                // Type column
                HeaderColumn(title: lang.tr("sort_type"), field: .type, currentSort: tab.sortField, ascending: tab.sortAscending) {
                    toggleSort(.type)
                }
                .frame(width: 140, alignment: .leading)
                
                Divider().frame(height: 16)
                
                // Size column
                HeaderColumn(title: lang.tr("sort_size"), field: .size, currentSort: tab.sortField, ascending: tab.sortAscending) {
                    toggleSort(.size)
                }
                .frame(width: 90, alignment: .trailing)
            }
            .padding(.horizontal, 4)
            .frame(height: 28)
            .background(Color(NSColor.controlBackgroundColor))
            .overlay(Divider(), alignment: .bottom)
            
            // List Items
            ScrollView {
                LazyVStack(spacing: 1) {
                    ForEach(items) { item in
                        DetailsRowView(
                            item: item,
                            isSelected: tab.selectedURLs.contains(item.url),
                            onDoubleClick: {
                                handleDoubleClick(item: item)
                            },
                            viewModel: viewModel,
                            tab: tab
                        )
                    }
                    
                    // Clickable empty area below items
                    Color.clear
                        .frame(maxWidth: .infinity, minHeight: 300)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            tab.deselectAll()
                        }
                }
                .padding(.vertical, 2)
            }
            .contextMenu {
                EmptyAreaContextMenu(viewModel: viewModel, tab: tab)
            }
        }
        .background(Color(NSColor.controlBackgroundColor).opacity(0.3))
    }
    
    private func toggleSort(_ field: SortField) {
        if tab.sortField == field {
            tab.sortAscending.toggle()
        } else {
            tab.sortField = field
            tab.sortAscending = true
        }
        tab.refresh(showHidden: viewModel.showHiddenFiles)
    }
    
    private func handleDoubleClick(item: FileItem) {
        if item.isDirectory && !item.isPackage {
            tab.navigateTo(url: item.url)
        } else {
            FileSystemManager.shared.openFile(url: item.url)
        }
    }
}

private struct HeaderColumn: View {
    let title: String
    let field: SortField
    let currentSort: SortField
    let ascending: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                
                if currentSort == field {
                    Image(systemName: ascending ? "chevron.up" : "chevron.down")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(Windows11Theme.accentColor)
                }
                Spacer()
            }
            .padding(.horizontal, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

private struct DetailsRowView: View {
    let item: FileItem
    let isSelected: Bool
    let onDoubleClick: () -> Void
    let viewModel: ExplorerViewModel
    @ObservedObject var tab: TabModel
    
    @State private var isHovering = false
    
    var body: some View {
        HStack(spacing: 0) {
            // Checkbox for easy multi-selection (Win11 style)
            Button(action: {
                tab.select(item: item, isToggle: true, isRange: false)
            }) {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .font(.system(size: 13))
                    .foregroundColor(isSelected ? Windows11Theme.accentColor : .secondary.opacity(0.6))
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
            .opacity((tab.showItemCheckboxes || isHovering || isSelected) ? 1.0 : 0.0)
            .padding(.leading, 6)
            
            // Name & Icon
            HStack(spacing: 8) {
                Image(nsImage: item.systemIcon)
                    .resizable()
                    .frame(width: 18, height: 18)
                
                Text(item.name)
                    .font(.system(size: 12))
                    .lineLimit(1)
                    .foregroundColor(item.isHidden ? .secondary : .primary)
            }
            .frame(minWidth: 200, maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 2)
            
            // Date modified
            Text(item.formattedDate)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .frame(width: 150, alignment: .leading)
                .padding(.horizontal, 6)
            
            // Type
            Text(item.kindDescription)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .frame(width: 140, alignment: .leading)
                .padding(.horizontal, 6)
            
            // Size
            Text(item.formattedSize)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .frame(width: 90, alignment: .trailing)
                .padding(.trailing, 10)
        }
        .frame(height: 28)
        .background(
            Group {
                if isSelected {
                    Windows11Theme.selectedBackground
                } else if isHovering {
                    Windows11Theme.hoverBackground
                } else {
                    Color.clear
                }
            }
        )
        .cornerRadius(4)
        .padding(.horizontal, 4)
        .contentShape(Rectangle())
        .onHover { hovering in
            isHovering = hovering
        }
        .gesture(
            TapGesture(count: 2).onEnded {
                onDoubleClick()
            }
            .exclusively(before: TapGesture(count: 1).onEnded {
                let flags = NSEvent.modifierFlags
                let isCmdOrCtrl = flags.contains(.command) || flags.contains(.control)
                let isShift = flags.contains(.shift)
                tab.select(item: item, isToggle: isCmdOrCtrl, isRange: isShift)
            })
        )
        .onRightClick {
            if !tab.selectedURLs.contains(item.url) {
                tab.select(item: item, isToggle: false, isRange: false)
            }
        }
        .contextMenu {
            FileContextMenu(item: item, viewModel: viewModel, tab: tab)
        }
    }
}
