//
//  StopPointOverview.swift
//  GaryGo
//
//  Created by Tom Knighton on 08/10/2021.
//

import SwiftUI
import MapKit

struct StopPointOverview: View {
    
    @State var stopPoint: StopPoint
    @Environment(\.safeAreaInsets) var edges
    
    var body: some View {
        VStack(spacing: 0) {
            GaryGoHeaderView(headerTitle: stopPoint.commonName ?? "Station", colour: Color.blue)
            
            ScrollView {
                if let lat = stopPoint.lat,
                   let long = stopPoint.lon {
                    let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: long), span: MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015))
                    Map(coordinateRegion: .constant(region), annotationItems: [stopPoint], annotationContent: { Point in
                        MapAnnotation(coordinate: region.center) {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 10, height: 10)
                        }
                    })
                    .cornerRadius(15)
                    .padding(.top, 16)
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity, minHeight: 250, alignment: .center)
                    .shadow(radius: 5)
                    .allowsHitTesting(false)
                }
                
                StopPointInfoCard(stopPointInfo: stopPoint.getStopPointInfo())
            }
            Spacer()
        }
        .navigationBarHidden(true)
        .background(Color("Section"))
        
    }
}

fileprivate struct StopPointInfoCard: View {
    
    var stopPointInfo: [StopPoint.StopPointInfo]
    
    var body: some View {
        LineStatusCard {
            VStack {
                Text("Information:")
                    .font(.title2)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 8)
                
                ForEach(stopPointInfo, id: \.infoName) { infoPoint in
                    HStack {
                        Text("\(infoPoint.infoName):")
                            .bold()
                        Spacer()
                        Text(infoPoint.infoValue)
                    }
                    .font(.title3)
                    .padding(.horizontal, 8)
                }
            }
        }
    }
}
