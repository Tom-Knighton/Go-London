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
    
    @Published var lineId: String = ""
    
    @Published var lineRoutes: [LineRoutes] = []
    @Published var cachedLineRoutes: [LineRoutes] = []
    
    @Published var mapStyle: MapStyle = .LinesDark
    @Published var cachedMapStyle: MapStyle = .LinesDark
    
    private var cancelSet: Set<AnyCancellable> = []
        
    func setup(for lineId: String) {
        self.lineId = lineId
        
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
            if let routes = await GLSDK.Lines.Routes(for: self.lineId) {
                self.lineRoutes = [routes]
            }
        }
    }
    
    //MARK: - Update Cache
    func updateCachedRoutes() {
        self.cachedLineRoutes = self.lineRoutes
    }
    
    func updateCachedStyle() {
        self.cachedMapStyle = self.mapStyle
    }
}