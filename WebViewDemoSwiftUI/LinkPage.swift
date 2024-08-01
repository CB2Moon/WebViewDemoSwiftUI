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
    @State private var textFieldHeight: CGFloat = 34
    private let maxTextFieldHeight: CGFloat = 140 // Approximately 7 lines
    
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
                        .contentMargins(.bottom, 110.0)
                        
                        if locationManager.authorizationStatus != .authorizedWhenInUse &&
                            locationManager.authorizationStatus != .authorizedAlways {
                            Button("Turn on location service") {
                                openAppSettings()
                            }.padding(.bottom, -10.0)
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
                }
            }
            VStack {
                Spacer()
                HStack(alignment: .bottom) {
                    TextEditor(text: $inputLink)
                        .font(.system(size: fontSize))
                        .frame(height: min(max(34, textFieldHeight), maxTextFieldHeight))
                        .padding(4)
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(8)
                        .overlay(){
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(UIColor.systemGray4), lineWidth: 1)
                        }
                        .onChange(of: inputLink) {
                            updateTextFieldHeight()
                        }
                        .padding([.top, .leading, .bottom])
                    
                    Button(action: addLink) {
                        Image(systemName: "plus")
                            .padding(.vertical, 2.0)
                            .frame(height: 28)
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
                            .frame(height: 28)
                    }
                    .padding([.bottom, .trailing])
                    .buttonStyle(.borderedProminent)
                }
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16.0, style: .continuous))
                .padding()
                .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.13), radius: 10)
            }
        }
    }
    
    func addLink() {
        if !inputLink.isEmpty {
            links.append(inputLink)
            inputLink = ""
            saveLinks()
            updateTextFieldHeight()
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
        let size = CGSize(width: UIScreen.main.bounds.width - 100, height: .infinity)
        let estimatedSize = inputLink.boundingRect(
            with: size,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: UIFont.systemFont(ofSize: fontSize)],
            context: nil
        )
        textFieldHeight = estimatedSize.height + 12
    }
}

#Preview {
    LinkPage()
}
