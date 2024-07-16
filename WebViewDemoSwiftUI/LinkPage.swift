//
//  LinkPage.swift
//  WebViewDemoSwiftUI
//
//  Created by CB on 14/7/2024.
//

import SwiftUI
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var authorizationStatus: CLAuthorizationStatus?
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
}

struct LinkPage: View {
    @State private var links: [String] = UserDefaults.standard.stringArray(forKey: "savedLinks") ?? [
        "https://www.apple.com",
        "https://maps.google.com",
        "https://www.bing.com/maps",
    ]
    @State private var inputLink: String = ""
    @State private var selectedURL: URL?
    @State private var isWebViewPresented: Bool = false
    @StateObject private var locationManager = LocationManager()
    private var fontSize: CGFloat = 17
    @State private var textFieldHeight: CGFloat = 30 // Initial height
    
    var body: some View {
        ZStack {
            NavigationView {
                VStack {
                    List {
                        ForEach(links, id: \.self) { link in
                            Button(action: {
                                inputLink = link
                            }) {
                                HStack {
                                    Image(systemName: "link")
                                    Text(link)
                                        .lineLimit(nil)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                        .onDelete(perform: deleteLink)
                    }
                    
                    
                    if locationManager.authorizationStatus != .authorizedWhenInUse &&
                        locationManager.authorizationStatus != .authorizedAlways {
                        Button("Turn on location service") {
                            openAppSettings()
                        }
                    }
                }
                .navigationTitle("Links")
                .fullScreenCover(isPresented: $isWebViewPresented) {
                    WebViewPage(url: $selectedURL)
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .onAppear {
                locationManager.requestPermission()
            }
            VStack {
                Spacer()
                HStack(alignment: .bottom) {
                    TextField("Link to visit", text: $inputLink, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(2, reservesSpace: true)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding([.top, .leading, .bottom])
                    
                    Button(action: addLink) {
                        Image(systemName: "plus")
                            .padding(.vertical, 2.0)
                            .frame(height: 22)
                    }
                    .padding(.bottom)
                    .buttonStyle(.bordered)
                    
                    Button(action: {
                        if let url = URL(string: inputLink) {
                            selectedURL = url
                            isWebViewPresented = true
                        }
                    }) {
                        Text("Go")
                            .frame(height: 22)
                    }
                    .padding([.bottom, .trailing])
                    .buttonStyle(.borderedProminent)
                }
                .background(.thinMaterial)
                .padding()
                .cornerRadius(20)
                .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.13), radius: 10)
            }
        }
    }
    
    func addLink() {
        if !inputLink.isEmpty {
            links.append(inputLink)
            inputLink = ""
            saveLinks()
        }
    }
    
    func deleteLink(at offsets: IndexSet) {
        links.remove(atOffsets: offsets)
        saveLinks()
    }
    
    func saveLinks() {
        UserDefaults.standard.set(links, forKey: "savedLinks")
    }
    
    func openAppSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        }
    }
    
    private func updateTextFieldHeight() {
        let newSize = inputLink.size(withAttributes: [.font: UIFont.preferredFont(forTextStyle: .body)])
        textFieldHeight = newSize.height + 16 // Add some padding
    }
}

struct WebViewPage: View {
    @Binding var url: URL?
    @Environment(\.presentationMode) var presentationMode
    @State private var showingDismissAlert = false
    @State private var shouldClearCache = false
    
    var body: some View {
        Group {
            if let url = url {
                WebView(url: url, clearCache: $shouldClearCache)
                    .edgesIgnoringSafeArea(.all)
                    .toolbar(.hidden)
            } else {
                Text("Invalid URL")
            }
        }
        .gesture(DragGesture().onEnded({ gesture in
            if gesture.translation.width > 100 {
                self.showingDismissAlert = true
            }
        }))
        .alert(isPresented: $showingDismissAlert) {
            Alert(
                title: Text("Close Web View"),
                message: Text("What would you like to do?"),
                primaryButton: .default(Text("Hide")) {
                    self.presentationMode.wrappedValue.dismiss()
                },
                secondaryButton: .default(Text("Clear Cache and Close")) {
                    self.shouldClearCache = true
                    self.presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

extension UITextView {
    static func calculateHeight(text: String, width: CGFloat = UIScreen.main.bounds.width) -> CGFloat {
        let textView = UITextView(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        textView.text = text
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.sizeToFit()
        return textView.frame.height
    }
}

#Preview {
    LinkPage()
}
