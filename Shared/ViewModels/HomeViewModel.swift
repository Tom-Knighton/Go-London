//
//  MainMapViewModel.swift
//  Go London (iOS)
//
//  Created by Tom Knighton on 31/03/2022.
//

import Foundation
import CoreLocation
import GoLondonSDK
import Combine
import SwiftUI

@MainActor
public class HomeViewModel: ObservableObject {
    
    @Published var radius: Float
    @Published var filters: LineModeFilters
    @Published var isLoading: Bool
    @Published var searchText: String = ""
    @Published var hasMovedFromLastLocation: Bool = false
    @Published var isShowingLineMap: Bool = false
    
    public class LineModeFilters: ObservableObject, Equatable {
        
        public static func == (lhs: HomeViewModel.LineModeFilters, rhs: HomeViewModel.LineModeFilters) -> Bool {
            lhs.filters == rhs.filters
        }
        
        struct Filter: Identifiable, Equatable, Codable {
            var lineMode: LineMode
            var toggled: Bool = true
            
            var id: String { lineMode.rawValue + String(toggled) }
        }
        
        @Published var filters: [Filter] = []
        
        init(_ lineModes: [LineMode]) {
            self.filters = lineModes.map { Filter(lineMode: $0) }
        }
        
        init (filters: [Filter]) {
            self.filters = filters
        }
        
        func toggleFilter(_ lineMode: LineMode) {
            if let index = self.filters.firstIndex(where: { $0.lineMode == lineMode }) {
                self.filters[index].toggled.toggle()
            }
        }
        
        func isToggled(_ lineMode: LineMode) -> Bool {
            return self.filters.first(where: { $0.lineMode == lineMode})?.toggled ?? false
        }
        
        func getAllToggled() -> [LineMode] {
            return (self.filters.filter { $0.toggled }).compactMap { $0.lineMode}
        }
        
        func makeTempStructs() -> [HomeMapFilterToggle] {
            let temps = self.filters.compactMap { HomeMapFilterToggle(from: $0, as: $0.toggled)}
            return temps
        }
    }
        
    var anyCancellable: AnyCancellable? = nil
    
    init(radius: Float = 1000) {
        self.radius = radius
        self.filters = GoLondon.homeFilterCache
        self.isLoading = false
        
        anyCancellable = self.filters.objectWillChange.sink { [weak self] (_) in
            self?.objectWillChange.send()
        }
        
    }
    
    deinit {
        print("****DEINIT: HomeViewModel")
    }
    
    func toggleLineModeFilter(_ lineMode: LineMode) {
        self.filters.toggleFilter(lineMode)
    }
    
    func isFilterToggled(_ lineMode: LineMode) -> Bool {
        return self.filters.isToggled(lineMode)
    }
    
    func searchForMarkers(at location: CLLocationCoordinate2D) async -> [StopPointAnnotation]? {
        guard !isLoading else { return nil }
 
        self.toggleIsLoading(to: true)
        
        let nearbyPoints = await GLSDK.Search.SearchAround(latitude: location.latitude, longitude: location.longitude, filterBy: self.filters.getAllToggled(), radius: Int(self.radius))
        
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
        
        self.toggleIsLoading(to: false)
        
        return markers
    }
    
    private func toggleIsLoading(to val: Bool) {
        withAnimation {
            self.isLoading = val
        }
    }
}

class HomeMapFilterToggle: ObservableObject {
    
    @Published var filter: HomeViewModel.LineModeFilters.Filter
    
    @Published var tempStatus: Bool
    
    init(from filter: HomeViewModel.LineModeFilters.Filter, as val: Bool) {
        
        self.filter = filter
        self.tempStatus = val
    }
    
}
