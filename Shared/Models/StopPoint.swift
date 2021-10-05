//
//  StopPoint.swift
//  GaryGo
//
//  Created by Tom Knighton on 05/10/2021.
//

import Foundation

struct StopPoint: Codable {
    let icsId: String?
    let modes: [String]?
    let zone: String?
    let id: String?
    let name: String?
    let lat: Double?
    let lon: Double?
}

struct StopPointQueryResult: Codable {
    let query: String?
    let total: Int?
    let matches: [StopPoint]?
}
