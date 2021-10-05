//
//  DirectionsView.swift
//  GaryGo
//
//  Created by Tom Knighton on 05/10/2021.
//

import Foundation
import SwiftUI

struct DirectionsHomeView: View {
    
    var body: some View {
        VStack {
            Text("Where are we going?")
                .font(.title)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
        }
        .padding(.horizontal, 16)
        .background(Color("Section"))
        .navigationBarTitle("Directions")
    }
}
