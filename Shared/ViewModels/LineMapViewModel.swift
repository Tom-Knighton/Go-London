//
//  LineMapViewModel.swift
//  Go London
//
//  Created by Tom Knighton on 22/05/2022.
//

import Foundation
import GoLondonSDK
import Combine
import SwiftUI

public struct LineMapFilter: Codable, Equatable {
    
    let lineId: String
    var toggled: Bool
}

@MainActor
public class LineMapViewModel: ObservableObject {
    
    @Published var lineIds: [String] = []
    @Published var lineFilters: [LineMapFilter] = []
    @Published var cachedLineFilters: [LineMapFilter] = []
    
    @Published var lineRoutes: [LineRoutes] = []
    @Published var cachedLineRoutes: [LineRoutes] = []
    
    @Published var mapStyle: MapStyle = .LinesDark
    @Published var cachedMapStyle: MapStyle = .LinesDark
    
    @Published var filterAccessibility: Bool = false
    @Published var cachedFilterAccessibility: Bool = false
    
    private var cancelSet: Set<AnyCancellable> = []
    
    var isViewingSingleLine: Bool {
        lineRoutes.count == 1
    }
    
    init() {
        print("INIT Line")
        self.mapStyle = .LinesDark
    }
    
    public func setup(for lineIds: [String], filterAccessibility: Bool = false) {
        self.lineIds = lineIds

        if lineIds.count > 2 {
            self.lineFilters = GoLondon.lineMapFilterCache
            self.cachedLineFilters = GoLondon.lineMapFilterCache
        } else {
            self.lineFilters = lineIds.compactMap { LineMapFilter(lineId: $0, toggled: true) }
            self.cachedLineFilters = lineIds.compactMap { LineMapFilter(lineId: $0, toggled: true) }
        }


        self.filterAccessibility = filterAccessibility

        self.mapStyle = UITraitCollection.current.userInterfaceStyle == .dark ? .LinesDark : .LinesLight
        
        NotificationCenter.default.publisher(for: .OS_COLOUR_SCHEME_CHANGE)
            .compactMap { $0.userInfo }
            .sink { [weak self] userInfo in
                guard let scheme = userInfo["scheme"] as? ColorScheme else {
                    return
                }
                self?.mapStyle = scheme == .dark ? .LinesDark : .LinesLight
            }
            .store(in: &cancelSet)
    }
    
    deinit {
        print("****DEINIT Line")
    }
    
    
    /// Returns the accessibility type for the station
    /// - Parameter stopName: The complete name of the stop point
    /// - Remark: Will return none if there is no accessibility data
    /// - Remark: Will return the overview if more than one line is being rendered
    func getAccessibilityType(for stopName: String) -> StationAccessibilityType {
        
        let data = GlobalViewModel.shared
        
        let stopName = stopName.replacingOccurrences(of: "Underground", with: "").replacingOccurrences(of: "Station", with: "").replacingOccurrences(of: "Rail", with: "").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        guard let accessibleData = data.lradData.first(where: { $0.stationName == stopName }) else {
            print("No accessible data for \(stopName)")
            return .None
        }
        
        var accessibility: StationAccessibilityType = .None
        if self.isViewingSingleLine, let lineId = self.lineRoutes.first?.lineId {
            let lineData = accessibleData.lineAccessibility?.first(where: { LineMode.friendlyTubeLineName(for: lineId ) == $0.lineName ?? "" })
            
            accessibility = lineData?.accessibility ?? .None
        } else {
            accessibility = accessibleData.overviewAccessibility ?? .None
        }
        
        return accessibility
    }
        
    func toggleLine(lineId: String, to val: Bool) {
        if let index = self.lineFilters.firstIndex(where: { $0.lineId == lineId }) {
            withAnimation {
                self.lineFilters[index].toggled = val
            }
        }
    }
    
    func fetchToggledRoutes() async {
        Task {
            self.lineRoutes = await GlobalViewModel.shared.routesFor(self.lineFilters.filter { $0.toggled }.compactMap { $0.lineId })
        }
    }
    
    //MARK: - Update Cache
    func updateCachedRoutes() {
        self.cachedLineRoutes = self.lineRoutes
    }
    
    func updateCachedStyle() {
        self.cachedMapStyle = self.mapStyle
    }
    
    func updateCachedAccessibility(to val: Bool) {
        self.cachedFilterAccessibility = val
    }
}
