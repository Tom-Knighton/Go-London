//
//  StopPointMarker.swift
//  Go London (iOS)
//
//  Created by Tom Knighton on 27/03/2022.
//

import Foundation
import SwiftUI
import GoLondonSDK

struct DropPin: Shape {
    var startAngle: Angle = .degrees(180)
    var endAngle: Angle = .degrees(0)
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addCurve(to: CGPoint(x: rect.minX, y: rect.midY),
                      control1: CGPoint(x: rect.midX, y: rect.maxY),
                      control2: CGPoint(x: rect.minX, y: rect.midY + rect.height / 4))
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: rect.width / 2, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        path.addCurve(to: CGPoint(x: rect.midX, y: rect.maxY),
                      control1: CGPoint(x: rect.maxX, y: rect.midY + rect.height / 4),
                      control2: CGPoint(x: rect.midX, y: rect.maxY))
        return path
    }
}

struct StopPointMarkerView: View {
    
    @State private var isDetailViewOpen: Bool = false
    @State private var shouldOpenDetailView: Bool = false
    
    let stopPoint: StopPoint
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                ZStack {
                    
                    let isBus = stopPoint.isBusOnly == true || stopPoint.isBusStand == true
                    
                    Circle()
                        .frame(width: 30, height: 30)
                        .shadow(radius: 3)
                        .foregroundColor(isBus ? .red : .white)
                    
                    if isBus {
                        if stopPoint.isBusOnly == true, let letter = stopPoint.stopLetter {
                            Text(letter)
                                .bold()
                                .minimumScaleFactor(0.2)
                                .frame(width: 30, height: 30, alignment: .center)
                        } else {
                            Image("tfl")
                                .resizable()
                                .frame(width: 25, height: 25, alignment: .center)
                                .foregroundColor(.white)
                                .shadow(radius: 2, x: 1, y: -1)
                        }
                        
                    } else {
                        
                        logoImage()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25, alignment: .center)
                            .shadow(radius: 2, x: 1, y: -1)
                    }
                }
                
                Rectangle()
                    .frame(width: 1, height: 15)
                    .foregroundColor(.primary)
            }
            .foregroundColor(.white)
            .onTapGesture {
                NotificationCenter.default.post(name: .GL_MAP_SHOW_DETAIL_VIEW, object: self.stopPoint)
                print("sending")
            }
        }

    }
    
    @ViewBuilder
    func logoImage() -> some View {
        let modes = self.stopPoint.lineModeGroups ?? []
        
        if modes.isEmpty {
            Image("tfl")
                .resizable()
                .foregroundColor(.red)
        }
        
        if let mode = self.stopPoint.mostSignificantLineMode {
            mode.image
        }
    }
    
}
