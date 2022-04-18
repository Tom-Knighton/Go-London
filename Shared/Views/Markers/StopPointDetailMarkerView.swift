//
//  StopPointDetailMarkerView.swift
//  Go London
//
//  Created by Tom Knighton on 14/04/2022.
//

import Foundation
import SwiftUI
import GoLondonSDK

struct StopPointDetailMarkerView: View {
    
    @State var stopPoint: StopPoint
    
    var body: some View {
        VStack {
            Text(self.stopPoint.commonName ?? self.stopPoint.name ?? "AHHH")
                .font(.title3)
                .bold()
            Text("Slimmy jimmies")
        }
        .padding()
        .background(Color.layer1)
        .cornerRadius(15)
        .shadow(radius: 3)
    }
}

struct StopPointDetail: PreviewProvider {
    
    static var previews: some View {
        StopPointDetailMarkerView(stopPoint: GoLondon.defaultStopPoint)
            .previewLayout(.sizeThatFits)
    }
}
