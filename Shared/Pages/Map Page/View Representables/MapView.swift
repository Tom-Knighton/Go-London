//
//  MapView.swift
//  Go London
//
//  Created by Tom Knighton on 23/03/2022.
//

import UIKit
import SwiftUI
import GoLondonSDK
import Combine
import MapboxMaps

public struct MapViewRepresentable: UIViewRepresentable {
    
    @ObservedObject var viewModel: MapRepresentableViewModel
    @Binding var selectedIndex: Int?
    
    @State private var cachedSelectedIndex: Int? = -1
    @State private var circleAnnotationManager: CircleAnnotationManager?
    
    @State private var cancelSet: Set<AnyCancellable> = []
    
    @State private var detailedView: UIView? = nil
    
    public class Coordinator: GestureManagerDelegate {
        
        private var parent: MapViewRepresentable
        
        init(_ parent: MapViewRepresentable) {
            self.parent = parent
        }
        
        public func gestureManager(_ gestureManager: GestureManager, didBegin gestureType: GestureType) {}
        
        public func gestureManager(_ gestureManager: GestureManager, didEnd gestureType: GestureType, willAnimate: Bool) {
            guard gestureType == .singleTap else {
                return
            }
            NotificationCenter.default.post(name: .GL_MAP_CLOSE_DETAIL_VIEWS, object: nil)
        }
        
        public func gestureManager(_ gestureManager: GestureManager, didEndAnimatingFor gestureType: GestureType) {}
        
        @objc
        func mapTapped(_ sender: MapTapGesture) {
            guard let mapView = sender.mapView else {
                return
            }

            let point = sender.location(in: mapView)
            
            let options = RenderedQueryOptions(layerIds: ["stopMarkers"], filter: nil)
            mapView.mapboxMap.queryRenderedFeatures(at: point, options: options) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let features):
                    if !features.isEmpty,
                       let first = features.first,
                       let id = first.feature.identifier?.rawValue as? Double {
                        
                        withAnimation {
                            self.parent.selectedIndex = Int(id)
                        }
                    } else {
                        self.parent.selectedIndex = nil
                    }
                    
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        
        func showOnlyPin(of selectedIndex: Int?, for mapView: MapView, zoomTo: Bool = true) {
            
            if let selectedIndex = selectedIndex {
                let stopPoint = self.parent.viewModel.stopPointMarkers[selectedIndex]
                try? mapView.mapboxMap.style.updateLayer(withId: "stopMarkers", type: SymbolLayer.self, update: { (layer: inout SymbolLayer) throws in
                    let opacity = Exp(.switchCase) {
                        Exp(.eq) {
                            Exp(.get) { "id" }
                            stopPoint.id
                        }
                        1
                        
                        0.1
                    }
                    
                    layer.iconOpacity = .expression(opacity)
                })
                
                if zoomTo {
                    mapView.camera.fly(to: CameraOptions(center: stopPoint.coordinate))
                }
            } else {
                try? mapView.mapboxMap.style.updateLayer(withId: "stopMarkers", type: SymbolLayer.self, update: { (layer: inout SymbolLayer) throws in
                    layer.iconOpacity = .constant(1)
                })
            }
            
            
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public func makeUIView(context: Context) -> MapView {
        
        let mapView = MapView(frame: .zero)
        mapView.mapboxMap.loadStyleURI(self.viewModel.mapStyle.loadStyle())

        mapView.gestures.options.pitchEnabled = false
        mapView.gestures.options.pinchRotateEnabled = false
        mapView.gestures.options.panDecelerationFactor = 0.99
        
        mapView.ornaments.logoView.isHidden = true
        mapView.ornaments.attributionButton.isHidden = true
        mapView.ornaments.scaleBarView.isHidden = true
        
        mapView.presentsWithTransaction = true
        mapView.viewAnnotations.validatesViews = false
        
        mapView.mapboxMap.setCamera(to: CameraOptions(center: viewModel.mapCenter, zoom: 12.5))
                
        if viewModel.enableCurrentLocation {
            let cameraLocationConsumer = CameraLocationConsumer(mapView: mapView)
            mapView.location.options.puckType = .puck2D(.makeDefault(showBearing: true))
            mapView.location.options.puckBearingEnabled = true
            
            if viewModel.enableTrackingLocation {
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
            self.cachedSelectedIndex = self.selectedIndex
        }
        
        mapView.mapboxMap.onNext(.mapLoaded) {  _ in
            viewModel.searchedLocation = mapView.mapboxMap.cameraState.center
            resetMarkers(for: mapView)
            
            self.addCircleLayer(for: mapView, radius: 850)
            
            
            let tapGesture = MapTapGesture(target: context.coordinator, action: #selector(context.coordinator.mapTapped(_:)))
            tapGesture.mapView = mapView
            mapView.addGestureRecognizer(tapGesture)
            
        }
        
        mapView.mapboxMap.onEvery(.cameraChanged) { [weak viewModel, weak mapView] _ in
            DispatchQueue.main.async {
                if let center = mapView?.cameraState.center,
                    viewModel?.mapCenter != center {
                    viewModel?.updateCenter(to: center)
                }
            }
        }
        
        mapView.gestures.delegate = context.coordinator
        return mapView
    }
    
    public func updateUIView(_ uiView: MapView, context: Context) {
                
        DispatchQueue.main.async {
            if viewModel.internalCacheStyle != viewModel.mapStyle {
                uiView.mapboxMap.loadStyleURI(viewModel.mapStyle.loadStyle(), completion: nil)
                viewModel.updateCacheStyle()
            }

            if viewModel.stopPointMarkers != viewModel.internalCachedStopPointMarkers {
                viewModel.setSearchedLocation(to: uiView.mapboxMap.cameraState.center)
                viewModel.updateCacheMarkers()
                self.addCircleLayer(for: uiView, radius: 850)
                resetMarkers(for: uiView)
            }

            if viewModel.forceUpdatePosition {
                viewModel.forceUpdatePosition = false
                uiView.camera.fly(to: CameraOptions(center: viewModel.mapCenter, zoom: 12.5))
            }
            
            if self.cachedSelectedIndex != self.selectedIndex {
                context.coordinator.showOnlyPin(of: selectedIndex, for: uiView)
                self.cachedSelectedIndex = self.selectedIndex
            }
        }
    }
    
    func resetMarkers(for uiView: MapView) {
        
        try? uiView.mapboxMap.style.removeLayer(withId: "stopMarkers")
        try? uiView.mapboxMap.style.removeSource(withId: "stopMarkersSource")
        
        var features: [Feature] = []
        
        for index in 0..<self.viewModel.stopPointMarkers.count {
            let marker = self.viewModel.stopPointMarkers[index]
            
            let renderer = ImageRenderer(content: StopPointMarkerView(marker: marker).shadow(radius: 1))
            renderer.scale = UIScreen.main.scale
            if let img = renderer.uiImage {
                try? uiView.mapboxMap.style.addImage(img, id: marker.id)
                
                var feature = Feature(geometry: Point(marker.coordinate))
                
                feature.identifier = FeatureIdentifier(rawValue: index)
                feature.properties = JSONObject(dictionaryLiteral: ("id", JSONValue(marker.id)))
                features.append(feature)
            }
        }
        
        
        var source = GeoJSONSource()
        source.data = .featureCollection(FeatureCollection(features: features))
        
        var pointLayer = SymbolLayer(id: "stopMarkers")
        pointLayer.source = "stopMarkersSource"
        pointLayer.iconImage = .expression(Exp(.get) { "id" })
        pointLayer.iconAllowOverlap = .constant(true)
        pointLayer.iconAnchor = .constant(.bottom)
        pointLayer.symbolZOrder = .constant(.source)
        pointLayer.iconOpacityTransition = StyleTransition(duration: 0.7, delay: 0.3)
        try? uiView.mapboxMap.style.addSource(source, id: "stopMarkersSource")
        try? uiView.mapboxMap.style.addPersistentLayer(pointLayer)
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

// MARK: - Circle Layer
extension MapViewRepresentable {
    
    
    /// Adds circle layer around center of map with specified radius
    /// - Parameter mapView: The mapView to add the layer to
    /// - Parameter radius: The radius of the circle to draw
    func addCircleLayer(for mapView: MapView, radius: Int) {
        let currentStyle = mapView.mapboxMap.style
        let center = viewModel.searchedLocation
        
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
        try? currentStyle.addPersistentLayer(layer)
        
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

// MARK: - Detailed Stop Point View
extension MapViewRepresentable {
    
    func addDetailMarker(on uiView: MapView, for stopPoint: StopPoint) {
        
        if let view = self.detailedView {
            uiView.viewAnnotations.remove(view)
        }
        
        let lineModes = stopPoint.lineModes ?? []
        let lines = Int((stopPoint.name ?? stopPoint.commonName ?? "").count / 23)
        let option = ViewAnnotationOptions(
            geometry: Point(CLLocationCoordinate2D(latitude: CLLocationDegrees(stopPoint.lat ?? 0), longitude:  CLLocationDegrees(stopPoint.lon ?? 0))),
            width: 275,
            height: 205,
            allowOverlap: false,
            anchor: .top,
            offsetX: 0,
            offsetY: (lineModes.contains(.tube) && lineModes.contains(.bus) ? -15 : lineModes.contains(.bus) ? 10 : lineModes.contains(.tube) ? -10 : lineModes.contains(.overground) ? 10 : 25) - (10 * CGFloat(lines)),
            selected: true
        )
        
        
        
        
        let vc = UIHostingController(rootView: StopPointDetailMarkerView(stopPoint: stopPoint))
        vc.view.backgroundColor = .clear
        vc.view.isHidden = true
        try? uiView.viewAnnotations.add(vc.view, options: option)
        self.detailedView = vc.view
        
        
    }
    
    func closeDetailedMarker(for uiView: MapView) {
        guard let view = self.detailedView else {
            return
        }
        
        uiView.viewAnnotations.remove(view)
        self.detailedView = nil
    }
}

// MARK: - Publishers

extension MapViewRepresentable {
//    func addPublishers(for mapView: MapView) {
//        let onShowDetailPublisher = NotificationCenter.default.publisher(for: .GL_MAP_SHOW_DETAIL_VIEW)
//            .compactMap { $0.object as? StopPoint }
//        onShowDetailPublisher
//            .sink { stopPoint in
//                addDetailMarker(on: mapView, for: stopPoint)
//            }
//            .store(in: &cancelSet)
//
//        let onHideDetailPublisher = NotificationCenter.default.publisher(for: .GL_MAP_CLOSE_DETAIL_VIEWS)
//        onHideDetailPublisher
//            .sink { _ in
//                self.closeDetailedMarker(for: mapView)
//            }
//            .store(in: &cancelSet)
//    }
}
