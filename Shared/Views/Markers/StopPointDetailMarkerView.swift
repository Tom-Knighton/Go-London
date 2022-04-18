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
            Text(self.stopPoint.commonName ?? self.stopPoint.name ?? "")
                .font(.title3)
                .bold()
                .fixedSize(horizontal: false, vertical: true)
            
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
            
            lineIdentifierCapsules()
           
        }
        .padding()
        .background(Color.layer1)
        .cornerRadius(15)
        .shadow(radius: 3)
    }
    
    @ViewBuilder
    func lineIdentifierCapsules() -> some View {
        VStack {
            if let groups = self.stopPoint.lineModeGroups {
                ForEach(groups, id: \.modeName) { lineMode in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(lineMode.lineIdentifier ?? [], id: \.self) { identifier in
                                lineIdentifierCapsuleText(for: lineMode, lineIdentifier: identifier)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func lineIdentifierCapsuleText(for lineMode: LineModeGroup, lineIdentifier: String)  -> some View{
        if lineMode.modeName == .bus {
            Text(lineIdentifier)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
        } else if lineMode.modeName == .tube {
            Text(LineMode.friendlyTubeLineName(for: lineIdentifier))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(LineMode.lineColour(for: lineIdentifier))
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }
}

struct StopPointDetail: PreviewProvider {
    
    static var previews: some View {
        StopPointDetailMarkerView(stopPoint: GoLondon.defaultStopPoint)
            .previewLayout(.sizeThatFits)
    }
}
