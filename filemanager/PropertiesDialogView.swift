//
//  PropertiesDialogView.swift
//  filemanager
//

import AppKit
import SwiftUI

public struct PropertiesDialogView: View {
    let item: FileItem
    let onDismiss: () -> Void
    @ObservedObject var lang = LocalizationManager.shared
    
    @State private var selectedTab: Int = 0
    @State private var defaultAppName: String = ""
    
    public var body: some View {
        VStack(spacing: 0) {
            // Windows 11 style Dialog Header
            HStack {
                Text(lang.tr("prop_title", item.name))
                    .font(.system(size: 13, weight: .bold))
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 10)
            
            // Tab Picker
            Picker("", selection: $selectedTab) {
                Text(lang.tr("prop_tab_general")).tag(0)
                Text(lang.tr("prop_tab_security")).tag(1)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.bottom, 10)
            
            Divider()
            
            // Tab Content
            ScrollView {
                if selectedTab == 0 {
                    generalTabContent
                } else {
                    securityTabContent
                }
            }
            .padding(16)
            
            Divider()
            
            // Bottom Action Buttons
            HStack {
                Spacer()
                Button(lang.tr("ok")) {
                    onDismiss()
                }
                .keyboardShortcut(.defaultAction)
                
                Button(lang.tr("cancel")) {
                    onDismiss()
                }
                .keyboardShortcut(.cancelAction)
            }
            .padding(12)
            .background(Color(NSColor.windowBackgroundColor))
        }
        .frame(width: 420, height: 480)
        .background(Color(NSColor.windowBackgroundColor))
        .onAppear {
            resolveDefaultApp()
        }
    }
    
    // MARK: - General Tab
    private var generalTabContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            // File Name & Icon
            HStack(spacing: 12) {
                Image(nsImage: item.systemIcon)
                    .resizable()
                    .frame(width: 40, height: 40)
                
                Text(item.name)
                    .font(.system(size: 13, weight: .semibold))
            }
            
            Divider()
            
            // Type & Opens With
            Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 8) {
                GridRow {
                    Text(lang.tr("prop_file_type"))
                        .foregroundColor(.secondary)
                    let ext = item.extensionName.isEmpty ? lang.tr("none") : ".\(item.extensionName)"
                    Text("\(item.kindDescription) (\(ext))")
                }
                
                GridRow {
                    Text(lang.tr("prop_opens_with"))
                        .foregroundColor(.secondary)
                    HStack {
                        Text(defaultAppName.isEmpty ? lang.tr("default_app") : defaultAppName)
                        Spacer()
                        Button(lang.tr("menu_reveal_in_finder")) {
                            FileSystemManager.shared.revealInFinder(url: item.url)
                        }
                        .buttonStyle(.link)
                        .font(.system(size: 11))
                    }
                }
            }
            
            Divider()
            
            // Location, Size, Dates
            Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 8) {
                GridRow {
                    Text(lang.tr("prop_location"))
                        .foregroundColor(.secondary)
                    Text(item.url.deletingLastPathComponent().path)
                        .lineLimit(2)
                }
                
                GridRow {
                    Text(lang.tr("prop_size"))
                        .foregroundColor(.secondary)
                    Text(item.isDirectory && !item.isPackage
                         ? lang.tr("folder")
                         : "\(item.formattedSize) (\(item.fileSize) \(lang.tr("bytes")))")
                }
                
                GridRow {
                    Text(lang.tr("prop_created"))
                        .foregroundColor(.secondary)
                    Text(item.formattedCreationDate)
                }
                
                GridRow {
                    Text(lang.tr("prop_modified"))
                        .foregroundColor(.secondary)
                    Text(item.formattedDate)
                }
            }
            
            Divider()
            
            // Attributes (Win11 style)
            HStack(spacing: 20) {
                Text(lang.tr("prop_attributes"))
                    .foregroundColor(.secondary)
                
                Toggle(lang.tr("prop_hidden"), isOn: .constant(item.isHidden))
                    .disabled(true)
                
                Toggle(lang.tr("prop_readonly"), isOn: .constant(!FileManager.default.isWritableFile(atPath: item.url.path)))
                    .disabled(true)
            }
        }
        .font(.system(size: 11))
    }
    
    // MARK: - Security Tab
    private var securityTabContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(lang.tr("prop_object_name", item.url.path))
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            Divider()
            
            Text(lang.tr("prop_posix_permissions"))
                .font(.system(size: 12, weight: .semibold))
            
            Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 8) {
                GridRow {
                    Text(lang.tr("prop_octal_code"))
                        .foregroundColor(.secondary)
                    Text(item.permissionsString.isEmpty ? "755" : item.permissionsString)
                        .font(.system(size: 11, design: .monospaced))
                }
                
                GridRow {
                    Text(lang.tr("prop_readable"))
                        .foregroundColor(.secondary)
                    Text(FileManager.default.isReadableFile(atPath: item.url.path) ? lang.tr("yes") : lang.tr("no"))
                }
                
                GridRow {
                    Text(lang.tr("prop_writable"))
                        .foregroundColor(.secondary)
                    Text(FileManager.default.isWritableFile(atPath: item.url.path) ? lang.tr("yes") : lang.tr("no"))
                }
                
                GridRow {
                    Text(lang.tr("prop_executable"))
                        .foregroundColor(.secondary)
                    Text(FileManager.default.isExecutableFile(atPath: item.url.path) ? lang.tr("yes") : lang.tr("no"))
                }
            }
            
            Divider()
            
            Text(lang.tr("prop_advanced_note"))
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
        .font(.system(size: 11))
    }
    
    private func resolveDefaultApp() {
        if let appURL = NSWorkspace.shared.urlForApplication(toOpen: item.url) {
            defaultAppName = appURL.deletingPathExtension().lastPathComponent
        } else {
            defaultAppName = lang.tr("default_app")
        }
    }
}
