//
//  TilesView.swift
//  filemanager
//

import AppKit
import SwiftUI

public struct TilesView: View {
    @ObservedObject var viewModel: ExplorerViewModel
    @ObservedObject var tab: TabModel
    let items: [FileItem]
    
    private let columns = [
        GridItem(.adaptive(minimum: 220, maximum: 280), spacing: 8)
    ]
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(items) { item in
                        TileCardView(
                            item: item,
                            isSelected: tab.selectedURLs.contains(item.url),
                            onDoubleClick: {
                                if item.isDirectory && !item.isPackage {
                                    tab.navigateTo(url: item.url)
                                } else {
                                    FileSystemManager.shared.openFile(url: item.url)
                                }
                            },
                            viewModel: viewModel,
                            tab: tab
                        )
                    }
                }
                .padding(12)
                
                // Clickable empty area below items
                Color.clear
                    .frame(maxWidth: .infinity, minHeight: 300)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        tab.deselectAll()
                    }
            }
        }
        .background(Color(NSColor.controlBackgroundColor).opacity(0.3))
        .contextMenu {
            EmptyAreaContextMenu(viewModel: viewModel, tab: tab)
        }
    }
}

private struct TileCardView: View {
    let item: FileItem
    let isSelected: Bool
    let onDoubleClick: () -> Void
    let viewModel: ExplorerViewModel
    @ObservedObject var tab: TabModel
    
    @State private var isHovering = false
    
    var body: some View {
        HStack(spacing: 8) {
            // Checkbox
            Button(action: {
                tab.select(item: item, isToggle: true, isRange: false)
            }) {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .font(.system(size: 13))
                    .foregroundColor(isSelected ? Windows11Theme.accentColor : .secondary.opacity(0.7))
                    .frame(width: 18, height: 18)
            }
            .buttonStyle(.plain)
            .opacity((tab.showItemCheckboxes || isHovering || isSelected) ? 1.0 : 0.0)
            
            Image(nsImage: item.systemIcon)
                .resizable()
                .frame(width: 36, height: 36)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.system(size: 12, weight: .medium))
                    .lineLimit(1)
                    .foregroundColor(item.isHidden ? .secondary : .primary)
                
                Text(item.kindDescription)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                if !item.formattedSize.isEmpty {
                    Text(item.formattedSize)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary.opacity(0.8))
                }
            }
            
            Spacer()
        }
        .padding(8)
        .frame(height: 54)
        .background(
            Group {
                if isSelected {
                    Windows11Theme.selectedBackground
                } else if isHovering {
                    Windows11Theme.hoverBackground
                } else {
                    Color(NSColor.controlBackgroundColor).opacity(0.6)
                }
            }
        )
        .cornerRadius(Windows11Theme.cardCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Windows11Theme.cardCornerRadius)
                .stroke(isSelected ? Windows11Theme.accentColor.opacity(0.4) : Color.primary.opacity(0.06), lineWidth: 1)
        )
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
