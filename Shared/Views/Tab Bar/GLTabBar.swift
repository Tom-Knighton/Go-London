//
//  GLTabBar.swift
//  Go London
//
//  Created by Tom Knighton on 30/04/2022.
//

import SwiftUI

struct GLTabBar: View {
    
    @EnvironmentObject var tabManager: GLTabBarViewModel
    @State private var bottomPaddingFix: CGFloat = 0
    @Environment(\.safeAreaInsets) var edges

    var body: some View {
        VStack {
            HStack {
                ForEach(self.tabManager.allPages, id: \.self) { page in
                    Button(action: { self.tabManager.selectPage(page.icon.pageName)}) {
                        Spacer()
                        VStack {
                            Group {
                                if page.icon.isSystem {
                                    Image(systemName: page.isSelected ? page.icon.selectedIconName : page.icon.iconName)
                                } else {
                                    Image(page.isSelected ? page.icon.selectedIconName : page.icon.iconName)
                                }
                            }
                            .font(.system(size: page.isSelected ? page.icon.fontSize - 1 : page.icon.fontSize, weight: page.isSelected ? .bold : .regular))
                            .foregroundColor(Color(UIColor.label))
                            
                            Text(page.icon.pageName)
                                .foregroundColor(Color(UIColor.label))
                                .font(.system(size: 12, weight: .bold))
                                .fixedSize()
                        }
                        Spacer()
                    }
                }
                .padding(.bottom, self.bottomPaddingFix)
            }
            .frame(minHeight: 25)
            .padding(.vertical, 15)
            .background(Color.layer1)
            .cornerRadius(10, corners: [.topLeft, .topRight])
            .shadow(color: Color.black.opacity(0.15), radius: 5, x: 5, y: 5)
            .shadow(color: Color.black.opacity(0.15), radius: 5, x: -5, y: -5)
            .onAppear {
                self.bottomPaddingFix = self.edges.bottom
            }
            .onChange(of: self.edges.bottom) { newVal in
                if newVal > self.bottomPaddingFix {
                    self.bottomPaddingFix = newVal
                }
            }
        }
    }
}

struct GLTabBar_Previews: PreviewProvider {
    static var previews: some View {
        GLTabBar()
    }
}
