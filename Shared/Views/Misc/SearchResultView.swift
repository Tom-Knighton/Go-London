//
//  SearchResultView.swift
//  Go London
//
//  Created by Tom Knighton on 27/04/2022.
//

import Foundation
import SwiftUI
import GoLondonSDK

struct SearchResultView: View {
    
    @State var point: Point
    
    var body: some View {
        VStack {
            if let point = point as? POIPoint {
                Text(point.text ?? "")
                    .font(.title3)
                    .bold()
                
                Text(addressString)
            } else if let point = point as? StopPoint {
                Text(point.commonName ?? point.name ?? "")
                    .font(.title3)
                    .bold()
                modesToDisplay()
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.layer1)
        .cornerRadius(10)
        .shadow(radius: 1)
    }
    
    @ViewBuilder
    func modesToDisplay() -> some View {
        if let point = point as? StopPoint {
            HStack {
                if let _ = point.lineModeGroups {
                    ForEach(point.sortedLineModeGroups, id: \.modeName) { mode in
                        Group {
                            if (mode.modeName != LineMode.tube) {
                                mode.modeName?.image
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                            } else {
                                ForEach(mode.lineIdentifier ?? [], id: \.self) { id in
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(LineMode.lineColour(for: id))
                                        .frame(width: 20, height: 20)
                                }
                            }
                        }
                        .shadow(radius: 3)
                    }
                } else if let _ = point.lineModes {
                    ForEach(point.sortedLineModes, id: \.self) { mode in
                        Group {
                            mode.image
                                .frame(width: 20, height: 20)
                                .aspectRatio(contentMode: .fit)
                        }
                        .shadow(radius: 3)
                    }
                }
            }
        }
    }
    
    var addressString: String {
        if let point = point as? POIPoint {
            var address = point.place_name?.split(separator: ",") ?? []
            address = address.dropFirst().dropLast()
            return address.joined(separator: ",")
        }
        return ""
    }
}

struct resPrev: PreviewProvider {
    
    static var previews: some View {
        SearchResultView(point: GoLondon.defaultStopPoint)
            .previewLayout(.sizeThatFits)
    }
}
