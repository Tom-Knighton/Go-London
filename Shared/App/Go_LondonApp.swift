//
//  Go_LondonApp.swift
//  Shared
//
//  Created by Tom Knighton on 18/03/2022.
//

import SwiftUI

@main
struct Go_LondonApp: App {
    
    @Environment(\.scenePhase) var scenePhase
    @State var showLocationPermission = false
    
    init() {
        LocationManager.shared.start()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .sheet(isPresented: $showLocationPermission) {
                    RequestLocation()
                }
        }
        .onChange(of: scenePhase) { newPhase in
            let locStatus = PermissionsManager.GetStatus(of: LocationWhenInUsePermission())
            self.showLocationPermission = locStatus != .authorised
        }
    }
}
