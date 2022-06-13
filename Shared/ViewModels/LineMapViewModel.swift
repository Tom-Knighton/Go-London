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
final class LineMapViewModel: ObservableObject {
    
    @Published var lineIds: [String] = []
    @Published var lineFilters: [LineMapFilter]
    @Published var cachedLineFilters: [LineMapFilter]
    
    @Published var lineRoutes: [LineRoutes] = []
    @Published var cachedLineRoutes: [LineRoutes] = []
    
    @Published var mapStyle: MapStyle = .LinesDark
    @Published var cachedMapStyle: MapStyle = .LinesDark
    
    @Published var filterAccessibility: Bool = false
    @Published var cachedFilterAccessibility: Bool = false
    
    private var cancelSet: Set<AnyCancellable> = []
    
    
    public init(for lineIds: [String], filterAccessibility: Bool = false) {
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
            .sink { userInfo in
                guard let scheme = userInfo["scheme"] as? ColorScheme else {
                    return
                }
                self.mapStyle = scheme == .dark ? .LinesDark : .LinesLight
            }
            .store(in: &cancelSet)
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
            self.lineRoutes = await GLSDK.Lines.Routes(for: self.lineFilters.filter { $0.toggled }.compactMap { $0.lineId }, fixCoordinates: false)
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
