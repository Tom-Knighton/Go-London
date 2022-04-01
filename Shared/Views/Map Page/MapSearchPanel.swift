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
    
    var body: some View {
        VStack {
            GLTextField(text: $searchText, prompt: "Search...", leftSystemImage: "magnifyingglass.circle", isFocused: $isFocused)
                .onTapGesture {
                    if !self.isFocused {
                        self.isFocused = true
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
