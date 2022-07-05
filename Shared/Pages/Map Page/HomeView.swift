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
import Introspect

public struct HomeView : View {
    
    @Environment(\.colorScheme) var colourScheme
    @Environment(\.safeAreaInsets) var edges
    
    @StateObject private var mainMapModel: MainMapViewModel = MainMapViewModel(searchRadius: 850, enableCurrentLocation: true, enableTrackingLocation: false, mapCenter: LocationManager.shared.lastLocation?.coordinate ?? GoLondon.LiverpoolStreetCoord)
    @StateObject private var lineMapModel: LineMapViewModel = LineMapViewModel()
    @StateObject private var mapSearchModel: MapSearchPanelViewModel = MapSearchPanelViewModel()
    @StateObject private var keyboard: KeyboardResponder = KeyboardResponder()
    @Binding var tabBarHeight: CGFloat
    
    
    @State private var isShowingLineMap: Bool = false
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
                        
                        Button(action: {  withAnimation { self.isShowingLineMap.toggle() }}) {
                            Image(systemName: "tram.circle")
                        }
                        .buttonStyle(MapButtonStyle())
                        
                        Button(action: { self.isShowingFilterSheet.toggle() }) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                        }
                        .buttonStyle(MapButtonStyle())
                        
                        if self.isShowingLineMap {
                            Button(action: { withAnimation { self.lineMapModel.filterAccessibility.toggle() }}) {
                                Text(Image(systemName: self.lineMapModel.filterAccessibility ? "figure.walk.circle" : "figure.roll"))
                                    .padding(self.lineMapModel.filterAccessibility ? 0 : 1)
                            }
                            .buttonStyle(MapButtonStyle())
                            .transition(.move(edge: .trailing))
                        } else {
                            if let _ = LocationManager.shared.lastLocation?.coordinate {
                                Button(action: { self.goToCurrentLocation() }) { Text(Image(systemName: "location.circle.fill")) }
                                    .buttonStyle(MapButtonStyle())
                                    .transition(.move(edge: .trailing))
                            }
                            
                            if self.mainMapModel.hasMovedFromLastLocation || self.mainMapModel.isSearching {
                                self.searchHereButton()
                                    .animation(.easeInOut, value: self.mainMapModel.hasMovedFromLastLocation || self.mainMapModel.isSearching)
                                    .transition(.move(edge: .trailing))
                            }
                        }
                        
                        Spacer()
                    }
                    Spacer().frame(width: 16)
                }
                
                
                
                VStack(spacing: 0) {
                    Spacer()
                   
                    let hideScroll = self.mainMapModel.selectedPointIndex == nil || !self.mapSearchModel.searchText.isEmpty || !self.mapSearchModel.searchResults.isEmpty
                    if !hideScroll {
                        GeometryReader { geo in
                            SnapCarouselView(items: self.mainMapModel.stopPointMarkers, itemWidth: geo.size.width - 40, selectedIndex: self.$mainMapModel.selectedPointIndex)
                        }
                        .frame(height: 200)
                    }
                    
                    if !self.isShowingLineMap {
                        self.mapSearchPanel()
                            .transition(.move(edge: .bottom))
                    }
                    
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
        .onAppear {
            self.lineMapModel.setup(for: ["elizabeth", "dlr", "london-overground", "central", "bakerloo", "circle", "district", "hammersmith-city", "jubilee", "metropolitan", "northern", "piccadilly", "victoria", "waterloo-city"])
            self.bottomPaddingFix = self.edges.bottom
        }
        .sheet(isPresented: $isShowingFilterSheet) {
            if self.isShowingLineMap {
                LineMapFilterView(viewModel: self.lineMapModel)
            } else {
                HomeMapFilterView(viewModel: self.mainMapModel)
            }
        }
        .background(
            self.mapBackground()
        )
        .onChange(of: self.mainMapModel.filters) { _ in
            Task {
                if let newMarkers = await self.mainMapModel.searchForMarkers(at: self.mainMapModel.mapCenter) {
                    self.mainMapModel.stopPointMarkers = newMarkers
                }
            }
        }
        .onChange(of: self.mainMapModel.mapCenter) { newValue in
            withAnimation {
                self.mainMapModel.hasMovedFromLastLocation = newValue.distance(to: self.mainMapModel.mapLastCachedLocation) > 300
            }
        }
        .onChange(of: self.edges.bottom) { newValue in
            if newValue > self.bottomPaddingFix {
                self.bottomPaddingFix = newValue
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .GL_MAP_CLOSE_DETAIL_VIEWS), perform: { _ in
            withAnimation(.easeInOut) {
                self.mainMapModel.selectedPointIndex = nil
            }
        })
        .onReceive(NotificationCenter.default.publisher(for: .GL_MAP_SHOW_DETAIL_VIEW)) { output in
            if let s = output.object as? StopPoint {
                withAnimation(.easeInOut) {
                    self.mainMapModel.selectedPointIndex = self.mainMapModel.stopPointMarkers.firstIndex(where: { $0.stopPoint.id == s.id }) ?? 7
                }
            }
        }
    }
    
    //MARK: - View Builders
    
    /// View at bottom of page holding map search bar and results
    @ViewBuilder
    func mapSearchPanel() -> some View {
        
        if !self.mainMapModel.isShowingLineMap {
            MapSearchPanelView(isFocused: $mapPanelFocused, model: mapSearchModel)
                .transition(.move(edge: .bottom))
        }
        
        Spacer().frame(height: 16)
    }
    
    @ViewBuilder
    func searchHereButton() -> some View {
        if self.mainMapModel.isSearching {
            Button(action: {}) { ProgressView().progressViewStyle(.circular).foregroundColor(.white) }
                .buttonStyle(MapButtonStyle())
                .transition(.move(edge: .trailing))
        } else {
            Button(action: { Task { search() } }) { Image(systemName: "location.magnifyingglass") }
                .buttonStyle(MapButtonStyle())
                .transition(.move(edge: .trailing))
        }
    }
    
    @ViewBuilder
    func mapBackground() -> some View {
        
        if self.isShowingLineMap {
            LineMapView(viewModel: self.lineMapModel)
                .edgesIgnoringSafeArea(.all)
                .transition(.opacity)
        } else {
            MapViewRepresentable(viewModel: self.mainMapModel)
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    self.search()
                }
                .transition(.opacity)
        }
    }
    
    //MARK: - Functions
    func goToCurrentLocation() {
        if let loc = LocationManager.shared.lastLocation?.coordinate {
            withAnimation {
                self.mainMapModel.mapCenter = loc
                self.mainMapModel.forceUpdatePosition = true
                self.mainMapModel.hasMovedFromLastLocation = false
                self.mainMapModel.mapLastCachedLocation = loc
                self.search()
            }
        }
    }
    
    func search() {
        Task { [weak mainMapModel] in
            guard let center = mainMapModel?.mapCenter else {
                return
            }
            
            mainMapModel?.setSearchedLocation(to: center)

            if let newMarkers = await mainMapModel?.searchForMarkers(at: center) {
                mainMapModel?.stopPointMarkers = newMarkers
            }

            withAnimation {
                mainMapModel?.updateCenter(to: center)
                mainMapModel?.hasMovedFromLastLocation = false
            }
        }
    }
}
