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

class MapRepresentableViewModel: ObservableObject {
    
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
        
    init(enableCurrentLocation: Bool, enableTrackingLocation: Bool, mapCenter: CLLocationCoordinate2D, stopPointMarkers: [StopPointAnnotation] = [], forceUpdatePosition: Bool = false, searchedLocation: CLLocationCoordinate2D? = nil) {
                
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
    
    func hideAllDetails(except markerId: String? = nil) {
        for i in self.stopPointMarkers.indices {
            if (markerId != nil) && self.stopPointMarkers[i].id == markerId {
                continue
            }
            self.stopPointMarkers[i].isDetail = false
        }
        
        if let index = self.stopPointMarkers.firstIndex(where: { $0.id == markerId }) {
            self.stopPointMarkers[index].isDetail = true
        }
    }
}
