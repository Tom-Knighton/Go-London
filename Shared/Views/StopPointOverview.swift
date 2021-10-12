//
//  StopPointOverview.swift
//  GaryGo
//
//  Created by Tom Knighton on 08/10/2021.
//

import SwiftUI
import MapKit
import CoreLocation
import CoreLocationUI


struct StopPointOverview: View {
    
    @ObservedObject var locationViewModel = GGMapLocationManager()
    @State var stopPoint: StopPoint
    @State var showFullMapView: Bool = false
    @Environment(\.safeAreaInsets) var edges
    @Namespace var animation
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                GaryGoHeaderView(headerTitle: stopPoint.commonName ?? "Station", colour: Color.blue)
                
                ScrollView {
                    if let lat = stopPoint.lat,
                       let long = stopPoint.lon {
                        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: long), span: MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015))
                        
                        Button(action: {
                            withAnimation(Animation.interactiveSpring()) {
                                self.showFullMapView.toggle()
                            }
                        }) {
                            GGMapView(region: .constant(region), annotations: [GGMapAnnotation(title: stopPoint.commonName ?? "", subtitle: nil, coordinate: region.center, iconName: "location.circle")])
                                .cornerRadius(15)
                                .padding(.top, 16)
                                .padding(.horizontal, 16)
                                .frame(maxWidth: .infinity, minHeight: 250, alignment: .center)
                                .shadow(radius: 5)
                                .allowsHitTesting(false)
                        }
                    }
                    
                    StopPointInfoCard(stopPointInfo: stopPoint.getStopPointInfo())
                }
                Spacer()
            }
            
            if self.showFullMapView {
                fullScreenMapView()
                    .transition(.opacity)
            }
        }
        .navigationBarHidden(true)
        .background(Color("Section"))
        
    }
    
    @ViewBuilder
    func fullScreenMapView() -> some View {
        ZStack {
            if let lat = stopPoint.lat,
               let long = stopPoint.lon {
                let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: long), span: MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015))
                
                GGMapView(region: .constant(region), annotations: [GGMapAnnotation(title: stopPoint.commonName ?? "", subtitle: nil, coordinate: region.center, iconName: "location.circle")], allowedShowLocationModes: self.locationViewModel.allowedMapZoomModes, currentShowLocationMode: self.locationViewModel.currentMapZoomMode)
                    .matchedGeometryEffect(id: "mapView", in: animation, isSource: true)
                    .edgesIgnoringSafeArea(.all)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .onAppear {
                        self.locationViewModel.checkIfLocationServiceIsEnabled()
                    }
            }
            
            HStack {
                Spacer()
                VStack {
                    Spacer().frame(height: 16)
                    Button(action: {
                        self.showFullMapView.toggle()
                    }) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.blue)
                            .overlay(Image(systemName: "xmark").foregroundColor(.white))
                            .frame(width: 50, height: 50)
                    }
                    Button(action: { self.locationViewModel.nextMapZoomMode() }) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.blue)
                            .overlay(Image(systemName: "location.fill").foregroundColor(.white))
                            .frame(width: 50, height: 50)
                    }
                    Spacer()
                }
                Spacer().frame(width: 16)
            }
        }
        
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
