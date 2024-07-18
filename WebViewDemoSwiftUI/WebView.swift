//
//  WebViewPage.swift
//  WebViewDemoSwiftUI
//
//  Created by CB on 14/7/2024.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL
    @Binding var clearCache: Bool
    @Binding var reload: Bool
    
    func makeUIView(context: Context) -> WKWebView {
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }
        webView.scrollView.bounces = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        if clearCache {
            clearWebViewCache(webView)
            DispatchQueue.main.async {
                self.clearCache = false
            }
        }
        if reload {
            webView.reload()
            DispatchQueue.main.async {
                self.reload = false
            }
        } else {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    private func clearWebViewCache(_ webView: WKWebView) {
        let dataTypes = WKWebsiteDataStore.allWebsiteDataTypes()
        let date = Date(timeIntervalSince1970: 0)
        WKWebsiteDataStore.default().removeData(ofTypes: dataTypes, modifiedSince: date) {
//            print("WebView cache cleared")
        }
    }
}
