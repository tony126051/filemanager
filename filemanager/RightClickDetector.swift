//
//  RightClickDetector.swift
//  filemanager
//

import AppKit
import SwiftUI

public struct RightClickDetector: NSViewRepresentable {
    public let onRightClick: () -> Void
    
    public init(onRightClick: @escaping () -> Void) {
        self.onRightClick = onRightClick
    }
    
    public func makeNSView(context: Context) -> RightClickNSView {
        let view = RightClickNSView()
        view.onRightClick = onRightClick
        return view
    }
    
    public func updateNSView(_ nsView: RightClickNSView, context: Context) {
        nsView.onRightClick = onRightClick
    }
    
    public final class RightClickNSView: NSView {
        public var onRightClick: (() -> Void)?
        
        public override func rightMouseDown(with event: NSEvent) {
            onRightClick?()
            super.rightMouseDown(with: event)
        }
    }
}

public extension View {
    func onRightClick(action: @escaping () -> Void) -> some View {
        self.background(RightClickDetector(onRightClick: action))
    }
}
