//
//  IconsGridView.swift
//  filemanager
//

import AppKit
import SwiftUI

public struct IconsGridView: View {
    @ObservedObject var viewModel: ExplorerViewModel
    @ObservedObject var tab: TabModel
    let items: [FileItem]
    let mode: ViewMode
    
    private var iconSize: CGFloat {
        switch mode {
        case .largeIcons: return 64
        case .mediumIcons: return 48
        case .smallIcons: return 32
        default: return 48
        }
    }
    
    private var itemWidth: CGFloat {
        switch mode {
        case .largeIcons: return 96
        case .mediumIcons: return 80
        case .smallIcons: return 64
        default: return 80
        }
    }
    
    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: itemWidth, maximum: itemWidth + 24), spacing: 8)]
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(items) { item in
                        IconCardView(
                            item: item,
                            iconSize: iconSize,
                            width: itemWidth,
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

private struct IconCardView: View {
    let item: FileItem
    let iconSize: CGFloat
    let width: CGFloat
    let isSelected: Bool
    let onDoubleClick: () -> Void
    let viewModel: ExplorerViewModel
    @ObservedObject var tab: TabModel
    
    @State private var isHovering = false
    
    var body: some View {
        VStack(spacing: 6) {
            Image(nsImage: item.systemIcon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: iconSize, height: iconSize)
            
            Text(item.name)
                .font(.system(size: 11))
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .foregroundColor(item.isHidden ? .secondary : .primary)
                .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .frame(minWidth: width)
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
        .cornerRadius(Windows11Theme.cardCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Windows11Theme.cardCornerRadius)
                .stroke(isSelected ? Windows11Theme.accentColor.opacity(0.4) : Color.clear, lineWidth: 1)
        )
        .overlay(
            // Top-left Checkbox (Windows 11 style)
            Button(action: {
                tab.select(item: item, isToggle: true, isRange: false)
            }) {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .font(.system(size: 12))
                    .foregroundColor(isSelected ? Windows11Theme.accentColor : .secondary.opacity(0.8))
                    .padding(2)
                    .background(Color(NSColor.controlBackgroundColor).opacity(0.85))
                    .cornerRadius(3)
            }
            .buttonStyle(.plain)
            .opacity((tab.showItemCheckboxes || isHovering || isSelected) ? 1.0 : 0.0)
            .padding(4),
            alignment: .topLeading
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
