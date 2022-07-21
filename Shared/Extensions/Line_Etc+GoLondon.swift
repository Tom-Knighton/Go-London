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
    
    /// Returns a 'friendly' name for a Tube Line Identifier
    /// - Remark: I.e. 'Waterloo & City' instead of 'waterloo-city'
    static func friendlyTubeLineName(for lineIdentifier: String) -> String {
        
        let lineIdentifier = lineIdentifier.lowercased()
        switch lineIdentifier {
        case "hammersmith-city":
            return "Hammersmith & City"
        case "waterloo-city":
            return "Waterloo & City"
        case "london-overground":
            return "London Overground"
        case "dlr":
            return "DLR"
        case "elizabeth":
            return "Elizabeth Line"
        default:
            return lineIdentifier.prefix(1).capitalized + lineIdentifier.dropFirst()
        }
    }
    
    /// Returns the Color for the current lineMode
    var lineColour: Color {
        return LineMode.lineColour(for: self)
    }
    
    /// Returns the Color object for the specified lineMode value
    /// - Parameter lineIdentifier: The line mode to get the main colour for
    static func lineColour(for lineMode: LineMode) -> Color {
        return lineColour(for: lineMode.rawValue)
    }
    
    /// Returns the Color object for the specified lineIdentifier, where lineIdentifier is a lineMode raw value or a tube line identifier like 'bakerloo'
    /// - Parameter lineIdentifier: The identifier to get the main colour for
    static func lineColour(for lineIdentifier: String) -> Color {
        switch lineIdentifier {
        case "bakerloo":
            return .init(hex: "#B36305")
        case "central":
            return .init(hex: "#E32017")
        case "circle":
            return .init(hex: "#FFD300")
        case "district":
            return .init(hex: "#00782A")
        case "hammersmith-city":
            return .init(hex: "#F3A9BB")
        case "jubilee":
            return .init(hex: "#A0A5A9")
        case "metropolitan":
            return .init(hex: "#9B0056")
        case "northern":
            return .init(hex: "#000000")
        case "piccadilly":
            return .init(hex: "#003688")
        case "victoria":
            return .init(hex: "#0098D4")
        case "waterloo-city":
            return .init(hex: "#95CDBA")
            
        case "tube":
            return .init(hex: "#0009AB")
        case "bus":
            return .init(hex: "#EE2E24")
        case "dlr":
            return .init(hex: "#00A4A7")
        case "national-rail":
            return .red
        case "overground", "london-overground":
            return .init(hex: "#EE7C0E")
        case "tfl-rail", "elizabeth-line", "elizabeth":
            return .init(hex: "#6950a1")
            
        
        default:
            return .init(hex: "#E21836")
        }
    }
    
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
        case .elizabethLine:
            return "Elizabeth Line"
        case .cableCar:
            return "Cable Car"
        case .tram:
            return "Tram"
        case .unknown:
            return ""
        }
    }
    
    @ViewBuilder
    var image: some View {
        switch self {
        case .bus:
            Image("tfl")
                .resizable()
                .foregroundColor(lineColour)
        case .dlr:
            Image("nationalrail")
                .resizable()
                .foregroundColor(lineColour)
        case .nationalRail:
            Image("nationalrail")
                .resizable()
                .foregroundColor(lineColour)
        case .overground:
            Image("tfl")
                .resizable()
                .foregroundColor(lineColour)
        case .tube:
            Image("tube")
                .resizable()
                .foregroundColor(lineColour)
        case .tflrail, .elizabethLine:
            Image("tfl")
                .resizable()
                .foregroundColor(lineColour)
        default:
            Image("tfl")
                .resizable()
                .foregroundColor(.red)
        }
    }
    
    @ViewBuilder
    static func image(for lineId: String) -> some View {
        switch lineId {
        case "london-overground":
            LineMode.overground.image
        case "dlr":
            LineMode.dlr.image
        case "elizabeth":
            LineMode.elizabethLine.image
        default:
            LineMode.tube.image
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
        case .elizabethLine:
            return 5
        case .cableCar:
            return 3
        case .tram:
            return 2
        case .unknown:
            return -1
        }
    }
}

extension Line: Equatable, Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
    
    public static func == (lhs: Line, rhs: Line) -> Bool {
        lhs.id == rhs.id
    }
}


extension LineModeGroupStatusType {
    
    var textColour: Color {
        switch self {
        case .unk:
            return .primary
        case .allGood:
            return .green
        case .allProblems:
            return .red
        case .manyProblems:
            return .red
        case .mostGood:
            return .green
        case .someProblems:
            return .yellow
        }
    }
}

extension LineRoutes: Equatable {
    public static func == (lhs: LineRoutes, rhs: LineRoutes) -> Bool {
        lhs.lineId == rhs.lineId
    } 
}
