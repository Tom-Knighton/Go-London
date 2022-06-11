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
            .onAppear {
                Task {
                    await self.viewModel.fetchToggledRoutes()
                }
            }
            .rotationEffect(.degrees(0.1))
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
        let myResourceOptions = ResourceOptions(accessToken: GoLondon.MapboxKey)
        let mapInitOptions: MapInitOptions = MapInitOptions(resourceOptions: myResourceOptions, styleURI: self.viewModel.mapStyle.loadStyle())
        let mapView: MapView = MapView(frame: .zero, mapInitOptions: mapInitOptions)
        
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
                self.interchangeIconLayers.forEach { layer in
                    try? uiView.mapboxMap.style.removeLayer(withId: layer)
                }
                self.interchangeIconLayers = []
                
                var index = 0
                self.viewModel.lineRoutes.forEach { route in
                    route.stopPointSequences?.forEach({ branch in
                        self.drawInterchangeIcons(on: uiView, for: branch, index: index, filterStepFree: self.viewModel.filterAccessibility)
                        index += 1
                    })
                }
                self.viewModel.updateCachedAccessibility(to: self.viewModel.filterAccessibility)
            }
        }
    }
    
    func drawMapDetails(on mapView: MapView) {
        
        mapView.viewAnnotations.removeAll()
        
        var index = 0
        
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
        
        lineRoutes.mutateEach { route in
            route.stopPointSequences?.mutateEach { branch in
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
                
                
                self.drawInterchangeIcons(on: mapView, for: branch, index: index)
                self.drawStopNames(on: mapView, for: branch, index: index)
                self.drawLines(on: mapView, for: branch, index: index)
                
                index += 1
            }
        }
        
        let coords = self.viewModel.lineRoutes.compactMap { $0.stopPointSequences?.compactMap { $0.stopPoint?.compactMap { $0.coordinate} } }.flatMap { $0 }.flatMap { $0 }
        
        guard !coords.isEmpty else {
            return
        }
        
        let camOpts = mapView.mapboxMap.camera(for: coords, padding: .init(top: 16, left: 16, bottom: 16, right: 16), bearing: 0, pitch: 0)
        mapView.mapboxMap.setCamera(to: camOpts)
    }
    
    func drawInterchangeIcons(on mapView: MapView, for branch: Branch, index: Int, filterStepFree: Bool = false) {
        let lowZoomSize = 0
        let highZoomSize = filterStepFree ? 1.8 : 0.8
        let interchangeIconSize = Exp(.interpolate) {
            Exp(.linear)
            Exp(.zoom)
            8
            lowZoomSize
            filterStepFree ? 14 : 18
            highZoomSize
        }
        
        let pointId = String(describing: branch.lineId ?? "") + String(describing: index)
        var pointSource = GeoJSONSource()
        pointSource.data = .featureCollection(.init(features: branch.stopPoint?.compactMap {
            
            var feat = Feature(geometry: Point($0.coordinate))
            let stopName = ($0.commonName ?? $0.name ?? "").replacingOccurrences(of: "Underground", with: "").replacingOccurrences(of: "Station", with: "").replacingOccurrences(of: "Rail", with: "").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            // Gets relevant accessible data
            let isViewingSingleLine = self.viewModel.lineIds.count == 1
            var accessibleView: StationAccessibilityType? = .None
            if let accessibleData = globalViewModel.iradData.first(where: { spa in // If we have data for this stop
                spa.stationName == stopName
            }) {
                if !isViewingSingleLine, // If we are viewing a single line only
                   let lineData = accessibleData.lineAccessibility?.first(where: { spla in // And we have data for this line at this top
                       self.viewModel.lineIds.contains { $0.contains(spla.lineName ?? "UNK__" )}
                   }) {
                    accessibleView = lineData.accessibility // Set the data for that line
                } else {
                    accessibleView = accessibleData.overviewAccessibility // Otherwise set the general overview for the station
                }
            }
            
            feat.properties = JSONObject(dictionaryLiteral: ("stopName", JSONValue(stopName)), ("accessibility", JSONValue(accessibleView?.rawValue ?? "None")))
            return feat
            
        } ?? []))
        
        var symbolLayer = SymbolLayer(id: pointId)
        symbolLayer.source = pointId
        
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
            
            "interchange"
        }
        
        
        symbolLayer.iconImage = filterStepFree ? .expression(interchangeIcon) : .constant(.name("interchange"))
        symbolLayer.iconSize = .expression(interchangeIconSize)
        symbolLayer.iconAllowOverlap = .constant(true)
        
        try? mapView.mapboxMap.style.addSource(pointSource, id: pointId)
        try? mapView.mapboxMap.style.addLayer(symbolLayer)
        self.interchangeIconLayers.append(pointId)
    }
    
    func drawStopNames(on mapView: MapView, for branch: Branch, index: Int, filterStepFree: Bool = false) {
        let nameId = "names-" + String(describing: branch.lineId ?? "") + String(describing: index)
        var nameSource = GeoJSONSource()
        nameSource.data = .featureCollection(.init(features: branch.stopPoint?.compactMap {
            
            var feat = Feature(geometry: Point($0.coordinate.coordinate(at: LocationDistance(1), facing: LocationDirection(180))))
            feat.properties = JSONObject(dictionaryLiteral: ("stopName", JSONValue(self.coordinateNames[$0.commonName ?? $0.name ?? ""] ?? $0.commonName ?? $0.name ?? "")))
            return feat
            
        } ?? []))
        
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
        
        var stopNamesLayer = SymbolLayer(id: "names-\(String(describing: index))")
        stopNamesLayer.source = nameId
        stopNamesLayer.textField = .expression(Exp(.get) { "stopName" })
        stopNamesLayer.textSize = .expression(stopNameTextSize)
        stopNamesLayer.textOffset = .constant([0, 2])
        stopNamesLayer.textFont = .constant(["Gill Sans Nova Medium"])
        stopNamesLayer.textHaloColor = .constant(StyleColor(UIColor.black))
        stopNamesLayer.textColor = .constant(StyleColor(UIColor.white))
        stopNamesLayer.textHaloWidth = .constant(1)
        stopNamesLayer.textAllowOverlap = .constant(true)
        
        try? mapView.mapboxMap.style.addSource(nameSource, id: nameId)
        try? mapView.mapboxMap.style.addLayer(stopNamesLayer)
    }
    
    
    func drawLines(on mapView: MapView, for branch: Branch, index: Int) {
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
        source.data = .feature(Feature(geometry: LineString(branch.stopPoint?.compactMap { $0.coordinate } ?? [] )))
        var lineLayer = LineLayer(id: "line-layer-\(String(describing: index))")
        lineLayer.source = "line-id-\(String(describing: index))"
        lineLayer.lineColor = .constant(StyleColor(UIColor(LineMode.lineColour(for: branch.lineId ?? ""))))
        lineLayer.lineWidth = .expression(lineWidth)
        lineLayer.lineCap = .constant(.round)
        lineLayer.lineJoin = .constant(.round)
        lineLayer.lineOpacity = .constant(0.7)
        
        if branch.lineId == "circle" {
            lineLayer.lineOffset = .constant(-2.5)
        }
        
        if branch.lineId == "district" {
            lineLayer.lineOffset = .constant(2.5)
        }
        
        try? mapView.mapboxMap.style.addSource(source, id: "line-id-\(String(describing: index))")
        try? mapView.mapboxMap.style.addLayer(lineLayer, layerPosition: .below("poi-label"))
    }
    
}
