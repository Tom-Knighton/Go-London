//
//  HomeView.swift
//  Go London
//
//  Created by Tom Knighton on 23/03/2022.
//

import Foundation
import SwiftUI
import MapboxMaps
import GoLondonSDK

public struct HomeView : View {
    
    @Environment(\.colorScheme) var colourScheme
    
    @ObservedObject var model: MainMapViewModel = MainMapViewModel(centerLocation: LocationManager.shared.lastLocation?.coordinate ?? GoLondon.LiverpoolStreetCoord)
    
    var mapboxStyleURI: Binding<StyleURI> { Binding(get: { colourScheme == .dark ? GoLondon.GetDarkStyleURL() : GoLondon.GetLightStyleURL()}, set: { _ in })}
    
    public var body: some View {
        ZStack {
            MapViewRepresentable(mapStyleURI: mapboxStyleURI, mapCenter: $model.centerLocation, markers: $model.nearbyMarkers, enableCurrentLocation: true)
                .onAppear {
                    search()
                }
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer().frame(height: 16)
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        Button(action: {}) { Text("Test") }
                        .buttonStyle(MapButtonStyle())
                        
                        ForEach(self.model.filters.filters, id: \.lineMode) { modeFilter in
                            withAnimation(.easeInOut) {
                                Button(action: { self.model.toggleLineModeFilter(modeFilter.lineMode) }) {
                                    HStack {
                                        Text(Image(systemName: self.model.isFilterToggled(modeFilter.lineMode) ? "checkmark" : "xmark")).bold()
                                        Text(modeFilter.lineMode.friendlyName)
                                    }
                                }
                                .buttonStyle(MapButtonStyle(backgroundColor: self.model.isFilterToggled(modeFilter.lineMode) ? .green : .red))
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .frame(maxWidth: .infinity, maxHeight: 60)
                Spacer()
            }
        }
        .onChange(of: self.model.filters.filters) { _ in
            Task {
                print("hmmm")
                await self.model.searchForMarkers()
            }
        }
    }
    
    func search() {
        Task {
            await self.model.searchForMarkers()
        }
    }
}
