//
//  CustomHeaderView.swift
//  GaryGo
//
//  Created by Tom Knighton on 08/10/2021.
//

import Foundation
import SwiftUI

struct GaryGoHeaderView: View {
    
    var headerTitle: String
    var colour: Color
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Button(action: { dismiss() } ) {
                    Text(Image(systemName: "chevron.backward")) +
                    Text(" Back")
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            
            Spacer().frame(height: 16)
            Text(headerTitle)
                .bold()
                .font(.largeTitle)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
            Spacer().frame(height: 8)
        }
        .edgesIgnoringSafeArea(.top)
        .frame(maxWidth: .infinity, minHeight: 90, maxHeight: 90)
        .background(colour.overlay(.ultraThinMaterial).cornerRadius(15, corners: [.bottomLeft, .bottomRight]).edgesIgnoringSafeArea(.top).shadow(radius: 3))
    }
    
}
