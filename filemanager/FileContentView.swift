//
//  FileContentView.swift
//  filemanager
//

import AppKit
import SwiftUI
import UniformTypeIdentifiers

public struct FileContentView: View {
    @ObservedObject var viewModel: ExplorerViewModel
    @ObservedObject var tab: TabModel
    
    public var body: some View {
        let items = tab.displayedItems
        
        Group {
            if items.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "folder")
                        .font(.system(size: 44))
                        .foregroundColor(.secondary.opacity(0.4))
                    Text(LocalizationManager.shared.tr("menu_empty_folder"))
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(NSColor.controlBackgroundColor).opacity(0.2))
                .contentShape(Rectangle())
                .contextMenu {
                    EmptyAreaContextMenu(viewModel: viewModel, tab: tab)
                }
            } else {
                switch tab.viewMode {
                case .details:
                    DetailsView(viewModel: viewModel, tab: tab, items: items)
                case .largeIcons, .mediumIcons, .smallIcons:
                    IconsGridView(viewModel: viewModel, tab: tab, items: items, mode: tab.viewMode)
                case .list:
                    ListView(viewModel: viewModel, tab: tab, items: items)
                case .tiles:
                    TilesView(viewModel: viewModel, tab: tab, items: items)
                }
            }
        }
        .onDrop(of: [.fileURL], isTargeted: nil) { providers in
            handleDrop(providers: providers)
        }
    }
    
    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { item, _ in
                guard let data = item as? Data,
                      let url = URL(dataRepresentation: data, relativeTo: nil) else { return }
                DispatchQueue.main.async {
                    do {
                        try FileSystemManager.shared.copy(items: [url], to: tab.currentURL)
                        tab.refresh(showHidden: viewModel.showHiddenFiles)
                    } catch {
                        viewModel.showStatus("拖放複製失敗: \(error.localizedDescription)")
                    }
                }
            }
        }
        return true
    }
}
