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
        return await ApiClient.perform(url: "\(URL)/Search?query=\(name)", to: StopPointQueryResult.self)?.matches ?? []
    }
}
