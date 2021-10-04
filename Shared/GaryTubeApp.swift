//
//  GaryTubeApp.swift
//  Shared
//
//  Created by Tom Knighton on 01/10/2021.
//

import SwiftUI

@main
struct GaryTubeApp: App {
    
    @StateObject var tabManager = TabViewManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewManager: tabManager)
        }
    }
}
