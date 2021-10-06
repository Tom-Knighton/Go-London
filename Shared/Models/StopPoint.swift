//
//  StopPoint.swift
//  GaryGo
//
//  Created by Tom Knighton on 05/10/2021.
//

import Foundation
import SwiftUI

struct StopPoint: Codable {
    let icsId: String?
    let modes: [String]?
    let zone: String?
    let id: String?
    let name: String?
    let commonName: String?
    let lat: Double?
    let lon: Double?
    
    let lineModeGroups: [LineModeGroup]?
    
    var lineIdentifiers: [LineIdentifier]? {
        var ids: [LineIdentifier] = []
        lineModeGroups?.forEach({ lineModeGroup in
            if lineModeGroup.modeName == "tube" {
                lineModeGroup.lineIdentifier?.forEach({ identifier in
                    ids.append(LineIdentifier(lineId: identifier))
                })
            } else {
                ids.append(LineIdentifier(lineId: lineModeGroup.modeName))
            }
        })
        
        let busIndex = ids.firstIndex(where: { $0.lineId == "bus" })
        let nrIndex = ids.firstIndex(where: { $0.lineId == "national-rail" })
        if let nrIndex = nrIndex {
            ids.insert(ids.remove(at: nrIndex), at: 0)
        }
        if let busIndex = busIndex {
            ids.insert(ids.remove(at: busIndex), at: 0)
        }
        
        return ids
    }
}

struct LineModeGroup: Codable {
    let modeName: String?
    let lineIdentifier: [String]?
}

struct LineIdentifier: Codable {
    let lineId: String?
    
    @ViewBuilder
    var lineIndicator: some View {
        switch lineId {
        case "national-rail":
            Image(systemName: "tram")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 25, height: 25)
        case "bus":
            Image(systemName: "bus")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 25, height: 25)
        default:
            RoundedRectangle(cornerRadius: 10)
                .frame(width: 25, height: 25)
                .foregroundColor(colour)
        }
        
    }
    
    private var colour: Color {
        switch lineId {
        case "overground":
            return Color(hex: 0xEF7C09)
        case "tflrail":
            return Color(hex: 0x604099)
        case "bakerloo":
            return Color(hex: 0xB05F0F)
        case "central":
            return Color(hex: 0xEE2E21)
        case "circle":
            return Color(hex: 0xFED203)
        case "district":
            return Color(hex: 0x00853D)
        case "hammersmith-city":
            return Color(hex: 0xF4879F)
        case "jubilee":
            return Color(hex: 0x949CA0)
        case "metropolitan":
            return Color(hex: 0x96005E)
        case "northern":
            return Color(hex: 0x231F20)
        case "piccadilly":
            return Color(hex: 0x1B3F94)
        case "victoria":
            return Color(hex: 0x049EDC)
        case "waterloo-city":
            return Color(hex: 0x84CDBC)
        default:
            return Color.clear
        }
    }
}

struct StopPointQueryResult: Codable {
    let query: String?
    let total: Int?
    let matches: [StopPoint]?
}
