//
//  Constants.swift
//  GaryTube
//
//  Created by Tom Knighton on 01/10/2021.
//

import Foundation
import SwiftUI

struct GaryTubeConstants {
    static let BASEURL = "https://api.tfl.gov.uk"
    static let apiKey = "53e8f6ca472546d68eb1d63bcec1f427"
    static let appKey = "129fc93903934d0b9f0398aeca65ecbf"
    
    static let TubeLineIds = ["central", "district", "hammersmith-city", "waterloo", "victoria", "bakerloo", "circle", "metropolitan", "northern", "piccadilly", "jubilee"]
    
    static func getLineColour(from lineName: String) -> Color {
        switch lineName {
        case "TfL Rail":
            return Color(hex: 0x604099)
        case "London Overground":
            return Color(hex: 0xEF7C09)
        case "Bakerloo":
            return Color(hex: 0xB05F0F)
        case "Central":
            return Color(hex: 0xEE2E21)
        case "Circle":
            return Color(hex: 0xFED203)
        case "District":
            return Color(hex: 0x00853D)
        case "Hammersmith & City":
            return Color(hex: 0xF4879F)
        case "Jubilee":
            return Color(hex: 0x949CA0)
        case "Metropolitan":
            return Color(hex: 0x96005E)
        case "Northern":
            return Color(hex: 0x231F20)
        case "Piccadilly":
            return Color(hex: 0x1B3F94)
        case "Victoria":
            return Color(hex: 0x049EDC)
        case "Waterloo & City":
            return Color(hex: 0x84CDBC)
        case "DLR":
            return Color(hex: 0x02B0AE)
        default:
            return Color.primary
        }
    }
}

