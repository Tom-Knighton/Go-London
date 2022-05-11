//
//  Point+GoLondon.swift
//  Go London
//
//  Created by Tom Knighton on 28/04/2022.
//

import Foundation
import GoLondonSDK

extension Point: Equatable {
    public static func == (lhs: Point, rhs: Point) -> Bool {
        lhs.lat == rhs.lat && lhs.lon == rhs.lon && lhs.pointType == rhs.pointType
    }
}
