//
//  MapSearchPanel.swift
//  Go London
//
//  Created by Tom Knighton on 01/04/2022.
//

import Foundation
import SwiftUI

struct MapSearchPanelView: View {
    
    @Binding var searchText: String
    @FocusState var isFocused: Bool
    @State var promptText = "nearby stations..."
    
    var body: some View {
        VStack {
            withAnimation(.easeInOut) {
                GLTextField(text: $searchText, prompt: $promptText, promptPrefix: "Search for ", leftSystemImage: "magnifyingglass.circle", isFocused: $isFocused)
                    .onTapGesture {
                        if !self.isFocused {
                            self.isFocused = true
                        }
                    }
                    .onAppear {
                        self.changeSearchText()
                    }
            }
            
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.layer1)
        )
        .padding(.horizontal)
        .padding(.bottom, isFocused ? 6 : 28)
        .shadow(radius: 3)
    }
    
    func changeSearchText() {
        let random = ["nearby stations", "nearby streets", "far away towns", "far away stations", "landmarks", "addresses", "places of interest", "restuarants", "hotels"]
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.promptText = "\(random.randomElement() ?? "nearby stations")..."
            self.changeSearchText()
        }
    }
}

struct MapSearchPanelPreview: PreviewProvider {
    
    static var previews: some View {
        ZStack {
            MapSearchPanelView(searchText: .constant(""))
                
        }
        .previewLayout(.sizeThatFits)
        .preferredColorScheme(.dark)
    }
}
