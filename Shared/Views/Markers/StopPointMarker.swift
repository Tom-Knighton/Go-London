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
    
    let stopPoint: StopPoint?
    
    var body: some View {
        ZStack {
            
            let isBus = (stopPoint?.lineModeGroups?.count == 1 && stopPoint?.lineModeGroups?.first?.modeName == "bus")
            
            Circle()
                .frame(width: 30, height: 30)
                .shadow(radius: 3)
                .foregroundColor(isBus ? .red : .white)
            
            if isBus {
                Text(stopPoint?.name ?? "S")
                    .foregroundColor(Color(uiColor: UIColor.label))
                    .frame(width: 25, height: 25, alignment: .center)
            } else {
                Image("tfl")
                    .resizable()
                    .frame(width: 20, height: 20, alignment: .center)
                    .foregroundColor(.blue)
                    .shadow(radius: 2, x: 1, y: -1)
            }
        }
    }
}

struct StopPointMarkerPreviews: PreviewProvider {
    
    static var previews: some View {
        StopPointMarkerView(stopPoint: nil)
    }
}
