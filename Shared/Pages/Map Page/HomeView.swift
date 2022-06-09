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
    @StateObject private var mapModel: MapRepresentableViewModel = MapRepresentableViewModel(enableCurrentLocation: true, enableTrackingLocation: false, mapCenter: LocationManager.shared.lastLocation?.coordinate ?? GoLondon.LiverpoolStreetCoord)
    
    @StateObject private var keyboard: KeyboardResponder = KeyboardResponder()
    @Binding var tabBarHeight: CGFloat
    
    @State private var isShowingFilterSheet: Bool = false
    @State private var bottomPaddingFix: CGFloat = 0
    
    @FocusState private var mapPanelFocused: Bool
    @Namespace private var mapSpace
    
    public var body: some View {
        
        GeometryReader { geo in
            ZStack {
                HStack {
                    Spacer()
                    VStack {
                        if self.model.hasMovedFromLastLocation || self.model.isLoading {
                            self.searchHereButton()
                        }
                        
                        if let _ = LocationManager.shared.lastLocation?.coordinate {
                            Button(action: { self.goToCurrentLocation() }) { Text(Image(systemName: "location.circle.fill")) }
                                .buttonStyle(MapButtonStyle())
                                .transition(.move(edge: .leading))
                        }
                        
                        Button(action: { self.isShowingFilterSheet.toggle() }) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                        }
                        .buttonStyle(MapButtonStyle())
                        
                        Button(action: { }) {
                            Image(systemName: "tram.circle")
                        }
                        .buttonStyle(MapButtonStyle())

                        Spacer()
                    }
                    Spacer().frame(width: 16)
                }
                
                VStack {
                    Spacer()
                    self.mapSearchPanel()
                    
                    if self.keyboard.currentHeight != 0 {
                        Spacer().frame(height: 0)
                            .matchedGeometryEffect(id: "mapSpace", in: self.mapSpace)
                    } else {
                        Spacer().frame(height: self.bottomPaddingFix + self.tabBarHeight + 32)
                            .matchedGeometryEffect(id: "mapSpace", in: self.mapSpace)
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingFilterSheet) {
            HomeMapFilterView(viewModel: self.model)
        }
        .background(
            self.mapBackground()
        )
        .onChange(of: self.model.filters) { _ in
            Task {
                if let newMarkers = await self.model.searchForMarkers(at: self.mapModel.mapCenter) {
                    self.mapModel.stopPointMarkers = newMarkers
                }
            }
        }
        .onChange(of: self.mapModel.mapCenter) { newValue in
            self.model.hasMovedFromLastLocation = newValue.distance(to: self.mapModel.mapLastCachedLocation) > 300
        }
        .onChange(of: self.edges.bottom) { newValue in
            if newValue > self.bottomPaddingFix {
                self.bottomPaddingFix = newValue
            }
        }
    }
    
    //MARK: - View Builders
    
    /// View at bottom of page holding map search bar and results
    @ViewBuilder
    func mapSearchPanel() -> some View {
        Spacer()
        MapSearchPanelView(isFocused: $mapPanelFocused)
        Spacer().frame(height: 16)
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
            Button(action: { Task { search() } }) { Image(systemName: "location.magnifyingglass") }
                .buttonStyle(MapButtonStyle())
                .transition(.move(edge: .leading))
        }
    }
    
    @ViewBuilder
    func mapBackground() -> some View {
        MapViewRepresentable(viewModel: mapModel)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                self.search()
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
