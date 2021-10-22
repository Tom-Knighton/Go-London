//
//  Line.swift
//  GaryTube
//
//  Created by Tom Knighton on 01/10/2021.
//

import Foundation
import SwiftUI

struct Line: Codable {
    
    let id: String?
    let name: String?
    let modeName: String?
    let disruptions: [Disruption]?
    let created: Date?
    let modified: Date?
    let lineStatuses: [LineStatus]?
//    let routeSections: [??]?
//    let serviceTypes: [??]?
    
    var currentStatus: LineStatus? {
        return self.lineStatuses?.filter({ status in
            let hasStatusNow = status.validityPeriods?.contains(where: { $0.isNow == true }) == true
            let hasStatusRunning = status.validityPeriods?.contains(where: { ($0.fromDate ?? Date()) >= Date() && ($0.toDate ?? Date()) <= Date() }) == true
            return hasStatusNow || hasStatusRunning
        }).first ?? self.lineStatuses?.first ?? nil
    }
    
    var tubeColour: Color {
        guard let name = self.name else { return .primary }
        
        return GaryTubeConstants.getLineColour(from: name)
    }
}

struct LineStatus: Codable {
    let id: Int?
    let lineId: String?
    let statusSeverity: Int?
    let statusSeverityDescription: String?
    let reason: String?
    let created: Date?
    let validityPeriods: [LineStatusValidityPeriod]?
    let disruption: Disruption?
    
    var severityColour: Color {
        switch statusSeverity {
        case 0, 8, 13, 19:
            return Color.blue
        case 1, 2, 3, 6, 12, 16, 20:
            return Color.red
        case 4, 5, 7, 9, 11, 14, 15, 17:
            return Color.orange
        case 10, 18:
            return Color.green
        default:
            return Color.blue
        }
    }
}

struct LineStatusValidityPeriod: Codable {
    let fromDate: Date?
    let toDate: Date?
    let isNow: Bool?
}

struct LineRoute: Codable {
    let id: String?
    let name: String?
    let direction: String?
    let originationName: String?
    let destinationName: String?
    
}
