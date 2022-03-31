//
//  HomeView.swift
//  Go London
//
//  Created by Tom Knighton on 23/03/2022.
//

import Foundation
import SwiftUI
import MapboxMaps
import GoLondonSDK

public struct HomeView : View {
    
    @Environment(\.colorScheme) var colourScheme
    
    @State var nearStopPointMarkers: [StopPointAnnotation] = []
    @State var mapCenter: CLLocationCoordinate2D = LocationManager.shared.lastLocation?.coordinate ?? GoLondon.LiverpoolStreetCoord
    @StateObject var coord = TestModel()
    
    var mapboxStyleURI: Binding<StyleURI> { Binding(get: { colourScheme == .dark ? GoLondon.GetDarkStyleURL() : GoLondon.GetLightStyleURL()}, set: { _ in })}
    
    public var body: some View {
        ZStack {
            MapViewRepresentable(mapStyleURI: mapboxStyleURI, mapCenter: $mapCenter, markers: $nearStopPointMarkers, enableCurrentLocation: true)
                .onAppear {
                    search()
                }
                .edgesIgnoringSafeArea(.all)
                .onChange(of: self.nearStopPointMarkers) { newValue in
                    print("NEW MARKERS: \(newValue)")
                }
            
            Button(action: { search() }) {
                Text("Search")
            }.buttonStyle(BorderedProminentButtonStyle())
        }
    }
    
    func search() {
        Task {
            let stopPoints = await GLSDK.Search.SearchAround(latitude: mapCenter.latitude, longitude: mapCenter.longitude)
            self.nearStopPointMarkers.removeAll()
            for point in stopPoints {
                if let point = point as? StopPoint {
                    self.nearStopPointMarkers.append(StopPointAnnotation(stopPoint: point))
                }
            }
        }
    }
}
