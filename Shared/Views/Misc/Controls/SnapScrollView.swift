//
//  SnapScrollView.swift
//  Go London
//
//  Created by Tom Knighton on 21/06/2022.
//

import Foundation
import SwiftUI

struct SnapCarousel<Content: View, T: Identifiable>: View {
    
    var content: (T) -> Content
    var items: [T]
    
    var spacing: CGFloat
    var trailingSpace: CGFloat
    
    @Binding var selectedIndex: Int?
    
    @GestureState private var isDragging: Bool = false
    @GestureState private var offset: CGFloat = 0
    @State private var currentIndex: Int = 0
    @State private var fullWidth: CGFloat = UIScreen.main.fixedCoordinateSpace.bounds.width
    
    init(spacing: CGFloat = 16, trailingSpace: CGFloat = 100, selectedIndex: Binding<Int?>, items: [T], content: @escaping (T) -> Content) {
        self.spacing = spacing
        self.trailingSpace = trailingSpace
        self._selectedIndex = selectedIndex
        self.items = items
        self.content = content
    }
    
    var body: some View {
        GeometryReader { proxy in
            
            let width = proxy.size.width - (trailingSpace - spacing)
            let adjustment = (trailingSpace / 2) - spacing
            LazyHStack(spacing: spacing) {
                ForEach(items) { item in
                    content(item)
                        .frame(width: proxy.size.width - trailingSpace)
                }
            }
            .contentShape(Rectangle())
            .padding(.horizontal, spacing)
            .offset(x: (CGFloat(self.currentIndex) * -width) + (self.currentIndex == 0 ? 0 : adjustment) + self.offset)
            .gesture(
                DragGesture()
                    .updating(self.$offset, body: { value, out, _ in
                        out = value.translation.width
                    })
                    .updating(self.$isDragging, body: { _ , out, _ in
                        out = true
                    })
                    .onEnded({ value in
                        let offsetX = value.translation.width
                        
                        let progress = -offsetX / width
                        let rounded = progress.rounded()

                        self.currentIndex = max(min(self.currentIndex + Int(rounded), self.items.count - 1), 0)
                        self.currentIndex = self.selectedIndex ?? 0
                    })
                    .onChanged({ value in
                        if value.translation.width != CGFloat.zero {
                            let offsetX = value.translation.width
                            let progress = -offsetX / width
                            let rounded = progress.rounded()
                            
                            self.selectedIndex = max(min(self.currentIndex + Int(rounded), self.items.count - 1), 0)
                        }
                    })
            )
            .onAppear {
                self.currentIndex = self.selectedIndex ?? 0
            }
            .onChange(of: self.selectedIndex, perform: { newVal in
                if !isDragging {
                    withAnimation {
                        self.currentIndex = newVal ?? 0
                    }
                }
            })
            .animation(.easeInOut, value: self.offset == 0)
        }
        .frame(height: 260)
    }
}
