//
//  Go_LondonApp.swift
//  Shared
//
//  Created by Tom Knighton on 18/03/2022.
//

import SwiftUI
import GoLondonSDK

@main
struct Go_LondonApp: App {
    
    @Environment(\.scenePhase) private var scenePhase
    @State var showLocationPermission = false
    @ObservedObject var globalViewModel: GlobalViewModel = GlobalViewModel()
    
    init() {
        LocationManager.shared.start()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .hideKeyboardWhenTappedAround()
                .sheet(isPresented: $showLocationPermission) {
                    RequestLocation()
                }
                .environmentObject(globalViewModel)
                .task {
                    await self.globalViewModel.setup()
                }
        }
        .onChange(of: scenePhase) { newPhase in
            let locStatus = PermissionsManager.GetStatus(of: LocationWhenInUsePermission())
            self.showLocationPermission = locStatus != .authorised
        }
    }
}
