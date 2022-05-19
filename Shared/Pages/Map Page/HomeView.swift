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
    @Environment(\.safeAreaInsets) var edges
    
    @StateObject private var model: HomeViewModel = HomeViewModel(radius: 850)

    @StateObject private var mapModel: MapRepresentableViewModel = MapRepresentableViewModel(styleURI: GoLondon.GetDarkStyleURL(), enableCurrentLocation: true, enableTrackingLocation: false, mapCenter: LocationManager.shared.lastLocation?.coordinate ?? GoLondon.LiverpoolStreetCoord)
    
    @StateObject private var keyboard: KeyboardResponder = KeyboardResponder()
    
    @Binding var tabBarHeight: CGFloat
    
    public var body: some View {
        
        GeometryReader { geo in
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        if self.model.hasMovedFromLastLocation {
                            self.searchHereButton()
                        }
                        
                        if let _ = LocationManager.shared.lastLocation?.coordinate {
                            Button(action: { self.goToCurrentLocation() }) { Text(Image(systemName: "location.circle.fill")) }
                                .buttonStyle(MapButtonStyle())
                                .transition(.move(edge: .leading))
                        }
                        
                        self.filterButtons()
                        
                    }
                    .padding(.horizontal, 16)
                }
                .frame(maxWidth: .infinity,  minHeight: 60, maxHeight: 60)
                
                self.mapSearchPanel()
            }
           
        }
        .background(
            self.mapBackground()
        )
        .onChange(of: self.model.filters.filters) { _ in
            Task {
                await self.model.searchForMarkers(at: mapModel.mapCenter)
            }
        }
        .onChange(of: self.mapModel.mapCenter) { newValue in
            self.model.hasMovedFromLastLocation = newValue.distance(to: self.mapModel.mapLastCachedLocation) > 300
        }
    }
    
    //MARK: - View Builders
    
    /// View at bottom of page holding map search bar and results
    @ViewBuilder
    func mapSearchPanel() -> some View {
        Spacer()
        MapSearchPanelView()
        Spacer().frame(height: max(16, keyboard.currentHeight - self.tabBarHeight + 16))
    }
    
    ///  A series of buttons containing filters for a TfL map search
    @ViewBuilder
    func filterButtons() -> some View {
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
    
    @ViewBuilder
    func searchHereButton() -> some View {
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
    
    @ViewBuilder
    func mapBackground() -> some View {
        MapViewRepresentable(viewModel: mapModel)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                self.mapModel.styleURI = colourScheme == .dark ? GoLondon.GetDarkStyleURL() : GoLondon.GetLightStyleURL()
                search()
            }
            .onChange(of: colourScheme) { newValue in
                self.mapModel.styleURI = newValue == .dark ? GoLondon.GetDarkStyleURL() : GoLondon.GetLightStyleURL()
            }
    }
    
    //MARK: - Functions
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
