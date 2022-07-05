//
//  MapRepresentableViewModel.swift
//  Go London
//
//  Created by Tom Knighton on 17/04/2022.
//

import Foundation
import SwiftUI
import MapboxMaps
import MapKit
import Combine
import GoLondonSDK

public struct MainMapFilter: Codable, Equatable {
    public static func == (lhs: MainMapFilter, rhs: MainMapFilter) -> Bool {
        lhs.lineMode.friendlyName == rhs.lineMode.friendlyName && lhs.toggled == rhs.toggled
    }
    
    var lineMode: LineMode
    var toggled: Bool = true
}

@MainActor
class MainMapViewModel: ObservableObject {
    
    @Published var searchRadius: Float = 850
    @Published var filters: [MainMapFilter]
    
    @Published var isSearching: Bool
    @Published var searchText: String = ""
    @Published var hasMovedFromLastLocation: Bool = false
    @Published var isShowingLineMap: Bool = false
    
    @Published var mapStyle: MapStyle
    @Published var internalCacheStyle: MapStyle
    
    @Published var enableCurrentLocation: Bool
    @Published var enableTrackingLocation: Bool
    
    @Published var mapCenter: CLLocationCoordinate2D
    @Published var mapLastCachedLocation: CLLocationCoordinate2D
    @Published var mapRegion: MKCoordinateRegion
    
    @Published var stopPointMarkers: [StopPointAnnotation]
    @Published var internalCachedStopPointMarkers: [StopPointAnnotation]
    
    @Published var forceUpdatePosition: Bool
    
    @Published var searchedLocation: CLLocationCoordinate2D?
    
    @Published var selectedPointIndex: Int?
    
    private var cancellable: AnyCancellable?
        
    init(searchRadius: Float, enableCurrentLocation: Bool, enableTrackingLocation: Bool, mapCenter: CLLocationCoordinate2D, stopPointMarkers: [StopPointAnnotation] = [], forceUpdatePosition: Bool = false, searchedLocation: CLLocationCoordinate2D? = nil) {
                
        self.searchRadius = searchRadius
        self.enableCurrentLocation = enableCurrentLocation
        self.enableTrackingLocation = enableTrackingLocation
        
        self.mapCenter = mapCenter
        self.mapLastCachedLocation = mapCenter
        self.mapRegion = MKCoordinateRegion(center: mapCenter, span: MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015))
        
        self.stopPointMarkers = stopPointMarkers
        self.internalCachedStopPointMarkers = stopPointMarkers
        
        self.forceUpdatePosition = forceUpdatePosition
        
        self.searchedLocation = searchedLocation
        
        self.internalCacheStyle = .DefaultDark
        self.mapStyle = UITraitCollection.current.userInterfaceStyle == .dark ? .DefaultDark : .DefaultLight
        
        self.filters = GoLondon.homeFilterCache
        self.isSearching = false
        
        cancellable = NotificationCenter.default.publisher(for: .OS_COLOUR_SCHEME_CHANGE)
            .compactMap { $0.userInfo }
            .sink { [weak self] userInfo in
                guard let scheme = userInfo["scheme"] as? ColorScheme else {
                    return
                }
                self?.mapStyle = scheme == .dark ? .DefaultDark : .DefaultLight
            }
    }
    
    deinit {
        print("****DEINIT: MapRepresentable")
    }
    
    var markersOutOfSync: Bool {
        return self.internalCachedStopPointMarkers != self.stopPointMarkers
    }
    
    func updateCenter(to location: CLLocationCoordinate2D) {
        self.mapCenter = location
    }
    
    func updateCacheStyle() {
        self.internalCacheStyle = self.mapStyle
    }
    
    func setSearchedLocation(to location: CLLocationCoordinate2D) {
        self.searchedLocation = location
    }
    
    func updateCacheMarkers() {
        self.internalCachedStopPointMarkers = self.stopPointMarkers
    }
}

//MARK: - Searching
extension MainMapViewModel {
    func searchForMarkers(at location: CLLocationCoordinate2D) async -> [StopPointAnnotation]? {
        guard !isSearching else { return nil }
 
        self.toggleIsSearching(to: true)
        
        let nearbyPoints = await GLSDK.Search.SearchAround(latitude: location.latitude, longitude: location.longitude, filterBy: self.getToggledLineModes(), radius: Int(self.searchRadius))
        
        var markers: [StopPointAnnotation] = []

        
        var nearbyStopPoints: [StopPoint] = nearbyPoints.filter { $0 is StopPoint }.compactMap { $0 as? StopPoint}
        
        
        // First remove all stop points that are not only bus stops
        var weightedElements = nearbyStopPoints.filter { ($0.lineModes?.compactMap { $0.weighting }.reduce(0, +) ?? -1) > 0 }
        nearbyStopPoints = Array(Set(nearbyStopPoints).subtracting(weightedElements))
        
        
        // If we have access to location, then sort all points by distance to user
        let locationManager = LocationManager.shared
        if let location = locationManager.lastLocation {
            nearbyStopPoints = nearbyStopPoints.sorted(by: { $0.coordinate.distance(to: location.coordinate) < $1.coordinate.distance(to: location.coordinate)})
            
            weightedElements = weightedElements.sorted(by: { $0.coordinate.distance(to: location.coordinate) < $1.coordinate.distance(to: location.coordinate)})
        }
        
        // Add back in other (now sorted) stops at end of array
        nearbyStopPoints.append(contentsOf: weightedElements)

        for point in nearbyStopPoints {
            if point.lineModeGroups?.isEmpty == false {
                markers.append(StopPointAnnotation(stopPoint: point))
            }
        }
        
        self.toggleIsSearching(to: false)
        
        return markers
    }
    
    private func toggleIsSearching(to val: Bool) {
        withAnimation {
            self.isSearching = val
        }
    }
}

//MARK: - Filters
extension MainMapViewModel {
    func toggleLineModeFilter(_ lineMode: LineMode, to val: Bool) {
        if let index = self.filters.firstIndex(where: { $0.lineMode == lineMode }) {
            withAnimation {
                self.filters[index].toggled = val
                
            }
        }
    }
    
    func getToggledLineModes() -> [LineMode] {
        return self.filters.filter { $0.toggled }.compactMap { $0.lineMode }
    }
}

