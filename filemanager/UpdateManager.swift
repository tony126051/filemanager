//
//  UpdateManager.swift
//  filemanager
//

import AppKit
import Combine
import Foundation
import SwiftUI

public struct GitHubAsset: Codable {
    public let name: String
    public let browser_download_url: String
    public let size: Int?
}

public struct GitHubRelease: Codable {
    public let tag_name: String
    public let name: String?
    public let body: String?
    public let html_url: String
    public let published_at: String?
    public let assets: [GitHubAsset]?
}

public enum UpdateState: Equatable {
    case idle
    case checking
    case upToDate
    case updateAvailable(version: String, releaseName: String, notes: String, releaseURL: URL, downloadURL: URL?)
    case failed(String)
}

@MainActor
public final class UpdateManager: ObservableObject {
    public static let shared = UpdateManager()
    
    @Published public private(set) var state: UpdateState = .idle
    @Published public private(set) var lastCheckedDate: Date? = nil
    
    public let repoOwner = "tony126051"
    public let repoName = "filemanager"
    
    public var currentVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    public var currentBuild: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    public func checkForUpdates() async {
        state = .checking
        
        let urlString = "https://api.github.com/repos/\(repoOwner)/\(repoName)/releases/latest"
        guard let url = URL(string: urlString) else {
            state = .failed("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        request.setValue("filemanager-macos/\(currentVersion)", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 15
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                state = .failed("Invalid server response")
                return
            }
            
            lastCheckedDate = Date()
            
            if httpResponse.statusCode == 404 {
                // No releases found yet
                state = .upToDate
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                state = .failed("HTTP \(httpResponse.statusCode)")
                return
            }
            
            let decoder = JSONDecoder()
            let release = try decoder.decode(GitHubRelease.self, from: data)
            
            let remoteTag = release.tag_name
            let releaseURL = URL(string: release.html_url) ?? URL(string: "https://github.com/\(repoOwner)/\(repoName)/releases")!
            let downloadAsset = release.assets?.first(where: {
                $0.name.hasSuffix(".zip") || $0.name.hasSuffix(".dmg") || $0.name.hasSuffix(".tar.gz")
            })
            let downloadURL = downloadAsset.flatMap { URL(string: $0.browser_download_url) } ?? releaseURL
            
            if Self.isVersion(remoteTag, newerThan: currentVersion) {
                state = .updateAvailable(
                    version: remoteTag,
                    releaseName: release.name ?? remoteTag,
                    notes: release.body ?? "",
                    releaseURL: releaseURL,
                    downloadURL: downloadURL
                )
            } else {
                state = .upToDate
            }
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
    
    public static func isVersion(_ v1: String, newerThan v2: String) -> Bool {
        func parseVersion(_ s: String) -> [Int] {
            let clean = s.trimmingCharacters(in: CharacterSet(charactersIn: "vV \t\n\r"))
            return clean.split(separator: ".").compactMap { Int($0) }
        }
        let p1 = parseVersion(v1)
        let p2 = parseVersion(v2)
        let count = max(p1.count, p2.count)
        for i in 0..<count {
            let num1 = i < p1.count ? p1[i] : 0
            let num2 = i < p2.count ? p2[i] : 0
            if num1 > num2 { return true }
            if num1 < num2 { return false }
        }
        return false
    }
    
    public func openURL(_ url: URL) {
        NSWorkspace.shared.open(url)
    }
}
