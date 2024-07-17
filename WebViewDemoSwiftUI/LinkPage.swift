//
//  LinkPage.swift
//  WebViewDemoSwiftUI
//
//  Created by CB on 14/7/2024.
//

import SwiftUI

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
            GeometryReader { proxy in
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
                        WebViewPage(url: $selectedURL, isPresented: $isWebViewPresented)
                    }
                }
                .scrollDismissesKeyboard(.immediately)
                .onAppear {
                    locationManager.requestPermission()
                }.gesture(DragGesture().onEnded({ gesture in
                    if gesture.translation.width < -100 && gesture.startLocation.x >= proxy.size.width - 20 && selectedURL != nil {
                        isWebViewPresented = true
                    }
                }))
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
