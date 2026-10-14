//
//  AboutDialogView.swift
//  filemanager
//

import AppKit
import SwiftUI

public struct AboutDialogView: View {
    let onDismiss: () -> Void
    @ObservedObject var lang = LocalizationManager.shared
    @StateObject private var updater = UpdateManager.shared
    
    public init(onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(lang.tr("about_filemanager"))
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
            
            Divider()
            
            // Main Content Area
            ScrollView {
                VStack(spacing: 16) {
                    // App Icon & Title
                    VStack(spacing: 8) {
                        Image(nsImage: NSImage(named: "AppIcon") ?? NSApplication.shared.applicationIconImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 72, height: 72)
                            .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
                        
                        Text(lang.tr("about_app_name"))
                            .font(.system(size: 15, weight: .bold))
                        
                        Text("\(lang.tr("about_version")) \(updater.currentVersion) (\(lang.tr("about_build")) \(updater.currentBuild))")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 6)
                    
                    // GitHub Link Button
                    Button(action: {
                        if let url = URL(string: "https://github.com/tony126051/filemanager") {
                            updater.openURL(url)
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "link")
                            Text("GitHub: tony126051/filemanager")
                                .underline()
                        }
                        .font(.system(size: 12))
                        .foregroundColor(Windows11Theme.accentColor)
                    }
                    .buttonStyle(.plain)
                    
                    // Update Section Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(lang.tr("about_updates"))
                                .font(.system(size: 13, weight: .semibold))
                            Spacer()
                            if updater.state == .checking {
                                ProgressView()
                                    .scaleEffect(0.7)
                            }
                        }
                        
                        // Status View
                        updateStatusView
                        
                        // Action Buttons
                        HStack {
                            Button(action: {
                                Task {
                                    await updater.checkForUpdates()
                                }
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.clockwise")
                                    Text(updater.state == .upToDate ? lang.tr("update_recheck") : lang.tr("update_check"))
                                }
                            }
                            .disabled(updater.state == .checking)
                            
                            Spacer()
                            
                            if case .updateAvailable(_, _, _, _, let downloadURL) = updater.state {
                                Button(action: {
                                    if let url = downloadURL {
                                        updater.openURL(url)
                                    }
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "arrow.down.circle.fill")
                                        Text(lang.tr("update_download"))
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        }
                    }
                    .padding(14)
                    .background(Color.primary.opacity(0.03))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                    )
                    
                    // Copyright
                    Text("Copyright © 2026 tony126051. All rights reserved.")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
                .padding(16)
            }
            
            Divider()
            
            // Footer
            HStack {
                Spacer()
                Button(lang.tr("ok")) {
                    onDismiss()
                }
                .keyboardShortcut(.defaultAction)
                .keyboardShortcut(.cancelAction)
            }
            .padding(12)
            .background(Color(NSColor.windowBackgroundColor))
        }
        .frame(width: 440, height: 490)
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    @ViewBuilder
    private var updateStatusView: some View {
        switch updater.state {
        case .idle:
            HStack(spacing: 8) {
                Image(systemName: "info.circle")
                    .foregroundColor(.secondary)
                Text(lang.tr("update_idle_hint"))
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
        case .checking:
            HStack(spacing: 8) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .foregroundColor(Windows11Theme.accentColor)
                Text(lang.tr("update_checking"))
                    .font(.system(size: 12))
            }
            
        case .upToDate:
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                VStack(alignment: .leading, spacing: 2) {
                    Text(lang.tr("update_up_to_date"))
                        .font(.system(size: 12, weight: .medium))
                    if let date = updater.lastCheckedDate {
                        Text(date.formatted(date: .abbreviated, time: .shortened))
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                }
            }
            
        case .updateAvailable(let version, let releaseName, let notes, let releaseURL, _):
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .foregroundColor(.orange)
                    Text(lang.tr("update_available", version))
                        .font(.system(size: 12, weight: .bold))
                }
                
                if !releaseName.isEmpty && releaseName != version {
                    Text(releaseName)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                if !notes.isEmpty {
                    ScrollView {
                        Text(notes)
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxHeight: 70)
                    .padding(6)
                    .background(Color.primary.opacity(0.02))
                    .cornerRadius(4)
                }
                
                Button(action: {
                    updater.openURL(releaseURL)
                }) {
                    Text(lang.tr("update_view_release"))
                        .font(.system(size: 11))
                        .foregroundColor(Windows11Theme.accentColor)
                }
                .buttonStyle(.plain)
            }
            
        case .failed(let message):
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                Text(lang.tr("update_failed", message))
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
    }
}
