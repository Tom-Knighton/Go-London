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
    
    @ObservedObject private var model: HomeViewModel = HomeViewModel(radius: 850)

    @StateObject private var mapModel: MapRepresentableViewModel = MapRepresentableViewModel(styleURI: GoLondon.GetDarkStyleURL(), enableCurrentLocation: true, enableTrackingLocation: false, mapCenter: LocationManager.shared.lastLocation?.coordinate ?? GoLondon.LiverpoolStreetCoord)

    public var body: some View {
        ZStack {
            MapViewRepresentable(viewModel: mapModel)
                .onAppear {
                    self.mapModel.styleURI = colourScheme == .dark ? GoLondon.GetDarkStyleURL() : GoLondon.GetLightStyleURL()
                    search()
                }
                .edgesIgnoringSafeArea(.all)
                .onChange(of: colourScheme) { newValue in
                    self.mapModel.styleURI = newValue == .dark ? GoLondon.GetDarkStyleURL() : GoLondon.GetLightStyleURL()
                }
            
            VStack {
                Spacer().frame(height: 16)
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        if self.model.hasMovedFromLastLocation {
                            if self.model.isLoading {
                                Button(action: {}) { ProgressView().progressViewStyle(.circular).foregroundColor(.white) }
                                    .buttonStyle(MapButtonStyle())
                                    .transition(.move(edge: .leading))
                            } else {
                                Button(action: { Task { search() } }) { Text("Search Here") }
                                    .buttonStyle(MapButtonStyle())
                                    .transition(.move(edge: .leading))
                            }
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
                
                MapSearchPanelView(searchText: $model.searchText)
                    .transition(.slide)
            }
        }
        .onChange(of: self.model.filters.filters) { _ in
            Task {
                await self.model.searchForMarkers(at: mapModel.mapCenter)
            }
        }
        .onChange(of: self.mapModel.mapCenter) { newValue in
            self.model.hasMovedFromLastLocation = newValue.distance(to: self.mapModel.mapLastCachedLocation) > 300
        }
    }
    
    func goToCurrentLocation() {
        if let loc = LocationManager.shared.lastLocation?.coordinate {
            self.mapModel.mapCenter = loc
            self.mapModel.forceUpdatePosition = true
            self.model.hasMovedFromLastLocation = false
            self.mapModel.mapLastCachedLocation = loc
            self.search()
        }
    }
    
    func search() {
        Task {
            if let newMarkers = await self.model.searchForMarkers(at: self.mapModel.mapCenter) {
                self.mapModel.stopPointMarkers = newMarkers
            }
            
            self.mapModel.updateCenter(to: self.mapModel.mapCenter)
            self.model.hasMovedFromLastLocation = false
        }
    }
}
