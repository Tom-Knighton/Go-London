//
//  ContentView.swift
//  Shared
//
//  Created by Tom Knighton on 01/10/2021.
//

import SwiftUI
import Introspect

struct ContentView: View {
    
    @StateObject var viewManager: TabViewManager
    
    var body: some View {
        NavigationView {
            ZStack {
                switch viewManager.currentPage {
                case .lines:
                    LinesOverviewView()
                case .route:
                    DirectionsHomeView()
                }
                
                GPTabBar(viewManager: self.viewManager)
            }
        }
        .navigationViewStyle(.stack)
        .hideKeyboardWhenTappedAround()
    }
}

struct GPTabBar: View {
    
    @StateObject var viewManager: TabViewManager
    @State var pages: [Page] = [.route, .lines]
    @State var tabIcons: [TabIcon] = [TabIcon(pageName: "Directions", iconName: "map", selectedIconName: "map.fill", fontSize: 30), TabIcon(pageName: "Lines", iconName: "tram", selectedIconName: "tram.fill", fontSize: 24)]
    
    @Environment(\.safeAreaInsets) var edges
    
    struct TabIcon {
        let pageName: String
        let iconName: String
        let selectedIconName: String
        let fontSize: CGFloat
    }
    
    var body: some View {
        
        VStack {
            
            Spacer()
            
            HStack {
                ForEach(0..<pages.count) { index in
                    Button(action: { viewManager.currentPage = pages[index] }, label: {
                        Spacer()
                        VStack {
                            Image(systemName: viewManager.currentPage == pages[index] ? self.tabIcons[index].selectedIconName : self.tabIcons[index].iconName)
                                .font(.system(size: viewManager.currentPage == pages[index] ? self.tabIcons[index].fontSize - 1 : self.tabIcons[index].fontSize, weight: viewManager.currentPage == pages[index] ? .bold : .regular))
                                .foregroundColor(Color(.label))
                            Text(self.tabIcons[index].pageName)
                                .foregroundColor(Color(.label))
                                .font(.system(size: 12, weight: .bold))
                                .fixedSize()
                        }
                        Spacer()
                    })
                }
                .padding(.bottom, edges.bottom)
            }
            .frame(minHeight: 25)
            .padding(.vertical, 15)
            .background(Color("Section"))
            .cornerRadius(10, corners: [.topLeft, .topRight])
            .shadow(color: Color.black.opacity(0.15), radius: 5, x: 5, y: 5)
            .shadow(color: Color.black.opacity(0.15), radius: 5, x: -5, y: -5)
            .edgesIgnoringSafeArea(.bottom)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .edgesIgnoringSafeArea(.bottom)
    }
}


