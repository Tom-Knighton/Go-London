//
//  LocationManager.swift
//  Go London
//
//  Created by Tom Knighton on 23/03/2022.
//

import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    static let shared = LocationManager()
    
    private let locationManager = CLLocationManager()
    var locationStatus: CLAuthorizationStatus?
    var lastLocation: CLLocation?
    
    private let locPublisher: PassthroughSubject<CLLocation, Never>
    var publisher: AnyPublisher<CLLocation, Never>
    
    override init() {
        
        locPublisher = PassthroughSubject<CLLocation, Never>()
        publisher = locPublisher.eraseToAnyPublisher()
        
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func start() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func request(always: Bool = false) {
        always ? locationManager.requestAlwaysAuthorization() : locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationStatus = status
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        lastLocation = location
        self.locPublisher.send(location)
    }
}

class LocatorObservable: ObservableObject {
    
    @Published var location = CLLocation()
    var cancellable: AnyCancellable?
    
    init() {
        
    }
    
    func start() {
        cancellable = LocationManager.shared.publisher.assign(to: \.location, on: self)
    }
    
}

class TestModel: ObservableObject {
    
    @Published var coordinate: CLLocationCoordinate2D = GoLondon.LiverpoolStreetCoord
    
    func setCurrent() {
        if let last = LocationManager.shared.lastLocation {
            self.coordinate = last.coordinate
        }
    }
}
