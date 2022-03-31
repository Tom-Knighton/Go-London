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
        return self.lineModeGroups?.count == 1 && self.lineModeGroups?.first?.modeName == LineMode.bus.rawValue
    }
    
    var isBusStand: Bool {
        return self.lineModeGroups?.count == 0 && self.indicator?.hasPrefix("Stand") == true
    }
}
