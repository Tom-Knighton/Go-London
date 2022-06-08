//
//  AlertDetails.swift
//  Go London
//
//  Created by Tom Knighton on 08/06/2022.
//

import Foundation
import SwiftUI

struct AlertDetails: Identifiable {
    
    var id: UUID { UUID() }
    
    let title: String
    let message: String?
    
    let buttons: [AlertButtonType]?
    
}

struct AlertButtonType {
    
    let role: ButtonRole? = nil
    let text: String
    let action: () -> Void
}
