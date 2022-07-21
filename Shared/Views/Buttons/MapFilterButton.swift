//
//  MapFilterButton.swift
//  Go London
//
//  Created by Tom Knighton on 07/06/2022.
//

import Foundation
import SwiftUI

struct MapFilterButton: ButtonStyle {
    
    var height: CGFloat
    var backgroundColour: Color
    
    func makeBody(configuration: Configuration) -> some View {
        withAnimation(.easeInOut) {
            configuration.label
                .frame(maxWidth: .infinity, minHeight: height, maxHeight: .infinity)
                .padding(.vertical, 8)
                .padding(.horizontal, 2)
                .background(self.backgroundColour)
                .brightness(configuration.isPressed ? -0.1 : 0)
                .cornerRadius(15)
                .shadow(radius: 3)
                    
        }
    }
}
