//
//  PermissionManager.swift
//  Go London
//
//  Created by Tom Knighton on 25/03/2022.
//

import Foundation

class PermissionsManager {
    
    /// Returns the status (authorised, denied) of a specified Permission
    /// - Parameter permission: An object conforming to the Permission protocol
    /// - Returns: A PermissionStatus case
    static func GetStatus(of permission: Permission) -> PermissionStatus {
        return permission.status
    }
    
    /// Asks the system for a permission
    /// - Parameter permission: An object conforming to the Permission protocol
    static func RequestPermission(for permission: Permission) {
        return permission.request()
    }
}

enum PermissionType {
    case LocationWhenInUse, LocationAlways, GeneralLocation
}

enum PermissionStatus {
    case authorised, notYetAsked, denied
}

protocol Permission {
    
    var type: PermissionType { get }
    var status: PermissionStatus { get }
    
    func request()

}

