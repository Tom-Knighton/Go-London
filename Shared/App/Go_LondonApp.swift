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
    @StateObject var globalViewModel: GlobalViewModel = GlobalViewModel()
    @StateObject var tabManager: GLTabBarViewModel = GLTabBarViewModel(with: [
        GLTabBarViewModel.GLTabPage(uuid: UUID(), page: .home, icon: GLTabBarViewModel.GLTabPage.TabIcon(pageName: "Map", iconName: "map", selectedIconName: "map.fill", fontSize: 30), isSelected: false),
        GLTabBarViewModel.GLTabPage(uuid: UUID(), page: .lineStatus, icon: GLTabBarViewModel.GLTabPage.TabIcon(pageName: "Lines", iconName: "tram", selectedIconName: "tram.fill", fontSize: 24), isSelected: false)
    ], currentPageIndex: 0)
    
    
    init() {
        LocationManager.shared.start()
    }
    
    var body: some Scene {
        WindowGroup {            
            ContentView()
            .sheet(isPresented: $showLocationPermission) {
                RequestLocation()
            }
            .environmentObject(globalViewModel)
            .task {
                await self.globalViewModel.setup()
            }
            .environmentObject(tabManager)
        }
        .onChange(of: scenePhase) { newPhase in
            let locStatus = PermissionsManager.GetStatus(of: LocationWhenInUsePermission())
            self.showLocationPermission = locStatus != .authorised
        }
    }
}
