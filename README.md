# WebViewDemoApp - SwiftUI

This is a demonstration iOS app that provides a full-screen browser experience. If you develop your web app using a desktop web browser with device emulation enabled, there will be no difference when showing it in this app. You can easily clone the code and install the app on your iPhone using Xcode.

Location services are included for your convenience.

Upon launch, the app displays a list of URLs. You can delete or add URLs as needed, which is particularly useful when working on multiple projects. It also supports local IP addresses, as it utilizes a `WKWebView`. 

iOS 17 or above is required to use `.contentMargins()` to add some margin to the list in case the list goes long and the input area overlays the list items.

## Common Gestures

On the WebView page, you can exit by swiping right from the left edge of the screen. This action will reveal several options: `Hide`, `Refresh`, `Clear Cache and Close`, and `Cancel`.

## TODO
- [ ] `.contentMargins()` for lower iOS version
