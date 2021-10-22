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

class ArrivalGroupObserver: ObservableObject {
    
    @Published var arrivalGroups: [ArrivalGroup] = []
    
    @Published var isLoading = false
    
    func updateArrivalGroups(for stopPoint: StopPoint) async {
        
        guard !isLoading else { return }
        
        DispatchQueue.main.async {
            self.isLoading = true

            Task { [weak self] in
                self?.arrivalGroups = await StopPointService.GetEstimatedArrivals(for: stopPoint)
                self?.isLoading = false
            }
        }
    }
}


struct StopPointOverview: View {
    
    @ObservedObject var locationViewModel = GGMapLocationManager()
    @State var stopPoint: StopPoint
    @State var showFullMapView: Bool = false
    @Environment(\.safeAreaInsets) var edges
    @Namespace var animation
    
    @ObservedObject var arrivalGroupObserver = ArrivalGroupObserver()
    
    let arrivalsTimer = Timer.publish(every: 30.0, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                GaryGoHeaderView(headerTitle: stopPoint.commonName ?? "Station", colour: Color.blue)
                
                ScrollView {
                    VStack {
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
                        
                        if self.arrivalGroupObserver.isLoading && self.arrivalGroupObserver.arrivalGroups.count == 0 {
                            LottieView(name: "SearchingGif", loopMode: .loop)
                                .frame(width: 250, height: 250, alignment: .center)
                        }
                        ForEach(self.arrivalGroupObserver.arrivalGroups, id: \.lineName) { arrivalGroup in
                            StopPointArrivalsard(lineName: arrivalGroup.lineName, arrivals: arrivalGroup.getPlatformArrivalGroups())
                        }
                    }
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
        .onReceive(arrivalsTimer, perform: { _ in
            Task {
                await loadArrivalsHere()
            }
        })
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification), perform: { _ in
            Task {
                await loadArrivalsHere()
            }
        })
        .task {
            await loadArrivalsHere()
        }
    }
    
    func loadArrivalsHere() async {
        await self.arrivalGroupObserver.updateArrivalGroups(for: self.stopPoint)
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

fileprivate struct StopPointArrivalsard: View {
    
    var lineName: String
    var arrivals: [ArrivalGroup.PlatformArrivalGroup]
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text(lineName)
                    .font(.title2)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(GaryTubeConstants.getLineColour(from: lineName).overlay(Material.thin).shadow(radius: 5))
            
            ForEach(arrivals, id: \.platformName) { arrivalGroup in
                HStack {
                    VStack {
                        Text(arrivalGroup.direction)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(arrivalGroup.platformName)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    arrivalTimes(arrivals: arrivalGroup.arrivals)
                    Spacer()
                }
                .font(.title3)
                .padding(.horizontal, 8)
            }
            
            if arrivals.count == 0 {
                Text("Check Station Boards")
                    .bold()
                    .font(.system(.title3, design: .rounded))
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            Spacer().frame(height: 8)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .background(Color("Section2"))
        .cornerRadius(15)
        .shadow(radius: 5)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
    
    @ViewBuilder
    func arrivalTimes(arrivals: [StopPointArrival]) -> some View {
        VStack {
            if arrivals.count >= 1, let firstArrival = arrivals.first {
                Text(getNextArrivalText(for: firstArrival))
                    .bold()
                    .font(.system(size: 19, design: .rounded))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                Text(getNextThreeArrivalsText(for:arrivals))
                    .frame(maxWidth: .infinity, alignment: .trailing)
            } else {
                Text("Check Station Boards")
            }
        }
        .font(.system(size: 14, weight: .light, design: .rounded))
        .multilineTextAlignment(.trailing)
    }
    
    func getNextArrivalText(for arrival: StopPointArrival) -> String {
        return arrival.friendlyDueTime == "Due" ? "Due" : arrival.friendlyDueTime + " min"
    }
    
    func getNextThreeArrivalsText(for arrivals: [StopPointArrival]) -> String {
        
        guard arrivals.count > 1 else { return "" }
        let maxIndex = 3 >= arrivals.count ? arrivals.count - 1 : 3
        var friendlyText = "Then "
        
        for i in 1...maxIndex {
            friendlyText += arrivals[i].friendlyDueTime + (i == maxIndex ? " mins" : ", ")
        }
        return friendlyText
    }
}

