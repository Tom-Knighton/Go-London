//
//  MapButton.swift
//  Go London (iOS)
//
//  Created by Tom Knighton on 31/03/2022.
//

import Foundation
import SwiftUI

struct MapButtonStyle: ButtonStyle {
    
    var backgroundColor: Color = .layer2
    var textColor: Color = .blue
    
    func makeBody(configuration: Configuration) -> some View {
        withAnimation(.easeInOut) {
            configuration.label
                .padding(20)
                .clipShape(Circle())
                .background(Circle().fill(self.backgroundColor))
                .brightness(configuration.isPressed ? -0.1 : 0)
                .shadow(radius: 3)
                .foregroundColor(self.textColor)
                .font(.system(size: 20))
        }
    }
}
