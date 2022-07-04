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
            NavigationLink(value: stopPoint) {
                Spacer()
                Text(stopPoint.name ?? stopPoint.commonName ?? "")
                Spacer()
                Image(systemName: "chevron.forward")
                    .font(Font.system(.caption).weight(.bold))
                    .foregroundColor(Color(UIColor.tertiaryLabel))
                Spacer().frame(width: 8)
            }
            .foregroundColor(.primary)
            .padding(6)
            .shadow(radius: 3)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.gradient, lineWidth: 1)
            )
            
            Spacer()
            HStack(alignment: .center) {
                ForEach(stopPoint.lineModeGroups ?? [], id: \.modeName) { lineMode in
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
                        .shadow(radius: 3)
                        
                    }
                }
            }
            
            lineIdentifierCapsules()
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Material.ultraThin)
        .cornerRadius(10)
    }
    
    @ViewBuilder
    func lineIdentifierCapsules() -> some View {
        if let groups = stopPoint.lineModeGroups {
            VStack {
                ForEach(groups, id: \.modeName) { lineMode in
                    ViewThatFits {
                        AnyLayout(FlowLayout(alignment: Alignment(horizontal: .center, vertical: .center))) {
                            ForEach(lineMode.lineIdentifier ?? [], id: \.self) { identifier in
                                lineIdentifierCapsuleText(for: lineMode, lineIdentifier: identifier)
                            }
                        }
                        
                        ScrollView(.horizontal) {
                            LazyHStack {
                                ForEach(lineMode.lineIdentifier ?? [], id: \.self) { identifier in
                                    lineIdentifierCapsuleText(for: lineMode, lineIdentifier: identifier)
                                }
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

