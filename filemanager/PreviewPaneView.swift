//
//  PreviewPaneView.swift
//  filemanager
//

import AppKit
import QuickLookUI
import SwiftUI

public struct PreviewPaneView: View {
    @ObservedObject var viewModel: ExplorerViewModel
    @ObservedObject var tab: TabModel
    @ObservedObject var lang = LocalizationManager.shared
    
    private var selectedItem: FileItem? {
        guard let url = tab.selectedURLs.first else { return nil }
        return tab.items.first(where: { $0.url == url }) ?? FileItem(url: url)
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(viewModel.rightPaneMode == .preview ? lang.tr("preview_title") : lang.tr("details_title"))
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: {
                    viewModel.rightPaneMode = .none
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .frame(height: 32)
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            if let item = selectedItem {
                ScrollView {
                    if viewModel.rightPaneMode == .preview {
                        previewContent(for: item)
                    } else {
                        detailsContent(for: item)
                    }
                }
            } else {
                VStack(spacing: 8) {
                    Spacer()
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 36))
                        .foregroundColor(.secondary.opacity(0.3))
                    Text(lang.tr("preview_placeholder"))
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    Spacer()
                }
            }
        }
        .frame(minWidth: 220, idealWidth: 260, maxWidth: 350)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
    }
    
    // MARK: - Preview Content
    @ViewBuilder
    private func previewContent(for item: FileItem) -> some View {
        VStack(spacing: 12) {
            // Visual Preview
            if isImageFile(item) {
                if let nsImage = NSImage(contentsOf: item.url) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 180)
                        .cornerRadius(6)
                        .shadow(radius: 2)
                }
            } else if isTextFile(item) {
                TextFilePreview(url: item.url)
                    .frame(height: 180)
                    .cornerRadius(6)
            } else {
                Image(nsImage: item.systemIcon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .padding(.top, 10)
            }
            
            Text(item.name)
                .font(.system(size: 13, weight: .semibold))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .padding(.horizontal, 10)
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                MetadataRow(label: lang.tr("sort_type"), value: item.kindDescription)
                if !item.formattedSize.isEmpty {
                    MetadataRow(label: lang.tr("sort_size"), value: item.formattedSize)
                }
                MetadataRow(label: lang.tr("sort_date_modified"), value: item.formattedDate)
                MetadataRow(label: lang.tr("prop_location"), value: item.url.path)
            }
            .padding(.horizontal, 12)
            
            Spacer(minLength: 16)
        }
        .padding(.vertical, 12)
    }
    
    // MARK: - Details Content
    @ViewBuilder
    private func detailsContent(for item: FileItem) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(nsImage: item.systemIcon)
                    .resizable()
                    .frame(width: 36, height: 36)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.name)
                        .font(.system(size: 13, weight: .semibold))
                        .lineLimit(2)
                    Text(item.kindDescription)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                Text(lang.tr("prop_tab_general"))
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.secondary)
                
                let ext = item.extensionName.isEmpty ? lang.tr("none") : ".\(item.extensionName)"
                MetadataRow(label: lang.tr("prop_file_type"), value: ext)
                if !item.formattedSize.isEmpty {
                    MetadataRow(label: lang.tr("sort_size"), value: item.formattedSize)
                }
                MetadataRow(label: lang.tr("prop_created"), value: item.formattedCreationDate)
                MetadataRow(label: lang.tr("sort_date_modified"), value: item.formattedDate)
                if !item.permissionsString.isEmpty {
                    MetadataRow(label: lang.tr("prop_octal_code"), value: item.permissionsString)
                }
                MetadataRow(label: lang.tr("prop_hidden"), value: item.isHidden ? lang.tr("yes") : lang.tr("no"))
            }
            .padding(.horizontal, 12)
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                Text(lang.tr("prop_location"))
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.secondary)
                
                Text(item.url.deletingLastPathComponent().path)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .lineLimit(4)
            }
            .padding(.horizontal, 12)
            
            Spacer(minLength: 16)
        }
    }
    
    private func isImageFile(_ item: FileItem) -> Bool {
        let exts = ["png", "jpg", "jpeg", "gif", "webp", "tiff", "bmp", "heic", "svg"]
        return exts.contains(item.extensionName)
    }
    
    private func isTextFile(_ item: FileItem) -> Bool {
        let exts = ["txt", "md", "swift", "json", "xml", "plist", "py", "c", "cpp", "h", "html", "css", "js", "ts", "sh", "yml", "yaml"]
        return exts.contains(item.extensionName)
    }
}

private struct MetadataRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .font(.system(size: 11))
                .foregroundColor(.primary)
                .lineLimit(3)
            
            Spacer()
        }
    }
}

private struct TextFilePreview: View {
    let url: URL
    @ObservedObject var lang = LocalizationManager.shared
    
    var textContent: String {
        guard let data = try? Data(contentsOf: url) else { return lang.tr("preview_unavailable") }
        let prefix = data.prefix(8192)
        return String(decoding: prefix, as: UTF8.self)
    }
    
    var body: some View {
        ScrollView {
            Text(textContent)
                .font(.system(size: 10, design: .monospaced))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(8)
        }
        .background(Color(NSColor.textBackgroundColor))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
        )
    }
}
