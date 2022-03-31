//
//  GoLondon.swift
//  Go London
//
//  Created by Tom Knighton on 23/03/2022.
//

import Foundation
import CoreLocation
import MapboxMaps

public class GoLondon {
    
    public static func GetLightStyleURL() -> StyleURI {
        guard let lightStyle = StyleURI(rawValue: "mapbox://styles/tomknighton/cl145dxdf000914m7r7ykij8s") else {
            return .light
        }
        return lightStyle
    }
    
    public static func GetDarkStyleURL() -> StyleURI {
        guard let darkStyle = StyleURI(rawValue: "mapbox://styles/tomknighton/cl145juvf002h14rkofjuct4r") else {
            return .dark
        }
        return darkStyle
    }
    
    public static let LiverpoolStreetCoord: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 51.518752, longitude: -0.081437)
}
