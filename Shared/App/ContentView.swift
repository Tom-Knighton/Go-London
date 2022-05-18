//
//  ContentView.swift
//  Shared
//
//  Created by Tom Knighton on 18/03/2022.
//

import SwiftUI
import MapboxMaps
import Combine

struct GeometryGetterMod: ViewModifier {
    
    @Binding var rect: CGRect
    
    func body(content: Content) -> some View {
        return GeometryReader { (g) -> Color in // (g) -> Content in - is what it could be, but it doesn't work
            DispatchQueue.main.async { // to avoid warning
                self.rect = g.frame(in: .global)
            }
            return Color.clear // return content - doesn't work
        }
    }
}

struct ContentView: View {
    
    @ObservedObject var tabManager: GLTabBarViewModel = GLTabBarViewModel(with: [
        GLTabBarViewModel.GLTabPage(page: .home, icon: GLTabBarViewModel.GLTabPage.TabIcon(pageName: "Map", iconName: "map", selectedIconName: "map.fill", fontSize: 30), isSelected: false),
        GLTabBarViewModel.GLTabPage(page: .lineStatus, icon: GLTabBarViewModel.GLTabPage.TabIcon(pageName: "Lines", iconName: "tram", selectedIconName: "tram.fill", fontSize: 24), isSelected: false)
    ], currentPageIndex: 0)
    
    @FocusState var focused: Bool
    
    @State private var rect1 = CGRect()
    @State private var height: CGFloat = 0
    
    var body: some View {
        VStack(spacing: -8) {
            switch self.tabManager.currentPage.page {
            case .home:
                HomeView(tabBarHeight: $height)
            case .lineStatus:
                LineStatusPage()
            }

            GLTabBar()
                .environmentObject(tabManager)
                .overlay(Color.clear.modifier(GeometryGetterMod(rect: $rect1)))
                .onChange(of: self.rect1) { newVal in
                    self.height = newVal.height
                }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}
