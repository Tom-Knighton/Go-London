//
//  LineMode+GoLondon.swift
//  Go London (iOS)
//
//  Created by Tom Knighton on 31/03/2022.
//

import Foundation
import GoLondonSDK

extension LineMode {
    
    
    /// Returns a 'friendly' name for a LineMode, i.e 'TfL Rail' for LineMode.tflrail
    /// - Remark: Preferred over LineMode.rawValue as rawValue is used for the API and will return non-friendly values like 'tfl-rail'
    var friendlyName: String {
        switch self {
        case .bus:
            return "Bus"
        case .dlr:
            return "DLR"
        case .nationalRail:
            return "National Rail Services"
        case .overground:
            return "Overground"
        case .replacementBus:
            return "Replacement Bus Service"
        case .tflrail:
            return "TfL Rail"
        case .tube:
            return "Tube"
        }
    }
}
