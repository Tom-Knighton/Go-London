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
        let tflStatus = await ApiClient.perform(url: "\(URL)/Mode/tflrail/Status", to: [Line].self)
        let tubeStatus = await ApiClient.perform(url: "\(URL)/Mode/tube/Status", to: [Line].self)
        guard var tflStatus = tflStatus,
              let tubeStatus = tubeStatus else {
            return []
        }

        tflStatus.append(contentsOf: tubeStatus)
        return tflStatus
    }
    
    static func getDetailedLineInformation(lineId: String) async -> Line? {
        return await ApiClient.perform(url: "\(URL)/\(lineId)/Status?detail=true", to: [Line].self)?.first
    }
    
    static func getDetailedLineInformation(lineIds: [String]) async -> [Line?] {
        return await ApiClient.perform(url: "\(URL)/\(lineIds.joined(separator: ","))/Status?detail=true", to: [Line].self) ?? []
    }
    
}
