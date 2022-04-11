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
    @State private var internalCacheStyle: StyleURI?
    
    var enableCurrentLocation: Bool = false
    var enableTracking: Bool = false
    
    @Binding var center: CLLocationCoordinate2D
    
    @Binding var markers: [StopPointAnnotation]
    @State private var setCenter: Bool = false
    
    @State var circleAnnotationManager: CircleAnnotationManager?
    
    @Binding var forceUpdatePosition: Bool
    
    @State private var searchedLocation: CLLocationCoordinate2D?
    
    init(mapStyleURI: Binding<StyleURI>, mapCenter: Binding<CLLocationCoordinate2D>, markers: Binding<[StopPointAnnotation]>, enableCurrentLocation: Bool = false, enableTracking: Bool = false, forceUpdatePosition: Binding<Bool>? = nil) {
        
        self._styleURI = mapStyleURI
        self._center = mapCenter
        self._markers = markers
        self.enableCurrentLocation = enableCurrentLocation
        self.enableTracking = enableTracking
        self._forceUpdatePosition = forceUpdatePosition ?? .constant(false)
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
        
        mapView.mapboxMap.setCamera(to: CameraOptions(center: center, zoom: 12.5))
        
        if enableCurrentLocation {
            let cameraLocationConsumer = CameraLocationConsumer(mapView: mapView)
            mapView.location.options.puckType = .puck2D(.makeDefault(showBearing: true))
            mapView.location.options.puckBearingEnabled = true
            
            if enableTracking {
                mapView.mapboxMap.onNext(.mapLoaded, handler: { _ in
                    if let loc = LocationManager.shared.lastLocation?.coordinate {
                        mapView.mapboxMap.setCamera(to: CameraOptions(center: loc, zoom: 12.5))
                    }
                    
                    mapView.location.addLocationConsumer(newConsumer: cameraLocationConsumer)
                })
            }
        }
        
        DispatchQueue.main.async {
            self.circleAnnotationManager = mapView.annotations.makeCircleAnnotationManager()
        }
        
        mapView.mapboxMap.onNext(.mapLoaded) { _ in
            self.searchedLocation = mapView.mapboxMap.cameraState.center
            resetMarkers(for: mapView)
            
            self.addCircleLayer(for: mapView, radius: 1000)
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
        
        self.addCircleLayer(for: uiView, radius: 1000)
          
        DispatchQueue.main.async {
            if self.internalCacheStyle != self.styleURI {
                uiView.mapboxMap.loadStyleURI(styleURI, completion: nil)
                self.internalCacheStyle = self.styleURI
                self.addCircleLayer(for: uiView, radius: 1000)
            }
            
            if self.internalCachedMarkers != self.markers {
                self.searchedLocation = uiView.mapboxMap.cameraState.center
                self.internalCachedMarkers = self.markers
                self.addCircleLayer(for: uiView, radius: 1000)
                resetMarkers(for: uiView)
            }
            
            if self.forceUpdatePosition {
                self.forceUpdatePosition = false
                uiView.camera.fly(to: CameraOptions(center: self.center, zoom: 12.5))
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
            mapView?.mapboxMap.setCamera(to: CameraOptions(center: newLocation.coordinate, zoom: 13))
        }
    }
}

// MARK: - Circle Layer
extension MapViewRepresentable {
    
    
    /// Adds circle layer around center of map with specified radius
    /// - Parameter mapView: The mapView to add the layer to
    /// - Parameter radius: The radius of the circle to draw
    func addCircleLayer(for mapView: MapView, radius: Int) {
        let currentStyle = mapView.mapboxMap.style
        let center = self.searchedLocation
        
        guard let center = center else { return }
        
        try? currentStyle.removeLayer(withId: "search-circle-layer")
        try? currentStyle.removeSource(withId: "search-circle-source")
        
        var source = GeoJSONSource()
        let point = Feature(geometry: Point(center))
        source.data = .feature(point)
        
        var layer = CircleLayer(id: "search-circle-layer")
        layer.source = "search-circle-source"
        
        let circleRadiusExp = Exp(.interpolate) {
            Exp(.linear)
            Exp(.zoom)
            
            self.zoomRadii(for: mapView, radius: radius + 150)
        }
        layer.circleRadius = .expression(circleRadiusExp)
        layer.circleColor = .constant(StyleColor(UIColor.clear))
        layer.circleStrokeColor = .constant(StyleColor(UIColor.systemBlue))
        layer.circleStrokeWidth = .constant(2.0)
        layer.circleStrokeOpacity = .constant(1.0)
        
        try? currentStyle.addSource(source, id: "search-circle-source")
        try? currentStyle.addLayer(layer)
        
    }
    
    /// Gets  the dictionary containing the radii of the circles to draw at each map zoom level
    /// - Parameter mapView: The map view to add the circle to
    /// - Parameter radius: The radius of the circle to draw
    /// - Returns: A dictionary of the radii of circles based on each zoom level of the map
    func zoomRadii(for mapView: MapView, radius: Int = 1250) -> [Double: Double] {
        
        /// Returns the circle pixel radius to draw on the map, based on the zoom level and the desired meter radius
        /// - Parameters:
        ///   - zoom: The zoom level of the map
        ///   - center: The center coordinate to draw the point from
        ///   - radius: The radius of the desired circle in meters
        /// - Returns: The pixel radius of the circle to draw
        func circleRadius(for zoom: CGFloat, at center: CLLocationCoordinate2D, radius: Int = 1250) -> Double {
            let metersPerPoint = Projection.metersPerPoint(for: center.latitude, zoom: zoom)

            let radius = Double(radius) / metersPerPoint
            return radius
        }
        
        let center = mapView.mapboxMap.cameraState.center
        var radii: [Double: Double] = [:]
        for i in stride(from: 0, through: 22, by: 0.1) {
            radii[i] = circleRadius(for: i, at: center, radius: radius)
        }
        return radii
    }
    
}
