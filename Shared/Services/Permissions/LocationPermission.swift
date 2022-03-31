//
//  LocationPermission.swift
//  Go London
//
//  Created by Tom Knighton on 25/03/2022.
//

import Foundation
import CoreLocation

public struct LocationPermission: Permission {
    
    var type = PermissionType.GeneralLocation
    
    var status: PermissionStatus = (PermissionsManager.GetStatus(of: LocationWhenInUsePermission()) == .authorised || PermissionsManager.GetStatus(of: LocationAlwaysPermission()) == .authorised) ? .authorised : .denied
    
    func request() {
        return LocationAlwaysPermission().request()
    }
    
}

public struct LocationWhenInUsePermission: Permission {
    
    var type = PermissionType.LocationWhenInUse
    
    var status: PermissionStatus { get {
        let authorizationStatus: CLAuthorizationStatus = {
            let locationManager = CLLocationManager()
            if #available(iOS 14.0, tvOS 14.0, *) {
                return locationManager.authorizationStatus
            } else {
                return CLLocationManager.authorizationStatus()
            }
        }()
        
        switch authorizationStatus {
            case .authorized: return .authorised
            case .denied: return .denied
            case .notDetermined: return .notYetAsked
            case .restricted: return .denied
            case .authorizedAlways: return .authorised
            case .authorizedWhenInUse: return .authorised
            @unknown default: return .denied
        }
    }}
    
    func request() {
        LocationManager().request()
    }
}

public struct LocationAlwaysPermission: Permission {
    
    var type = PermissionType.LocationWhenInUse
    
    var status: PermissionStatus { get {
        let authorizationStatus: CLAuthorizationStatus = {
            let locationManager = CLLocationManager()
            if #available(iOS 14.0, tvOS 14.0, *) {
                return locationManager.authorizationStatus
            } else {
                return CLLocationManager.authorizationStatus()
            }
        }()
        
        switch authorizationStatus {
            case .authorized: return .authorised
            case .denied: return .denied
            case .notDetermined: return .notYetAsked
            case .restricted: return .denied
            case .authorizedAlways: return .authorised
            case .authorizedWhenInUse: return .denied
            @unknown default: return .denied
        }
    }}
    
    func request() {
        LocationManager().request(always: true)
    }
}
