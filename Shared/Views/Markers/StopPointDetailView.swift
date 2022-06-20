//
//  StopPointDetailView.swift
//  Go London
//
//  Created by Tom Knighton on 18/06/2022.
//

import Foundation
import SwiftUI
import GoLondonSDK

struct StopPointDetailView: View {
    
    @State var stopPoint: StopPoint
    
    var body: some View {
        VStack {
            Text(stopPoint.name ?? stopPoint.commonName ?? "")
            Spacer().frame(height: 32)
        }
        .frame(width: 250)
        .padding()
        .background(Material.ultraThin)
        .cornerRadius(10)
    }
}

struct previewstoppointdrtail: PreviewProvider {
    
    static var previews: some View {
        StopPointDetailView(stopPoint: GoLondon.defaultStopPoint)
            .previewLayout(.sizeThatFits)
    }
}
