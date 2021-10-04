//
//  Disruption.swift
//  GaryTube (iOS)
//
//  Created by Tom Knighton on 01/10/2021.
//

import Foundation

struct Disruption: Codable {
    let category: String?
    let type: String?
    let categoryDescription: String?
    let description: String?
    let created: Date?
    let lastUpdate: String?
    
    enum DelayType {
        case none, MinorDelays, SevereDelays, PlannedClosure
        
        var DisplayValue: String {
            switch self {
            case .MinorDelays:
                return "Minor Delays"
            case .SevereDelays:
                return "Severe Delays"
            case .PlannedClosure:
                return "Closed"
            case .none:
                return "No Delays"
            }
        }
    }
    
    //let affectedRoutes: [??]?
    //let affectedStops: [??]?
    
    let closureText: String?
    
    var delayType: DelayType {
        guard let closureText = closureText else {
            return .none
        }
        
        var delayType = DelayType.none
        switch closureText {
        case "severeDelays":
            delayType = DelayType.SevereDelays
            break
        case "minorDelays":
            delayType = DelayType.MinorDelays
            break
        default:
            break
        }
        
        return delayType
    }
}
