//
//  TabViewManager.swift
//  GaryGo
//
//  Created by Tom Knighton on 04/10/2021.
//

import Foundation
import SwiftUI

class TabViewManager: ObservableObject {
    @Published var currentPage: Page = .lines
}

enum Page {
    case lines
    case route
}
