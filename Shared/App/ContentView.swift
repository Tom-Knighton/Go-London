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
    
    @Environment(\.colorScheme) private var colourScheme
    
    @StateObject var tabManager: GLTabBarViewModel = GLTabBarViewModel(with: [
        GLTabBarViewModel.GLTabPage(uuid: UUID(), page: .home, icon: GLTabBarViewModel.GLTabPage.TabIcon(pageName: "Map", iconName: "map", selectedIconName: "map.fill", fontSize: 30), isSelected: false),
        GLTabBarViewModel.GLTabPage(uuid: UUID(), page: .lineStatus, icon: GLTabBarViewModel.GLTabPage.TabIcon(pageName: "Lines", iconName: "tram", selectedIconName: "tram.fill", fontSize: 24), isSelected: false)
    ], currentPageIndex: 0)
    
    @FocusState var focused: Bool
    
    @State private var rect1 = CGRect()
    @State private var height: CGFloat = 0
    
    var body: some View {
        VStack {
            ZStack {
                ForEach(self.tabManager.allPages, id: \.uuid) { page in
                    switch page.page {
                    case .home:
                        NavigationView {
                            HomeView(tabBarHeight: $height)
                                .navigationBarHidden(true)
                        }
                        .navigationViewStyle(.stack)
                        .opacity(self.tabManager.currentPage.page == .home ? 1 : 0)
                        .id(page.uuid)
                    case .lineStatus:
                        NavigationView {
                            AllLinesStatusPage()
                                .navigationBarHidden(false)
                                .navigationTitle("TfL Status:")
                        }
                        .navigationViewStyle(.stack)
                        .opacity(self.tabManager.currentPage.page == .lineStatus ? 1 : 0)
                        .id(page.uuid)
                    }
                }
            }       
        }
        .safeAreaInset(edge: .bottom) {
            GLTabBar()
                .opacity(self.tabManager.showTabBar ? 1 : 0)
        }
        .environmentObject(tabManager)
        .edgesIgnoringSafeArea(.bottom)
        .onChange(of: colourScheme) { newVal in
            NotificationCenter.default.post(name: .OS_COLOUR_SCHEME_CHANGE, object: nil, userInfo: ["scheme": newVal])
        }
    }
    
    func onSamePageTapped(page: GLTabBarViewModel.GLTabPage) {
        self.tabManager.resetUUID(for: page.page)
    }
}
