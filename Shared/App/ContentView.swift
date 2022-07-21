//
//  ContentView.swift
//  Shared
//
//  Created by Tom Knighton on 18/03/2022.
//

import SwiftUI
import MapboxMaps
import Combine

struct ContentView: View {
    
    @Environment(\.colorScheme) private var colourScheme
    @EnvironmentObject private var tabManager: GLTabBarViewModel
    @FocusState var focused: Bool
    
    @State private var showTabBar: Bool = true
    
    @State private var readRect: CGRect = CGRect()
    
    var body: some View {
        ZStack {
            ForEach(self.tabManager.allPages, id: \.uuid) { page in
                switch page.page {
                case .home:
                    NavigationStack {
                        HomeView()
                            .toolbar(.hidden)
                    }
                    .hideKeyboardWhenTappedAround()
                    .opacity(self.tabManager.currentPage.page == .home ? 1 : 0)
                    .id(page.uuid)
                    .environment(\.tabBarHeight, readRect.height)
                    
                case .lineStatus:
                    NavigationStack {
                        AllLinesStatusPage()
                    }
                    .navigationTitle("TfL Status:")
                    .opacity(self.tabManager.currentPage.page == .lineStatus ? 1 : 0)
                    .id(page.uuid)
                    .environment(\.tabBarHeight, readRect.height)
                        
                }
            }
        }
        .toolbar(self.tabManager.currentPage.page == .home ? .hidden : .automatic)
        .safeAreaInset(edge: .bottom) {
            if self.showTabBar {
                GLTabBar()
                    .transition(.move(edge: .bottom))
                    .background(GeometryGetter(rect: $readRect))
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
