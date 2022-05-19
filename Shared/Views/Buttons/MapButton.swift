//
//  MapButton.swift
//  Go London (iOS)
//
//  Created by Tom Knighton on 31/03/2022.
//

import Foundation
import SwiftUI

struct MapButtonStyle: ButtonStyle {
    
    var backgroundColor: Color = .blue
    var textColor: Color = .white
    
    func makeBody(configuration: Configuration) -> some View {
        withAnimation(.easeInOut) {
            configuration.label
                .padding(.vertical, 16)
                .padding(.horizontal, 20)
                .background(configuration.isPressed ? self.backgroundColor.darker(by: 5) : self.backgroundColor)
                .shadow(radius: 3)
                .foregroundColor(self.textColor)
                .clipShape(RoundedRectangle(cornerRadius: 15))
        }
    }
}
