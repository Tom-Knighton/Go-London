//
//  ContentView.swift
//  Shared
//
//  Created by Tom Knighton on 18/03/2022.
//

import SwiftUI
import MapboxMaps

struct ContentView: View {
    
    @ObservedObject var tabManager: GLTabBarViewModel = GLTabBarViewModel(with: [
        GLTabBarViewModel.GLTabPage(page: .home, icon: GLTabBarViewModel.GLTabPage.TabIcon(pageName: "Map", iconName: "map", selectedIconName: "map.fill", fontSize: 30), isSelected: false),
        GLTabBarViewModel.GLTabPage(page: .lineStatus, icon: GLTabBarViewModel.GLTabPage.TabIcon(pageName: "Lines", iconName: "tram", selectedIconName: "tram.fill", fontSize: 24), isSelected: false)
    ], currentPageIndex: 0)
    
    
    var body: some View {
        ZStack {
            switch self.tabManager.currentPage.page {
            case .home:
                HomeView()
            case .lineStatus:
                LineStatusPage()
            }
            Spacer()
            VStack {
                Spacer()
                GLTabBar()
                    .environmentObject(tabManager)
            }
            
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}
