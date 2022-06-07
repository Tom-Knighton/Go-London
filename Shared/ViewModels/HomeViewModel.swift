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

class HomeViewModel: ObservableObject {
    
    @Published var radius: Float
    @Published var filters: LineModeFilters
    @Published var isLoading: Bool
    @Published var searchText: String = ""
    @Published var hasMovedFromLastLocation: Bool = false
    
    class LineModeFilters: ObservableObject, Equatable {
        static func == (lhs: HomeViewModel.LineModeFilters, rhs: HomeViewModel.LineModeFilters) -> Bool {
            lhs.filters == rhs.filters
        }
        
        struct Filter: Identifiable, Equatable, Hashable {
            var lineMode: LineMode
            var toggled: Bool = true
            
            var id: String { lineMode.rawValue + String(toggled) }
        }
        
        @Published var filters: [Filter] = []
        
        init(_ lineModes: [LineMode]) {
            self.filters = lineModes.map { Filter(lineMode: $0) }
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
    
    private static var defaultFilters: LineModeFilters =  LineModeFilters([LineMode.bus, LineMode.elizabethLine, LineMode.tube, LineMode.overground, LineMode.nationalRail, LineMode.dlr])
    
    var anyCancellable: AnyCancellable? = nil
    
    init(radius: Float = 1000, filters: LineModeFilters = defaultFilters) {
        self.radius = radius
        self.filters = filters
        self.isLoading = false
        
        anyCancellable = self.filters.objectWillChange.sink { [weak self] (_) in
            self?.objectWillChange.send()
        }
        
    }
    
    func toggleLineModeFilter(_ lineMode: LineMode) {
        self.filters.toggleFilter(lineMode)
    }
    
    func isFilterToggled(_ lineMode: LineMode) -> Bool {
        return self.filters.isToggled(lineMode)
    }
    
    func searchForMarkers(at location: CLLocationCoordinate2D) async -> [StopPointAnnotation]? {
        guard !isLoading else { return nil }
        
        self.isLoading = true
        let nearbyPoints = await GLSDK.Search.SearchAround(latitude: location.latitude, longitude: location.longitude, filterBy: self.filters.getAllToggled(), radius: Int(self.radius))
        
        var markers: [StopPointAnnotation] = []

        for point in nearbyPoints.reversed() {
            if let point = point as? StopPoint,
               point.lineModeGroups?.isEmpty == false {
                markers.append(StopPointAnnotation(stopPoint: point))
            }
        }
        
        DispatchQueue.main.async {
            self.isLoading = false
        }
        
        return markers
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
