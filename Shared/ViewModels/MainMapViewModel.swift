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

class MainMapViewModel: ObservableObject {
    
    @Published var centerLocation: CLLocationCoordinate2D
    @Published var radius: Float
    @Published var filters: LineModeFilters
    @Published var nearbyMarkers: [StopPointAnnotation]
    
    class LineModeFilters: ObservableObject, Equatable {
        static func == (lhs: MainMapViewModel.LineModeFilters, rhs: MainMapViewModel.LineModeFilters) -> Bool {
            lhs.filters == rhs.filters
        }
        
        struct Filter: Identifiable, Equatable {
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
    }
    
    private static var defaultFilters: LineModeFilters =  LineModeFilters([LineMode.bus, LineMode.tflrail, LineMode.tube, LineMode.overground, LineMode.nationalRail, LineMode.dlr])
    
    var anyCancellable: AnyCancellable? = nil
    
    init(centerLocation: CLLocationCoordinate2D, radius: Float = 1000, filters: LineModeFilters = defaultFilters) {
        self.centerLocation = centerLocation
        self.radius = radius
        self.filters = filters
        self.nearbyMarkers = []
        
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
    
    func searchForMarkers() async {
        let nearbyPoints = await GLSDK.Search.SearchAround(latitude: self.centerLocation.latitude, longitude: self.centerLocation.longitude, filterBy: self.filters.getAllToggled(), radius: Int(self.radius))
        DispatchQueue.main.async {
            self.nearbyMarkers.removeAll()
            for point in nearbyPoints.reversed() {
                if let point = point as? StopPoint {
                    self.nearbyMarkers.append(StopPointAnnotation(stopPoint: point))
                }
            }
        }
    }
}
