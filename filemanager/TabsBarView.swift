//
//  TabsBarView.swift
//  filemanager
//

import SwiftUI

public struct TabsBarView: View {
    @ObservedObject var viewModel: ExplorerViewModel
    @ObservedObject var lang = LocalizationManager.shared
    
    public var body: some View {
        HStack(spacing: 4) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 3) {
                    ForEach(Array(viewModel.tabs.enumerated()), id: \.element.id) { index, tab in
                        TabItemView(
                            tab: tab,
                            isActive: index == viewModel.activeTabIndex,
                            canClose: viewModel.tabs.count > 1,
                            onSelect: {
                                viewModel.selectTab(at: index)
                            },
                            onClose: {
                                viewModel.closeTab(at: index)
                            }
                        )
                    }
                }
                .padding(.leading, 8)
            }
            
            // Win11 "+" Add Tab button
            Button(action: {
                viewModel.addNewTab()
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
                    .frame(width: 28, height: 26)
                    .background(Color.primary.opacity(0.04))
                    .cornerRadius(4)
            }
            .buttonStyle(.plain)
            .help("\(lang.tr("new_tab")) (Cmd+T)")
            
            Spacer()
        }
        .frame(height: 38)
        .background(Color(NSColor.windowBackgroundColor))
        .overlay(
            Divider(), alignment: .bottom
        )
    }
}

private struct TabItemView: View {
    @ObservedObject var tab: TabModel
    @ObservedObject var lang = LocalizationManager.shared
    let isActive: Bool
    let canClose: Bool
    let onSelect: () -> Void
    let onClose: () -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        HStack(spacing: 6) {
            Image(nsImage: tab.icon)
                .resizable()
                .frame(width: 16, height: 16)
            
            Text(tab.title)
                .font(.system(size: 12, weight: isActive ? .medium : .regular))
                .lineLimit(1)
                .foregroundColor(isActive ? .primary : .secondary)
            
            if canClose {
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor((isHovering || isActive) ? .secondary : .clear)
                        .frame(width: 16, height: 16)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .help("\(lang.tr("close_tab")) (Cmd+W)")
            }
        }
        .padding(.horizontal, 10)
        .frame(height: 30)
        .background(
            Group {
                if isActive {
                    Color(NSColor.controlBackgroundColor)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
                } else if isHovering {
                    Color.primary.opacity(0.06)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                } else {
                    Color.clear
                }
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(isActive ? Color.primary.opacity(0.12) : Color.clear, lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect()
        }
        .onHover { hovering in
            isHovering = hovering
        }
    }
}
