//
//  LineMode+GoLondon.swift
//  Go London (iOS)
//
//  Created by Tom Knighton on 31/03/2022.
//

import Foundation
import GoLondonSDK
import SwiftUI

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
    
    @ViewBuilder
    var image: some View {
        switch self {
        case .bus:
            Image("tfl")
                .resizable()
                .foregroundColor(.red)
        case .dlr:
            Image("nationalrail")
                .resizable()
                .foregroundColor(.init(hex: "#00A4A7"))
        case .nationalRail:
            Image("nationalrail")
                .resizable()
                .foregroundColor(.red)
        case .overground:
            Image("tfl")
                .resizable()
                .foregroundColor(.orange)
        case .tube:
            Image("tube")
                .resizable()
                .foregroundColor(.red)
        case .tflrail:
            Image("tfl")
                .resizable()
                .foregroundColor(.blue)
        default:
            Image("tfl")
                .resizable()
                .foregroundColor(.red)
        }
    }
    
    var weighting: Int {
        switch self {
        case .bus:
            return 0
        case .dlr:
            return 1
        case .nationalRail:
            return 2
        case .overground:
            return 3
        case .replacementBus:
            return -1
        case .tube:
            return 4
        case .tflrail:
            return 5
        }
    }
}
