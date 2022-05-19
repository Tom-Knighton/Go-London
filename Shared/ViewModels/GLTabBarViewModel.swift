//
//  GLTabBarViewModel.swift
//  Go London
//
//  Created by Tom Knighton on 30/04/2022.
//

import Foundation
import SwiftUI

class GLTabBarViewModel: ObservableObject {
    
    struct GLTabPage: Hashable {
        static func == (lhs: GLTabBarViewModel.GLTabPage, rhs: GLTabBarViewModel.GLTabPage) -> Bool {
            lhs.page.hashValue == rhs.page.hashValue
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(page)
        }
        
        let page: Page
        let icon: TabIcon
        var isSelected: Bool
        
        struct TabIcon: Hashable {
            let pageName: String
            let iconName: String
            let selectedIconName: String
            let isSystem: Bool = true
            let fontSize: CGFloat
            
            static func == (lhs: GLTabBarViewModel.GLTabPage.TabIcon, rhs: GLTabBarViewModel.GLTabPage.TabIcon) -> Bool {
                lhs.pageName == rhs.pageName
            }
            
            public func hash(into hasher: inout Hasher) {
                hasher.combine(pageName)
            }
        }
    }
    enum Page {
        case home
        case lineStatus
    }
    
    @Published var allPages: [GLTabPage] = []
    @Published var currentPage: GLTabPage
    
    init(with pages: [GLTabPage], currentPageIndex: Int = 0) {
        self.allPages = pages
        self.currentPage = pages[currentPageIndex]
        self.selectPage(index: currentPageIndex)
    }
    
    func selectPage(index: Int) {
        for (index, _) in self.allPages.enumerated() {
            self.allPages[index].isSelected = false
        }
        self.allPages[index].isSelected = true
        self.currentPage = self.allPages[index]
    }
    
    func selectPage(_ pageName: String) {
        DispatchQueue.main.async {
            for (index, _) in self.allPages.enumerated() {
                self.allPages[index].isSelected = false
            }
            
            let index = self.allPages.firstIndex { $0.icon.pageName == pageName } ?? 0
            self.allPages[index].isSelected = true
            self.currentPage = self.allPages[index]
        }
    }
}
