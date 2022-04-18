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
            
            
            HStack(alignment: .center) {
                ForEach(self.stopPoint.lineModeGroups ?? [], id: \.modeName) { lineMode in
                    VStack {
                        Group {
                            if let image = lineMode.modeName?.image {
                                image
                            } else {
                                Image("tfl").resizable().foregroundColor(.red)
                            }
                        }
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25)
                    }
                }
            }
            
            VStack {
                ForEach(self.stopPoint.lineModeGroups ?? [], id: \.modeName) { lineMode in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(lineMode.lineIdentifier ?? [], id: \.self) { identifier in
                                if lineMode.modeName == .bus {
                                    Text(identifier)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(Color.red)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                            }
                        }
                    }
                }
            }
            
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
