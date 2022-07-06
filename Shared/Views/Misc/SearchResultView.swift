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
        ZStack {
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
            HStack {
                Spacer()
                Image(systemName: "chevron.forward")
                    .font(Font.system(.caption).weight(.bold))
                    .foregroundColor(Color(UIColor.tertiaryLabel))
                Spacer().frame(width: 8)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.layer1)
        .cornerRadius(10)
        .shadow(radius: 1)
    }
    
    func findTubeModeGroup() -> LineModeGroup? {
        guard let point = point as? StopPoint else {
            return nil
        }
        
        return point.lineModeGroups?.first(where: { $0.modeName == .tube })
    }
    
    @ViewBuilder
    func modesToDisplay() -> some View {
        if let point = point as? StopPoint {
            HStack {
                if let _ = point.lineModes {
                    ForEach(point.sortedLineModes, id: \.self) { mode in
                        if mode == .tube, let tubeGroup = self.findTubeModeGroup() {
                            ForEach(tubeGroup.lineIdentifier ?? [], id: \.self) { id in
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(LineMode.lineColour(for: id))
                                    .frame(width: 20, height: 20)
                                    .shadow(radius: 3)
                            }
                        } else {
                            mode.image
                                .frame(width: 20, height: 20)
                                .aspectRatio(contentMode: .fit)
                                .shadow(radius: 3)
                        }
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
