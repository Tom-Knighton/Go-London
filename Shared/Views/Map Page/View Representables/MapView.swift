//
//  MapView.swift
//  Go London
//
//  Created by Tom Knighton on 23/03/2022.
//

import Foundation
import UIKit
import SwiftUI
import MapboxMaps

public struct MapViewRepresentable: UIViewRepresentable {
    
    @Binding var styleURI: StyleURI
    var enableCurrentLocation: Bool = false
    var enableTracking: Bool = false
    
    @Binding var center: CLLocationCoordinate2D
    
    @Binding var markers: [StopPointAnnotation]
    @State private var setCenter: Bool = false
    
    init(mapStyleURI: Binding<StyleURI>, mapCenter: Binding<CLLocationCoordinate2D>, markers: Binding<[StopPointAnnotation]>, enableCurrentLocation: Bool = false, enableTracking: Bool = false) {
        
        self._styleURI = mapStyleURI
        self._center = mapCenter
        self._markers = markers
        self.enableCurrentLocation = enableCurrentLocation
        self.enableTracking = enableTracking
    }
    
    @State internal var internalCachedMarkers: [StopPointAnnotation] = []
    
    public func makeUIView(context: Context) -> MapView {
        let myResourceOptions = ResourceOptions(accessToken: "pk.eyJ1IjoidG9ta25pZ2h0b24iLCJhIjoiY2p0ZWhyb2s2MTR1NzN5bzdtZm9udmJueSJ9.c4dShyMCfZ6JhsnFRf72Rg")
        let mapInitOptions: MapInitOptions = MapInitOptions(resourceOptions: myResourceOptions, styleURI: styleURI)
        let mapView: MapView = MapView(frame: .zero, mapInitOptions: mapInitOptions)
        
        mapView.gestures.options.pitchEnabled = false
        mapView.gestures.options.pinchRotateEnabled = false
        mapView.gestures.options.panDecelerationFactor = 0.99
        
        mapView.ornaments.logoView.isHidden = true
        mapView.ornaments.attributionButton.isHidden = true
        mapView.ornaments.scaleBarView.isHidden = true

        
        
        print("center: \(self.center), enableCurrent: \(enableCurrentLocation)")
        mapView.mapboxMap.setCamera(to: CameraOptions(center: center, zoom: 15))
        print("Set center to \(center)")
        
        if enableCurrentLocation {
            let cameraLocationConsumer = CameraLocationConsumer(mapView: mapView)
            mapView.location.options.puckType = .puck2D(.makeDefault(showBearing: true))
            mapView.location.options.puckBearingEnabled = true
            
            if enableTracking {
                mapView.mapboxMap.onNext(.mapLoaded, handler: { _ in
                    print("loaded")
                    if let loc = LocationManager.shared.lastLocation?.coordinate {
                        mapView.mapboxMap.setCamera(to: CameraOptions(center: loc, zoom: 15))
                    }
                    
                    mapView.location.addLocationConsumer(newConsumer: cameraLocationConsumer)
                })
                
            }
        }
        mapView.mapboxMap.onNext(.mapLoaded) { _ in
            resetMarkers(for: mapView)
        }
        
        mapView.mapboxMap.onEvery(.cameraChanged) { _ in
            DispatchQueue.main.async {
                if self.center != mapView.cameraState.center {
                    self.center = mapView.cameraState.center
                }
            }
        }
        
        return mapView
    }
    
    public func updateUIView(_ uiView: MapView, context: Context) {
        uiView.mapboxMap.loadStyleURI(styleURI, completion: nil)
        
        DispatchQueue.main.async {
            if self.internalCachedMarkers != self.markers {
                self.internalCachedMarkers = self.markers
                
                resetMarkers(for: uiView)
            }
        }
    }
    
    func resetMarkers(for uiView: MapView) {
        uiView.viewAnnotations.removeAll()
        
        for marker in self.markers {
            let options = ViewAnnotationOptions(
                geometry: Point(marker.coordinate),
                width: 25,
                height: 25,
                allowOverlap: true,
                offsetX: 0,
                offsetY: 20
            )
            let vc = UIHostingController(rootView: StopPointMarkerView(stopPoint: marker.stopPoint))
            vc.view.backgroundColor = .clear
            try? uiView.viewAnnotations.add(vc.view, options: options)
        }
    }
    
    public class CameraLocationConsumer: LocationConsumer {
        weak var mapView: MapView?
        
        init(mapView: MapView) {
            self.mapView = mapView
        }
        
        public func locationUpdate(newLocation: Location) {
            mapView?.mapboxMap.setCamera(to: CameraOptions(center: newLocation.coordinate, zoom: 15))
        }
    }
    
}
