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

@MainActor
final class LineMapViewModel: ObservableObject {
    
    @Published var lineIds: [String] = []
    
    @Published var lineRoutes: [LineRoutes] = []
    @Published var cachedLineRoutes: [LineRoutes] = []
    
    @Published var mapStyle: MapStyle = .LinesDark
    @Published var cachedMapStyle: MapStyle = .LinesDark
    
    @Published var cachedFilterAccessibility: Bool = false
    
    private var cancelSet: Set<AnyCancellable> = []
        
    func setup(for lineIds: [String]) {
        self.lineIds = lineIds
        
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
    
    func fetchStopPoints() async {
        Task {
            self.lineRoutes = await GLSDK.Lines.Routes(for: self.lineIds, fixCoordinates: false)
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
