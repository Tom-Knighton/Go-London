//
//  DirectionsView.swift
//  GaryGo
//
//  Created by Tom Knighton on 05/10/2021.
//

import Foundation
import SwiftUI

struct DirectionsHomeView: View {
    
    @State var searchText = ""
    @State var searchResults: [StopPoint] = []
    @State var isSearching = false
    @Environment(\.safeAreaInsets) var edges
    
    @State var searchTask: Task<Void, Never>?
    
    var body: some View {
        VStack {
            
            if (searchText.isEmpty) {
                Text("Where are we going?")
                    .font(.title)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .animation(.easeInOut, value: searchText.isEmpty)
                    .transition(.opacity)
            }
            
            
            SearchStopsTextField(placeHolder: "Search for a destination...", text: $searchText.animation())
            
            if (!searchText.isEmpty) {
                if !searchResults.isEmpty {
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(searchResults, id: \.id) { stopPoint in
                                NavigationLink(destination: NavigationLazyView(StopPointOverview(stopPoint: stopPoint))) {
                                    SearchStopResultView(stop: stopPoint)
                                }
                            }
                        }
                        .padding(.bottom, edges.bottom + (edges.bottom == 0 ? 80 : 60))
                    }
                } else {
                    if self.searchText.count >= 3 {
                        if isSearching {
                            LottieView(name: "SearchingGif", loopMode: .loop)
                                .frame(width: 150, height: 150)
                        } else {
                            Text("No Results :(")
                                .fontWeight(.light)
                                .padding(.top, 32)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .background(Color("Section"))
        .navigationBarTitle("Directions")
        .onChange(of: searchText) { newValue in
            self.searchTask?.cancel()
            if self.searchText.isEmpty == false && self.searchText.count >= 3 {
                self.isSearching = true
                self.searchTask = Task {
                    print("Searching for \(self.searchText)")
                    self.searchResults = await StopPointService.DetailedCachedSearch(by: self.searchText)
                    self.isSearching = false
                }
            }
            
        }
    }
}

struct SearchStopResultView: View {
    
    var stop: StopPoint
    
    var body: some View {
        VStack {
            Text(stop.commonName ?? "")
                .bold()
                .font(.title3)
                .multilineTextAlignment(.center)
            
            if (stop.lineIdentifiers?.isEmpty == false) {
                HStack {
                    ForEach(stop.lineIdentifiers ?? [], id: \.lineId) { identifier in
                        identifier.lineIndicator
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(Color("Section2"))
        .cornerRadius(15)
        .shadow(radius: 3)
        .padding(8)
    }
}

struct SearchStopsTextField: View {
    
    var placeHolder: String = ""
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 25, height: 25)
            
            TextField(placeHolder, text: $text)
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 2).foregroundColor(Color.clear)
        )
        .background(
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(Color(UIColor.secondarySystemBackground))
                .shadow(radius: 10)
        )
    }
}
