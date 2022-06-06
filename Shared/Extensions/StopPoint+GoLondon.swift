//
//  StopPoint+GoLondon.swift
//  Go London (iOS)
//
//  Created by Tom Knighton on 01/04/2022.
//

import Foundation
import GoLondonSDK
import CoreLocation

extension Point {
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: CLLocationDegrees(self.lat ?? 0), longitude: CLLocationDegrees(self.lon ?? 0))
    }
}

extension StopPoint {
    
    var isBusOnly: Bool {
        return self.lineModeGroups?.count == 1 && self.lineModeGroups?.first?.modeName == LineMode.bus
    }
    
    var isBusStand: Bool {
        return self.lineModeGroups?.count == 0 && self.indicator?.hasPrefix("Stand") == true
    }
    
    var mostSignificantLineMode: LineMode? {
        guard var modes = self.lineModeGroups,
              !modes.isEmpty else {
                  return nil
              }
        
        modes.sort { ($0.modeName?.weighting ?? 0) > ($1.modeName?.weighting ?? 0) }
        return modes.first?.modeName
        
    }
    
    var sortedLineModeGroups: [LineModeGroup] {
        guard let modes = self.lineModeGroups,
              !modes.isEmpty else {
                  return []
              }
        
        return modes.sorted { a, b in
            (a.modeName?.weighting ?? 0) > (b.modeName?.weighting ?? 0)
        }.filter { $0.modeName != LineMode.unknown }
    }
    
    var sortedLineModes: [LineMode] {
        guard let modes = self.lineModes,
              !modes.isEmpty else {
                  return []
              }
        
        return modes.sorted { a, b in
            a.weighting > b.weighting
        }.filter { $0 != LineMode.unknown }
    }
}
