//
//  TubeMapView.swift
//  Go London
//
//  Created by Tom Knighton on 22/05/2022.
//

import Foundation
import SwiftUI
import MapboxMaps
import GoLondonSDK

struct LineMapView: View {
    
    @ObservedObject var viewModel: LineMapViewModel
    
    var body: some View {
        LineMapViewRepresntable(viewModel: viewModel)
            .edgesIgnoringSafeArea(.all)
            .task {
                await self.viewModel.fetchToggledRoutes()
            }
    }
}

struct LineMapViewRepresntable: UIViewRepresentable {
    
    @ObservedObject private var viewModel: LineMapViewModel
    @State private var interchangeIconLayers: [String] = []
    @EnvironmentObject private var globalViewModel: GlobalViewModel
    @State private var coordinateNames: [String: String]
    
    init(viewModel: LineMapViewModel) {
        self.viewModel = viewModel
        self.coordinateNames = [:]
    }
    
    
    func makeUIView(context: Context) -> MapView {
        let mapView: MapView = MapView()
        mapView.mapboxMap.loadStyleURI(self.viewModel.mapStyle.loadStyle())
        
        mapView.gestures.options.pitchEnabled = false
        mapView.gestures.options.pinchRotateEnabled = false
        mapView.gestures.options.panDecelerationFactor = 0.99
        
        mapView.ornaments.logoView.isHidden = true
        mapView.ornaments.attributionButton.isHidden = true
        mapView.ornaments.scaleBarView.isHidden = true
        
        mapView.presentsWithTransaction = true
        
        mapView.location.options.puckType = .puck2D(.makeDefault(showBearing: true))
        mapView.location.options.puckBearingEnabled = true
        
        mapView.mapboxMap.setCamera(to: CameraOptions(center: GoLondon.LiverpoolStreetCoord, zoom: 12.5))
        
        try? mapView.mapboxMap.setCameraBounds(with: CameraBoundsOptions(bounds: GoLondon.UKBounds))
        
        if let image = UIImage(named: "interchange"),
           let freeToTrain = UIImage(named: "freeToTrain"),
           let freeToPlatform = UIImage(named: "freeToPlatform"),
           let accessibilityIssues = UIImage(named: "accessibilityIssues"),
           let partialToPlatform = UIImage(named: "partialToPlatform"),
           let interchangeOnly = UIImage(named: "interchangeOnly") {
            try? mapView.mapboxMap.style.addImage(image, id: "interchange")
            try? mapView.mapboxMap.style.addImage(freeToTrain, id: "freeToTrain")
            try? mapView.mapboxMap.style.addImage(freeToPlatform, id: "freeToPlatform")
            try? mapView.mapboxMap.style.addImage(accessibilityIssues, id: "accessibilityIssues")
            try? mapView.mapboxMap.style.addImage(partialToPlatform, id: "partialToPlatform")
            try? mapView.mapboxMap.style.addImage(interchangeOnly, id: "interchangeOnly")
        }
        
        mapView.mapboxMap.onNext(.mapLoaded) { [weak viewModel, weak mapView] _ in
            if let mapView = mapView,
               viewModel?.lineRoutes.isEmpty == false {
                DispatchQueue.main.async {
                    self.drawMapDetails(on: mapView)
                }
            }
        }
        
        return mapView
    }
    
    func updateUIView(_ uiView: MapView, context: Context) {
        if self.viewModel.lineRoutes != self.viewModel.cachedLineRoutes {
            DispatchQueue.main.async {
                self.viewModel.updateCachedRoutes()
                self.drawMapDetails(on: uiView)
            }
        }
        
        if self.viewModel.mapStyle != self.viewModel.cachedMapStyle {
            self.viewModel.updateCachedStyle()
            
            uiView.mapboxMap.loadStyleURI(self.viewModel.mapStyle.loadStyle())
        }
        
        if self.viewModel.lineFilters != self.viewModel.cachedLineFilters {
            uiView.mapboxMap.loadStyleURI(self.viewModel.mapStyle.loadStyle()) { _ in
                self.drawMapDetails(on: uiView)
            }
            self.viewModel.cachedLineFilters = self.viewModel.lineFilters
        }
        
        if self.viewModel.cachedFilterAccessibility != self.viewModel.filterAccessibility {
            DispatchQueue.main.async {
                
                var points: [Feature] = []
                var names: [Feature] = []
                self.viewModel.lineRoutes.forEach { route in
                    points.append(contentsOf: self.makeInterchangeGeometry(for: route))
                    names.append(contentsOf: self.makeNameGeometry(for: route))
                }
                self.drawInterchanges(features: points, on: uiView)
                self.drawStopNames(features: names, on: uiView)
                self.viewModel.updateCachedAccessibility(to: self.viewModel.filterAccessibility)
            }
        }
    }
    
    func drawMapDetails(on mapView: MapView) {
                
        if let image = UIImage(named: "interchange"),
           let freeToTrain = UIImage(named: "freeToTrain"),
           let freeToPlatform = UIImage(named: "freeToPlatform"),
           let accessibilityIssues = UIImage(named: "accessibilityDisruption"),
           let partialToPlatform = UIImage(named: "partialToPlatform"),
           let interchangeOnly = UIImage(named: "interchangeOnly") {
            try? mapView.mapboxMap.style.addImage(image, id: "interchange")
            try? mapView.mapboxMap.style.addImage(freeToTrain, id: "freeToTrain")
            try? mapView.mapboxMap.style.addImage(freeToPlatform, id: "freeToPlatform")
            try? mapView.mapboxMap.style.addImage(accessibilityIssues, id: "accessibilityIssues")
            try? mapView.mapboxMap.style.addImage(partialToPlatform, id: "partialToPlatform")
            try? mapView.mapboxMap.style.addImage(interchangeOnly, id: "interchangeOnly")
        } else {
            print("Error getting assets")
        }
        
        var lineRoutes = self.viewModel.lineRoutes.filter({ route in
            self.viewModel.lineFilters.contains(where: { $0.lineId == route.lineId ?? "" && $0.toggled })
        })
        
        
        var lines: [Feature] = []
        var interchanges: [Feature] = []
        var names: [Feature] = []
        lineRoutes.mutateEach { route in
            route.stopPointSequences?.mutateEach { branch in
                
                if self.viewModel.lineIds.count != 1 {
                    branch.stopPoint?.mutateEach{ stopPoint in
                        if let coord = self.coordinateNames[stopPoint.icsId ?? ""],
                           let name = stopPoint.name ?? stopPoint.commonName {
                            if name.count < coord.count {
                                self.coordinateNames[stopPoint.icsId ?? ""] = name
                            } else {
                                stopPoint.name = nil
                                stopPoint.commonName = nil
                            }
                        } else {
                            self.coordinateNames[stopPoint.icsId ?? ""] = stopPoint.name ?? stopPoint.commonName ?? ""
                        }
                    }
                }
            }
            
            lines.append(self.makeLineGeometry(for: route))
            interchanges.append(contentsOf: self.makeInterchangeGeometry(for: route))
            names.append(contentsOf: self.makeNameGeometry(for: route))
        }
        
        self.drawLines(features: lines, on: mapView)
        self.drawInterchanges(features: interchanges, on: mapView)
        self.drawStopNames(features: names, on: mapView)
        
        let coords = self.viewModel.lineRoutes.compactMap { $0.stopPointSequences?.compactMap { $0.stopPoint?.compactMap { $0.coordinate} } }.flatMap { $0 }.flatMap { $0 }
        
        guard !coords.isEmpty else {
            return
        }
        
        let camOpts = mapView.mapboxMap.camera(for: coords, padding: .init(top: 16, left: 16, bottom: 16, right: 16), bearing: 0, pitch: 0)
        mapView.mapboxMap.setCamera(to: camOpts)
    }
        
    func makeInterchangeGeometry(for line: LineRoutes) -> [Feature] {
        var features: [Feature] = []
        
        let stops = line.stopPointSequences?.compactMap({ $0.stopPoint }).flatMap ({ $0 })
        features = stops?.compactMap({ stopPoint in
            var feature = Feature(geometry: Point(stopPoint.coordinate))
            
            if self.viewModel.filterAccessibility {
                feature.properties = JSONObject(dictionaryLiteral: ("id", JSONValue(stopPoint.id ?? "")), ("accessibility", JSONValue(self.viewModel.getAccessibilityType(for: stopPoint.name ?? stopPoint.commonName ?? "", with: self.globalViewModel).rawValue)))
            } else {
                feature.properties = JSONObject(dictionaryLiteral: ("id", JSONValue(stopPoint.id ?? "")))
            }
            
            return feature
        }) ?? []
        
        return features
    }
    
    func drawInterchanges(features: [Feature], on mapView: MapView) {
        
        try? mapView.mapboxMap.style.removeLayer(withId: "interchanges")
        try? mapView.mapboxMap.style.removeSource(withId: "interchangesSource")

        let lowZoomSize = 0
        let highZoomSize = 0.8
        let interchangeIconSize = Exp(.interpolate) {
            Exp(.linear)
            Exp(.zoom)
            8
            lowZoomSize
            18
            highZoomSize
        }
        
        let interchangeIcon = Exp(.switchCase) {
            Exp(.eq) {
                Exp(.get) { "accessibility" }
                StationAccessibilityType.None.rawValue
            }
            ""
            
            Exp(.eq) {
                Exp(.get) { "accessibility" }
                StationAccessibilityType.StepFreeToTrain.rawValue
            }
            "freeToTrain"
            
            Exp(.eq) {
                Exp(.get) { "accessibility" }
                StationAccessibilityType.StepFreeToPlatform.rawValue
            }
            "freeToPlatform"
            
            Exp(.eq) {
                Exp(.get) { "accessibility" }
                StationAccessibilityType.PartialToPlatform.rawValue
            }
            "partialToPlatform"
            
            Exp(.eq) {
                Exp(.get) { "accessibility" }
                StationAccessibilityType.InterchangeOnly.rawValue
            }
            "interchangeOnly"
            
            ""
        }
        
        var source = GeoJSONSource()
        source.data = .featureCollection(FeatureCollection(features: features))
        
        var interchangeLayer = SymbolLayer(id: "interchanges")
        interchangeLayer.source = "interchangesSource"
        interchangeLayer.iconImage = self.viewModel.filterAccessibility ? .expression(interchangeIcon) : .constant(.name("interchange"))
        interchangeLayer.iconSize = .expression(interchangeIconSize)
        interchangeLayer.iconAllowOverlap = .constant(true)

        try? mapView.mapboxMap.style.addSource(source, id: "interchangesSource")
        try? mapView.mapboxMap.style.addPersistentLayer(interchangeLayer, layerPosition: .below("poi-label"))
    }
    
    func makeLineGeometry(for line: LineRoutes) -> Feature {
        
        var feature = Feature(geometry: MultiLineString(line.stopPointSequences?.compactMap({ $0.stopPoint?.compactMap { $0.coordinate } }) ?? []))
        
        var offset: Double = 0
        if !self.viewModel.isViewingSingleLine {
            if line.lineId == "circle" {
                offset = -2.5
            } else if line.lineId == "hammersmith-city" {
                offset = 2.5
            }
        }
        
        feature.properties = JSONObject(dictionaryLiteral: ("lineColour", JSONValue(LineMode.lineColour(for: line.lineId ?? "").hexValue)), ("lineId", JSONValue(line.lineId ?? "")), ("lineOffset", JSONValue(rawValue: offset)))
        
        return feature
    }
    
    func drawLines(features: [Feature], on mapView: MapView) {
        let superLowZoomWidth = 1
        let lowZoomWidth = 3
        let highZoomWidth = 15
        let lineWidth = Exp(.interpolate) {
            
            Exp(.linear)
            Exp(.zoom)
            0
            superLowZoomWidth
            12
            lowZoomWidth
            18
            highZoomWidth
        }
        
        var source = GeoJSONSource()
        source.lineMetrics = true
        source.data = .featureCollection(FeatureCollection(features: features))
        
        var lineLayer = LineLayer(id: "line-layers")
        lineLayer.source = "line-id-"
        lineLayer.lineColor = .expression(Exp(.get) { "lineColour" })
        lineLayer.lineWidth = .expression(lineWidth)
        lineLayer.lineCap = .constant(.round)
        lineLayer.lineJoin = .constant(.round)
        lineLayer.lineOpacity = .constant(0.7)
        lineLayer.lineOffset = .expression(Exp(.get) { "lineOffset" })
        
        try? mapView.mapboxMap.style.addSource(source, id: "line-id-")
        try? mapView.mapboxMap.style.addPersistentLayer(lineLayer, layerPosition: .below("poi-label"))
    }
    
    func makeNameGeometry(for line: LineRoutes) -> [Feature] {
        var features: [Feature] = []
        
        let stops = line.stopPointSequences?.compactMap({ $0.stopPoint }).flatMap ({ $0 })
        features = stops?.compactMap({ stopPoint in
            var feature = Feature(geometry: Point(stopPoint.coordinate))
            
            if self.viewModel.filterAccessibility {
                if self.viewModel.getAccessibilityType(for: stopPoint.name ?? stopPoint.commonName ?? "", with: self.globalViewModel) != .None {
                    if let name = self.coordinateNames[stopPoint.icsId ?? ""] {
                    
                        feature.properties = JSONObject(dictionaryLiteral: ("name", JSONValue(name)))
                    } else {
                        return nil
                    }
                } else {
                    return nil
                }
            } else {
                if let name = self.coordinateNames[stopPoint.icsId ?? ""] {
                    feature.properties = JSONObject(dictionaryLiteral: ("name", JSONValue(name)))
                } else {
                    return nil
                }
            }
            
            return feature
        }) ?? []
        
        return features
    }
    
    func drawStopNames(features: [Feature], on mapView: MapView) {
        
        try? mapView.mapboxMap.style.removeLayer(withId: "stopNames")
        try? mapView.mapboxMap.style.removeSource(withId: "stopNamesSource")

        let lowTextSize = 0
        let midTextSize = 20
        let highTextSize = 28
        let stopNameTextSize = Exp(.interpolate) {
            Exp(.linear)
            Exp(.zoom)
            12
            lowTextSize
            17
            midTextSize
            20
            highTextSize
        }
        
        var source = GeoJSONSource()
        source.data = .featureCollection(FeatureCollection(features: features))
        
        var stopNamesLayer = SymbolLayer(id: "stopNames")
        stopNamesLayer.source = "stopNamesSource"
        stopNamesLayer.textField = .expression(Exp(.get) { "name" })
        stopNamesLayer.textSize = .expression(stopNameTextSize)
        stopNamesLayer.textOffset = .constant([0, 2])
        stopNamesLayer.textFont = .constant(["Gill Sans Nova Medium"])
        stopNamesLayer.textHaloColor = .constant(StyleColor(UIColor.black))
        stopNamesLayer.textColor = .constant(StyleColor(UIColor.white))
        stopNamesLayer.textHaloWidth = .constant(1)
        stopNamesLayer.textAllowOverlap = .constant(true)
        
        try? mapView.mapboxMap.style.addSource(source, id: "stopNamesSource")
        try? mapView.mapboxMap.style.addPersistentLayer(stopNamesLayer)

    }
}
