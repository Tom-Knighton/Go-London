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
    
    @State var lineId: String = ""
    @StateObject private var viewModel: LineMapViewModel = LineMapViewModel()
    
    var body: some View {
        LineMapViewRepresntable(viewModel: viewModel)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                Task {
                    self.viewModel.setup(for: self.lineId)
                    await self.viewModel.fetchStopPoints()
                }
            }
    }
}

struct LineMapViewRepresntable: UIViewRepresentable {
    
    @ObservedObject var viewModel: LineMapViewModel
        
    func makeUIView(context: Context) -> MapView {
        let myResourceOptions = ResourceOptions(accessToken: "pk.eyJ1IjoidG9ta25pZ2h0b24iLCJhIjoiY2p0ZWhyb2s2MTR1NzN5bzdtZm9udmJueSJ9.c4dShyMCfZ6JhsnFRf72Rg")
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

        return mapView
    }
    
    func updateUIView(_ uiView: MapView, context: Context) {
        if self.viewModel.lineRoutes != self.viewModel.cachedLineRoutes {
            self.viewModel.updateCachedRoutes()
            self.drawStopPoints(on: uiView)
            
            
        }
        
        if self.viewModel.mapStyle != self.viewModel.cachedMapStyle {
            self.viewModel.updateCachedStyle()
            
            uiView.mapboxMap.loadStyleURI(self.viewModel.mapStyle.loadStyle())
        }
    }
    
    func drawStopPoints(on mapView: MapView) {
        
        let currentStyle = mapView.mapboxMap.style
        
        mapView.viewAnnotations.removeAll()
        
        var index = 0
        
        if let image = UIImage(named: "interchange") {
            try? currentStyle.addImage(image, id: "interchange")
        }
        
        self.viewModel.lineRoutes.forEach { route in
            route.stopPointSequences?.forEach({ branch in
                
                //MARK: Interchange icons
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
                
                let pointId = String(describing: branch.lineId ?? "") + String(describing: index)
                var pointSource = GeoJSONSource()
                pointSource.data = .featureCollection(.init(features: branch.stopPoint?.compactMap { Feature(geometry: Point($0.coordinate))} ?? []))
                var symbolLayer = SymbolLayer(id: pointId)
                symbolLayer.source = pointId
                symbolLayer.iconImage = .constant(.name("interchange"))
                symbolLayer.iconSize = .expression(interchangeIconSize)
                symbolLayer.iconAllowOverlap = .constant(true)
                
                try? currentStyle.addSource(pointSource, id: pointId)
                try? currentStyle.addPersistentLayer(symbolLayer)
                
                //MARK: Lines for routes
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
                
                try? currentStyle.addSource(source, id: "line-id-\(String(describing: index))")
                try? currentStyle.addPersistentLayer(lineLayer, layerPosition: .below("poi-label"))
                
                index += 1
            })
            
            
        }
        
        let coords = self.viewModel.lineRoutes.compactMap { $0.stopPointSequences?.compactMap { $0.stopPoint?.compactMap { $0.coordinate} } }.flatMap { $0 }.flatMap { $0 }
        
        guard !coords.isEmpty else {
            return
        }

        let camOpts = mapView.mapboxMap.camera(for: coords, padding: .init(top: 16, left: 16, bottom: 16, right: 16), bearing: 0, pitch: 0)
        mapView.mapboxMap.setCamera(to: camOpts)
    }
}


