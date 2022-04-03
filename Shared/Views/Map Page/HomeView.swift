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
    
    @ObservedObject private var model: MainMapViewModel = MainMapViewModel(centerLocation: LocationManager.shared.lastLocation?.coordinate ?? GoLondon.LiverpoolStreetCoord)
    
    private var mapboxStyleURI: Binding<StyleURI> { Binding(get: { colourScheme == .dark ? GoLondon.GetDarkStyleURL() : GoLondon.GetLightStyleURL()}, set: { _ in })}
    
    @State private var searchText: String = ""
    @State private var hasMovedFromCenter: Bool = false
    @State var cachedCenter: CLLocationCoordinate2D?
    @State private var shouldForceUpdateMap = false
    
    public var body: some View {
        ZStack {
            MapViewRepresentable(mapStyleURI: mapboxStyleURI, mapCenter: $model.centerLocation, markers: $model.nearbyMarkers, enableCurrentLocation: true, forceUpdatePosition: $shouldForceUpdateMap)
                .onAppear {
                    search()
                }
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer().frame(height: 16)
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        
                        if hasMovedFromCenter {
                            Button(action: {}) { Text("Search Here") }
                                .buttonStyle(MapButtonStyle())
                                .transition(.move(edge: .leading))
                        }
                        
                        if let _ = LocationManager.shared.lastLocation?.coordinate {
                            Button(action: { self.goToCurrentLocation() }) { Text(Image(systemName: "location.circle.fill")) }
                                .buttonStyle(MapButtonStyle())
                                .transition(.move(edge: .leading))
                        }
                        
                        ForEach(self.model.filters.filters, id: \.lineMode) { modeFilter in
                            withAnimation(.easeInOut) {
                                Button(action: { self.model.toggleLineModeFilter(modeFilter.lineMode) }) {
                                    HStack {
                                        Text(Image(systemName: self.model.isFilterToggled(modeFilter.lineMode) ? "checkmark" : "xmark"))
                                            .bold()
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
                
                MapSearchPanelView(searchText: $searchText)
                    .transition(.slide)
            }
        }
        .onChange(of: self.model.filters.filters) { _ in
            Task {
                await self.model.searchForMarkers()
            }
        }
        .onChange(of: self.model.centerLocation) { newValue in
            if let cached = self.cachedCenter {
                if newValue.distance(to: cached) > 300 {
                    self.hasMovedFromCenter = true
                    self.cachedCenter = newValue
                }
            } else {
                self.cachedCenter = newValue
            }
        }
    }
    
    func goToCurrentLocation() {
        if let loc = LocationManager.shared.lastLocation?.coordinate {
            self.model.centerLocation = loc
            self.shouldForceUpdateMap = true
            self.hasMovedFromCenter = false
            self.cachedCenter = loc
            self.search()
        }
    }
    
    func search() {
        Task {
            await self.model.searchForMarkers()
            self.hasMovedFromCenter = false
        }
    }
}
