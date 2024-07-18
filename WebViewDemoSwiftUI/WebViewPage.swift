//
//  WebViewPage.swift
//  WebViewDemoSwiftUI
//
//  Created by CB on 17/7/2024.
//

import SwiftUI

struct WebViewPage: View {
    @Binding var url: URL?
    @Binding var isPresented: Bool
    @Environment(\.dismiss) var dismiss
    @State private var showingDismissAlert = false
    @State private var shouldClearCache = false
    @State private var shouldReload = false
    
    var body: some View {
        Group {
            if let url = url {
                WebView(url: url, clearCache: $shouldClearCache, reload: $shouldReload)
                    .edgesIgnoringSafeArea(.all)
                    .toolbar(.hidden)
            } else {
                Text("Invalid URL")
            }
        }
        .gesture(DragGesture().onEnded({ gesture in
            if gesture.translation.width > 100 && gesture.startLocation.x <= 20 {
                self.showingDismissAlert = true
            }
        }))
        .alert("Close Web View", isPresented: $showingDismissAlert) {
            Button("Hide") {
                dismiss()
            }            
            Button("Refresh") {
                self.shouldReload = true
            }
            Button("Clear Cache and Close", role: .destructive) {
                self.shouldClearCache = true
                dismiss()
            }
            Button("Cancel", role: .cancel) {
                // Do nothing, just dismiss the alert
            }
        } message: {
            Text("What would you like to do?")
        }
    }
}
