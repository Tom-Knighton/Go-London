//
//  LineService.swift
//  GaryTube (iOS)
//
//  Created by Tom Knighton on 01/10/2021.
//

import Foundation

struct LineService {
    
    static let URL = "\(GaryTubeConstants.BASEURL)/Line"
    
    static func getDisruptions() async -> [Disruption]? {
        return await ApiClient.perform(url: "\(URL)/Mode/tube/Disruption", to: [Disruption].self)
    }
    
    static func getTrainStatus() async -> [Line]? {
        var trainStatus = await ApiClient.perform(url: "\(URL)/Mode/tflrail,overground,tube/Status", to: [Line].self)
        let overgroundIndex = trainStatus?.firstIndex(where: { $0.id == "london-overground" })
        let tflIndex = trainStatus?.firstIndex(where: { $0.id == "tfl-rail" })
        
        if let overgroundIndex = overgroundIndex,
           let tflIndex = tflIndex,
           let tfl = trainStatus?.remove(at: tflIndex),
           let overground = trainStatus?.remove(at: overgroundIndex) {
            trainStatus?.insert(tfl, at: 0)
            trainStatus?.insert(overground, at: 0)
        }
        return trainStatus ?? []
    }
    
    static func getDetailedLineInformation(lineId: String) async -> Line? {
        return await ApiClient.perform(url: "\(URL)/\(lineId)/Status?detail=true", to: [Line].self)?.first
    }
    
    static func getDetailedLineInformation(lineIds: [String]) async -> [Line?] {
        return await ApiClient.perform(url: "\(URL)/\(lineIds.joined(separator: ","))/Status?detail=true", to: [Line].self) ?? []
    }
    
}
