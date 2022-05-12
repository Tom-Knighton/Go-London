//
//  StopPointAnnotation.swift
//  Go London (iOS)
//
//  Created by Tom Knighton on 27/03/2022.
//

import Foundation
import CoreLocation
import GoLondonSDK

struct StopPointAnnotation: Identifiable, Equatable {
    static func == (lhs: StopPointAnnotation, rhs: StopPointAnnotation) -> Bool {
        lhs.id == rhs.id
    }
    
    var id: String { "\(String(describing: stopPoint.lat)),\(String(describing: stopPoint.lon))"}
    
    let stopPoint: StopPoint
    
    var coordinate: CLLocationCoordinate2D { get { return CLLocationCoordinate2D(latitude: CLLocationDegrees(self.stopPoint.lat ?? 0), longitude: CLLocationDegrees(self.stopPoint.lon ?? 0))}}
    
    var isDetail: Bool = false
}
