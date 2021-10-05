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
}
