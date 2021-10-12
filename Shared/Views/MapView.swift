//
//  MapView.swift
//  GaryGo
//
//  Created by Tom Knighton on 11/10/2021.
//

import Foundation
import MapKit
import SwiftUI


final class GGMapLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var allowedMapZoomModes: [GGMapView.showLocationMode] = [.stopPoint]
    @Published var currentMapZoomMode: GGMapView.showLocationMode = .annotations
    
    private var manager: CLLocationManager?
    
    func nextMapZoomMode() {
        let currentModeIndex = allowedMapZoomModes.firstIndex(where: { $0 == currentMapZoomMode }) ?? -1
        let nextIndex = currentModeIndex + 1
        self.currentMapZoomMode = nextIndex >= allowedMapZoomModes.count ? allowedMapZoomModes[0] : allowedMapZoomModes[nextIndex]
    }
    
    func checkIfLocationServiceIsEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            self.manager = CLLocationManager()
            if let manager = manager {
                manager.delegate = self
            }
        } else {
            print("alert")
        }
    }
    
    private func checkLocationAuthStatus() {
        guard let manager = manager else {
            return
        }
        
        switch manager.authorizationStatus  {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
            break
        case .restricted, .denied:
            self.allowedMapZoomModes = [.stopPoint]
            break
        case .authorizedAlways, .authorizedWhenInUse:
            self.allowedMapZoomModes = [.annotations, .stopPoint, .user]
            break
        @unknown default:
            self.allowedMapZoomModes = [.stopPoint]
            break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.checkLocationAuthStatus()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(String(describing: error))
        print(error.localizedDescription)
    }
}

struct GGMapView: UIViewRepresentable {
    
    @Binding var region: MKCoordinateRegion
    var annotations: [GGMapAnnotation] = []
    
    var allowedShowLocationModes: [showLocationMode] = []
    var currentShowLocationMode: showLocationMode = .stopPoint
    
    enum showLocationMode {
        case annotations, stopPoint, user
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.setRegion(region, animated: false)
        annotations.forEach { annotation in
            let mapAnnotation = MKPointAnnotation()
            mapAnnotation.coordinate = annotation.coordinate
            mapAnnotation.title = annotation.title
            mapAnnotation.subtitle = annotation.subtitle
            mapView.addAnnotation(mapAnnotation)
        }
        mapView.showsUserLocation = true
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        if self.allowedShowLocationModes.isEmpty == false {
            switch self.currentShowLocationMode {
            case .annotations:
                uiView.showAnnotations(uiView.annotations, animated: true)
            case .stopPoint:
                uiView.showAnnotations(uiView.annotations.filter({ $0 is MKUserLocation == false }), animated: true)
            case .user:
                uiView.showAnnotations(uiView.annotations.filter({ $0 is MKUserLocation }), animated: true)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        
        var parent: GGMapView
        
        init(_ parent: GGMapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation {
                return nil
            }
            
            let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "MapMarker")
            annotationView.glyphImage = UIImage(named: "buseslogo")?.withRenderingMode(.alwaysTemplate).withTintColor(.white)
            return annotationView
        }
    }
}

struct GGMapAnnotation {
    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
    let iconName: String?
}
