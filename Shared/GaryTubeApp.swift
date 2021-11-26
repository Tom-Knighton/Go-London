//
//  GaryTubeApp.swift
//  Shared
//
//  Created by Tom Knighton on 01/10/2021.
//

import SwiftUI
import GoLondonAPI

@main
struct GaryTubeApp: App {
    
    @StateObject var tabManager = TabViewManager()
    
    init() {
        GoLondonAPI.shared.setup(for: "53e8f6ca472546d68eb1d63bcec1f427", appKey: "129fc93903934d0b9f0398aeca65ecbf")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewManager: tabManager)
        }
    }
}
