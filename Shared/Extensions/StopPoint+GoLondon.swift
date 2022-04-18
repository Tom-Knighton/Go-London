//
//  StopPoint+GoLondon.swift
//  Go London (iOS)
//
//  Created by Tom Knighton on 01/04/2022.
//

import Foundation
import GoLondonSDK

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
}
