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
    @EnvironmentObject private var tabManager: GLTabBarViewModel
    @FocusState var focused: Bool
    
    @State private var showTabBar: Bool = true
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
            if self.showTabBar {
                GLTabBar()
                    .transition(.move(edge: .bottom))
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .onChange(of: colourScheme) { newVal in
            NotificationCenter.default.post(name: .OS_COLOUR_SCHEME_CHANGE, object: nil, userInfo: ["scheme": newVal])
        }
        .onReceive(NotificationCenter.default.publisher(for: .GL_TAB_BAR_SHOW)) { _ in
            withAnimation {
                self.showTabBar = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .GL_TAB_BAR_HIDE)) { _ in
            withAnimation {
                self.showTabBar = false
            }
        }
    }
    
    func onSamePageTapped(page: GLTabBarViewModel.GLTabPage) {
        self.tabManager.resetUUID(for: page.page)
    }
}
