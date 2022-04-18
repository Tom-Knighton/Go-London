//
//  MapRepresentableViewModel.swift
//  Go London
//
//  Created by Tom Knighton on 17/04/2022.
//

import Foundation
import SwiftUI
import MapboxMaps

class MapRepresentableViewModel: ObservableObject {
    
    @Published var styleURI: StyleURI
    @Published var internalCacheStyle: StyleURI
    
    @Published var enableCurrentLocation: Bool
    @Published var enableTrackingLocation: Bool
    
    @Published var mapCenter: CLLocationCoordinate2D
    @Published var mapLastCachedLocation: CLLocationCoordinate2D
    
    @Published var stopPointMarkers: [StopPointAnnotation]
    @Published var internalCachedStopPointMarkers: [StopPointAnnotation]
    
    @Published var forceUpdatePosition: Bool
    
    @Published var searchedLocation: CLLocationCoordinate2D?
        
    init(styleURI: StyleURI, enableCurrentLocation: Bool, enableTrackingLocation: Bool, mapCenter: CLLocationCoordinate2D, stopPointMarkers: [StopPointAnnotation] = [], forceUpdatePosition: Bool = false, searchedLocation: CLLocationCoordinate2D? = nil) {
        
        self.styleURI = styleURI
        self.internalCacheStyle = styleURI
        
        self.enableCurrentLocation = enableCurrentLocation
        self.enableTrackingLocation = enableTrackingLocation
        
        self.mapCenter = mapCenter
        self.mapLastCachedLocation = mapCenter
        
        self.stopPointMarkers = stopPointMarkers
        self.internalCachedStopPointMarkers = stopPointMarkers
        
        self.forceUpdatePosition = forceUpdatePosition
        
        self.searchedLocation = searchedLocation
    }
    
    var markersOutOfSync: Bool {
        return self.internalCachedStopPointMarkers != self.stopPointMarkers
    }
    
    func updateCenter(to location: CLLocationCoordinate2D) {
        self.mapCenter = location
    }
    
    func updateCacheStyle() {
        self.internalCacheStyle = self.styleURI
    }
    
    func setSearchedLocation(to location: CLLocationCoordinate2D) {
        self.searchedLocation = location
    }
    
    func updateCacheMarkers() {
        self.internalCachedStopPointMarkers = self.stopPointMarkers
    }
    
    func updateStyleURI(to uri: StyleURI) {
        self.styleURI = uri
    }
}
