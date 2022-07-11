//
//  GeometryGetter.swift
//  Go London (iOS)
//
//  Created by Tom Knighton on 12/07/2022.
//

import Foundation
import SwiftUI

struct GeometryGetter: View {
    @Binding var rect: CGRect

    var body: some View {
        GeometryReader { (g) -> Color in
            DispatchQueue.main.async {
                self.rect = g.frame(in: .global)
            }
            return Color.clear
        }
    }
}
