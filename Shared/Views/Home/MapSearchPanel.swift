//
//  MapSearchPanel.swift
//  Go London
//
//  Created by Tom Knighton on 01/04/2022.
//

import Foundation
import SwiftUI
import GoLondonSDK

struct MapSearchPanelView: View {
    
    private var isFocused: FocusState<Bool>.Binding
    @State var promptText = "nearby stations..."
    
    @ObservedObject var model: MapSearchPanelViewModel
    @State private var cachedText: String = ""
    
    init(isFocused: FocusState<Bool>.Binding, model: MapSearchPanelViewModel) {
        self.isFocused = isFocused
        self.model = model
    }
    
    var body: some View {
        VStack {
            
            if model.isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                Spacer().frame(height: 8)
            }
            
            if self.model.searchResults.isEmpty == false {
                ScrollViewReader { reader in
                    
                    ScrollView {
                        LazyVStack {
                            HStack {
                                Spacer()
                                Button(action: { withAnimation { self.model.searchResults.removeAll(); self.model.searchText = "" } } ) {
                                    HStack {
                                        Text(Image(systemName: "xmark"))
                                            .frame(width: 15, height: 15)
                                        Text("Clear")
                                    }
                                    .padding(4)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.blue, lineWidth: 2)
                                    )
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    
                                }.id(1)
                            }
                            
                            ForEach(self.model.searchResults, id: \.lat) { point in
                                SearchResultView(point: point)
                                    .id(String(describing: point.lat ?? 0) + String(describing: point.lon ?? 0))
                                    .frame(maxWidth: .infinity)
                                    .padding(.horizontal, 4)
                                    .padding(.top, 4)
                            }
                        }
                    }
                    .onReceive(model.$searchResults) { newValue in
                        guard let first = newValue.first else { return }
                        
                        reader.scrollTo(String(describing: first.lat ?? 0) + String(describing: first.lon ?? 0), anchor: .top)
                    }
                }
            }
            withAnimation(.easeInOut) {
                VStack {
                    GLTextField(text: $model.searchText, prompt: $promptText, promptPrefix: "Search for ", leftSystemImage: "magnifyingglass.circle", isFocused: isFocused)
                        .onReceive(model.$searchText.debounce(for: 0.8, scheduler: RunLoop.main)) { text in
                            guard self.cachedText != text else {
                                return
                            }
                            
                            Task {
                                guard model.searchText.count >= 3 || model.searchText.count == 0 else { return }
                                
                                if model.searchText.count != 0 {
                                    await model.makeSearch()
                                } else {
                                    withAnimation {
                                        self.model.searchResults.removeAll()
                                    }
                                }
                                self.cachedText = text
                            }
                        }
                        .onTapGesture(perform: {
                            withAnimation(.easeInOut) {
                                if !self.isFocused.wrappedValue {
                                    self.isFocused.wrappedValue = true
                                }
                            }
                        })
                        .onAppear {
                            self.changeSearchText()
                        }
                }
                
            }
            
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Material.regular)
                .shadow(radius: 3)
        )
        .padding(.horizontal)
    }
    
    func changeSearchText() {
        let random = ["nearby stations", "nearby streets", "far away towns", "far away stations", "landmarks", "addresses", "places of interest", "restuarants", "hotels",  "bus stops", "cities"]
        DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
            withAnimation(.easeInOut(duration: 1)) {
                self.promptText = "\(random.randomElement() ?? "nearby stations")..."
                self.changeSearchText()
            }
            
        }
    }
}

//struct MapSearchPanelPreview: PreviewProvider {
//
//    static var previews: some View {
//        ZStack {
//            MapSearchPanelView()
//
//        }
//        .previewLayout(.sizeThatFits)
//        .preferredColorScheme(.dark)
//    }
//}
