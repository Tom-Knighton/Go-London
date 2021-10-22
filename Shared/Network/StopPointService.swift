//
//  StopPointService.swift
//  GaryGo
//
//  Created by Tom Knighton on 05/10/2021.
//

import Foundation

struct StopPointService {
    static let URL = "\(GaryTubeConstants.BASEURL)/StopPoint"

    static func SearchStopPoint(by name: String) async -> [StopPoint] {
        return await ApiClient.perform(url: "\(URL)/Search?query=\(name)&maxResults=10", to: StopPointQueryResult.self)?.matches ?? []
    }
    
    static func GetStopPoints(by ids: [String]) async -> [StopPoint] {
        let stopPointData = await ApiClient.performNoDecoding(url: "\(URL)/\(ids.joined(separator: ","))")
        if let stopPointData = stopPointData {
            do {
                return try stopPointData.decode(to: [StopPoint].self) ?? []
            } catch {
                do {
                    let singlePoint = try stopPointData.decode(to: StopPoint.self)
                    if let singlePoint = singlePoint {
                        return [singlePoint]
                    }
                    return []
                } catch {
                    return []
                }
            }
        }
        return []
    }
    
    static func DetailedCachedSearch(by name: String) async -> [StopPoint] {
        let stops = await SearchStopPoint(by: name)
        let stopIds = stops.compactMap( { $0.id ?? "" })
        guard stops.isEmpty == false else {
            return []
        }
        
        return await GetStopPoints(by: stopIds).reversed()
    }
    
    static func GetEstimatedArrivals(for stopPoint: StopPoint) async -> [ArrivalGroup] {
        
        let isHub = stopPoint.id?.prefix(3) == "HUB"
        
        var unsortedArrivals: [StopPointArrival] = []
        if !isHub {
            // If the station is not a hub, the /Arrivals endpoint needs to be used on the parent station object
            unsortedArrivals = await ApiClient.perform(url: "\(URL)/\(stopPoint.id ?? "")/Arrivals", to: [StopPointArrival].self) ?? []
        } else {
            // If the station is a hub, then we need to call /Arrivals for each of the relevant children
            let childStations = stopPoint.getChildStationIds()
            for await child in childStations {
                let info = await ApiClient.perform(url: "\(URL)/\(child.stationId)/Arrivals", to: [StopPointArrival].self)
                unsortedArrivals.append(contentsOf: info ?? [])
            }
        }
        
        
        let arrivalsDict = unsortedArrivals.reduce(into: [:]) { dict, arrival in
            dict[arrival.lineName ?? ""] = unsortedArrivals.filter({ $0.lineName == arrival.lineName}).sorted(by: { ($0.timeToStation ?? 0) < ($1.timeToStation ?? 0)})
        }

        var arrivalGroups: [ArrivalGroup] = []
        arrivalsDict.forEach { (key: String, value: [StopPointArrival]) in
            arrivalGroups.append(ArrivalGroup(lineName: key, arrivals: value))
        }
        
        arrivalGroups.sort { group1, group2 in
            group1.lineName < group2.lineName
        }
        return arrivalGroups
    }
}
