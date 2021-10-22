//
//  StopPoint.swift
//  GaryGo
//
//  Created by Tom Knighton on 05/10/2021.
//

import Foundation
import SwiftUI

struct StopPoint: Codable, Identifiable {
    let icsId: String?
    let modes: [String]?
    let zone: String?
    let id: String?
    let name: String?
    let commonName: String?
    let lat: Double?
    let lon: Double?
        
    let lineModeGroups: [LineModeGroup]?
    
    private let additionalProperties: [StopPointProperty]?
    
    let children: [StopPoint]?
    
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
    
    private var wifiInfo: String {
        return additionalProperties?.first(where: { $0.key == "WiFi" })?.value?.capitalized ?? "No"
    }
    
    private var zoneInfo: String {
        return additionalProperties?.first(where: { $0.key == "Zone" })?.value?.capitalized ?? "No Information"
    }
    
    private var waitingRoomInfo: String {
        return additionalProperties?.first(where: { $0.key == "Waiting Room" })?.value?.capitalized ?? "No Information"
    }
    
    private var carParkInfo: String {
        return additionalProperties?.first(where: { $0.key == "Car park" })?.value?.capitalized ?? "No Information"
    }
    
    private var liftsInfo: String {
        return additionalProperties?.first(where: { $0.key == "Lifts" })?.value?.capitalized ?? "No Information"
    }
    
    private var toiletsInfo: String {
        return additionalProperties?.first(where: { $0.key == "Toilets" })?.value?.capitalized ?? "No Information"
    }
    
    func getStopPointInfo() -> [StopPointInfo] {
        return [StopPointInfo(infoName: "WiFi", infoValue: wifiInfo), StopPointInfo(infoName: "Zone", infoValue: zoneInfo), StopPointInfo(infoName: "Toilets", infoValue: toiletsInfo), StopPointInfo(infoName: "Lifts", infoValue: liftsInfo), StopPointInfo(infoName: "Waiting Rooms", infoValue: waitingRoomInfo), StopPointInfo(infoName: "Car Parks", infoValue: carParkInfo)].filter({ $0.infoValue != "No Information"})
    }
    
    func getChildStationIds() -> StopChildInfoIterator {
        let acceptableModes: [String] = ["tube", "central", "jubilee", "bakerloo", "circle", "district", "hammersmit-city", "metropolitan", "northern", "piccadilly", "victoria", "waterloo-city", "tfl-rail", "london-overground", "national-rail", "dlr"]
        let childrenFiltered = children?.filter({ stopPoint in
            return (stopPoint.lineIdentifiers?.filter({ acceptableModes.contains($0.lineId ?? "") }).count ?? 0) > 0
        })
        let finalResult: [StopPointChildInfo] = childrenFiltered?.compactMap { stopPoint in
            return StopPointChildInfo(stationId: stopPoint.id ?? "", lines: stopPoint.lineIdentifiers?.compactMap({ $0.lineId ?? "" }) ?? [])
        } ?? []
        return StopChildInfoIterator(elements: finalResult)
    }
    
    struct StopPointInfo {
        let infoName: String
        let infoValue: String
    }
}

struct StopChildInfoIterator: AsyncSequence {
    typealias Element = StopPointChildInfo
    
    var elements: [StopPointChildInfo]
    
    struct AsyncIterator: AsyncIteratorProtocol {
        var current = 1
        fileprivate var currentIndex = 0
        var elements: [StopPointChildInfo]

        mutating func next() async -> Element? {
            guard currentIndex < elements.count else {
                return nil
            }
            
            let element = elements[currentIndex]
            currentIndex += 1
            
            return element
        }
    }
    
    func makeAsyncIterator() -> AsyncIterator {
        AsyncIterator(elements: elements)
    }
}

struct StopPointChildInfo {
    let stationId: String
    let lines: [String]
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
            Image("nationalrail")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 25, height: 25)
        case "bus":
            Image("buseslogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 25, height: 25)
        default:
            RoundedRectangle(cornerRadius: 5)
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
        case "dlr":
            return Color(hex: 0x02B0AE)
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

struct StopPointProperty: Codable {
    let category: String?
    let key: String?
    let sourcesSystemKey: String?
    let value: String?
}

struct StopPointArrival: Codable {
    
    let id: String?
    let vehicleId: String?
    let naptanId: String?
    let lineId: String?
    let lineName: String?
    let platformName: String?
    let direction: String?
    let destinationName: String?
    let timeToStation: Int?
    let currentLocation: String?
    let stationName: String?
    let towards: String?
    
    var friendlyDueTime: String {
        guard let timeToStation = timeToStation else { fatalError("No time to station") }
        
        let denominator = lineId == "london-overground" ? 1 : 60
        switch timeToStation / denominator {
        case 0:
            return "Due"
        default:
            return String(timeToStation / denominator)
        }
    }
}

struct ArrivalGroup: Codable, Comparable {
    static func < (lhs: ArrivalGroup, rhs: ArrivalGroup) -> Bool {
        return lhs.lineName < rhs.lineName
    }
    
    static func == (lhs: ArrivalGroup, rhs: ArrivalGroup) -> Bool {
        return lhs.lineName == rhs.lineName
    }
    
    
    let lineName: String
    
    let arrivals: [StopPointArrival]
    
    init(lineName: String, arrivals: [StopPointArrival]) {
        self.lineName = lineName
        self.arrivals = arrivals
    }
    
    func getPlatformArrivalGroups() -> [PlatformArrivalGroup] {
        
        let arrivals = self.arrivals.filter({ $0.destinationName != $0.stationName || ($0.destinationName == $0.stationName && $0.lineId != "london-overground") })
        // Tube Lines:
        let platforms = arrivals.filter({ GaryTubeConstants.TubeLineIds.contains($0.lineId ?? "")}).compactMap({ $0.platformName ?? ""}).removeDuplicates() // All Tube Arrival Platforms
        var platformGroups: [PlatformArrivalGroup] = []
        for platform in platforms {
            let relevantArrivals = arrivals.filter({ $0.platformName == platform })
            let platformComponents = platform.split(separator: "-")
            
            
            var direction = String(platformComponents[0]).trim()
            var platformName = String(platformComponents[1]).trim()
            
            let firstArrival = relevantArrivals.first

            if direction == (firstArrival?.stationName ?? "") && firstArrival?.lineId == "jubilee" && platformComponents.count > 1 {
                direction = String(platformComponents[0]).trim()
            }
            
            platformName = platformName.replacingOccurrences(of: " Rail Station", with: "")
            platformName = platformName.replacingOccurrences(of: " Underground Station", with: "")
            platformName = platformName.replacingOccurrences(of: " DLR Station", with: "")
            platformGroups.append(PlatformArrivalGroup(platformName: platformName, direction: direction, arrivals: relevantArrivals))
        }
        
        //Other Lines:
        let remaining = arrivals.filter({ GaryTubeConstants.TubeLineIds.contains($0.lineId ?? "") == false }).compactMap({ $0.destinationName ?? ""}).removeDuplicates()
        for var destination in remaining {
            let relevantArrivals = arrivals.filter({ $0.destinationName == destination })
                        
            let actualPlatform = (relevantArrivals.first?.platformName?.components(separatedBy: " ") ?? []).first(where: { $0.isRealNumber })
            destination = destination.replacingOccurrences(of: " Rail Station", with: "")
            destination = destination.replacingOccurrences(of: " Underground Station", with: "")
            destination = destination.replacingOccurrences(of: " DLR Station", with: "")
            
            let platformName = actualPlatform != nil ? "Platform \(actualPlatform ?? "")" : "Awaiting Platform"
            
            platformGroups.append(PlatformArrivalGroup(platformName: platformName, direction: destination, arrivals: relevantArrivals))
        }
    
        return platformGroups
    }
    
    struct PlatformArrivalGroup: Codable {
        let platformName: String
        let direction: String
        let arrivals: [StopPointArrival]
    }
}

