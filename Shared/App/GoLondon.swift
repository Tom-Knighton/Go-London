//
//  GoLondon.swift
//  Go London
//
//  Created by Tom Knighton on 23/03/2022.
//

import Foundation
import CoreLocation
import MapboxMaps
import GoLondonSDK

public class GoLondon {
    
    public static let LiverpoolStreetCoord: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 51.518752, longitude: -0.081437)
    
    public static let UKBounds: CoordinateBounds = CoordinateBounds(southwest: CLLocationCoordinate2D(latitude: 49.84612, longitude: -11.84651), northeast: CLLocationCoordinate2D(latitude: 59.03151, longitude: 1.04011))
    
    public static var MapboxKey: String {
        if let infoPlistPath = Bundle.main.url(forResource: "Info", withExtension: "plist") {
            do {
                let infoPlistData = try Data(contentsOf: infoPlistPath)
                
                if let dict = try PropertyListSerialization.propertyList(from: infoPlistData, options: [], format: nil) as? [String: Any] {
                    return dict["MBXAccessToken"] as! String
                }
            } catch {
                fatalError("No MBXAccessToken found")
            }
        }
        
        fatalError("No valid Info.plist found")
    }
    
    private static var defaultHomeViewFilters: HomeViewModel.LineModeFilters = HomeViewModel.LineModeFilters([LineMode.bus, LineMode.elizabethLine, LineMode.tube, LineMode.overground, LineMode.nationalRail, LineMode.dlr])

    
    /// Returns the cached homeMapFilters (HomeViewModel.LineModeFilters), or a new object if none was set
    public static var homeFilterCache: HomeViewModel.LineModeFilters {
        get {
            if let data = UserDefaults.standard.data(forKey: "homeFilterCache") {
                do {
                    let filters = try JSONDecoder().decode([HomeViewModel.LineModeFilters.Filter].self, from: data)
                    return HomeViewModel.LineModeFilters(filters: filters)
                } catch {
                    try? UserDefaults.standard.set(JSONEncoder().encode(self.defaultHomeViewFilters.filters), forKey: "homeFilterCache")
                    return self.defaultHomeViewFilters
                }
            } else {
                try? UserDefaults.standard.set(JSONEncoder().encode(self.defaultHomeViewFilters.filters), forKey: "homeFilterCache")
                return self.defaultHomeViewFilters
            }
        }
        
        set {
            try? UserDefaults.standard.set(JSONEncoder().encode(newValue.filters), forKey: "homeFilterCache")
        }
    }
    
    
    /// Returns the cached lineMapFilters, or an empty array if none have been set
    public static var lineMapFilterCache: [LineMapFilter] {
        get {
            if let data = UserDefaults.standard.data(forKey: "lineMapFilterCache") {
                do {
                    let filters = try JSONDecoder().decode([LineMapFilter].self, from: data)
                    return filters
                } catch {
                    return []
                }
            } else {
                return []
            }
        }
        
        set {
            try? UserDefaults.standard.set(JSONEncoder().encode(newValue), forKey: "lineMapFilterCache")
        }
    }
    
#if DEBUG
    public static var defaultStopPoint: StopPoint {
        let decoder = JSONDecoder()
        let stopPoint: StopPoint = try! decoder.decode(StopPoint.self, from: Data("""
{"pointType":"Stop","icsId":null,"zone":null,"id":"940GZZLUMED","naptanId":"940GZZLUMED","name":null,"commonName":"Mile End Underground Station","indicator":null,"stopLetter":null,"hubNaptanCode":null,"lineModeGroups":[{"modeName":"bus","lineIdentifier":["205","25","277","323","425","d6","d7","n205","n25","n277"]},{"modeName":"tube","lineIdentifier":["central","district","hammersmith-city"]}],"children":[{"pointType":"Stop","icsId":null,"zone":null,"id":"9400ZZLUMED1","naptanId":"9400ZZLUMED1","name":null,"commonName":"Mile End Underground Station","indicator":null,"stopLetter":null,"hubNaptanCode":null,"lineModeGroups":[],"children":[],"properties":[{"name":"WiFi","value":"No"},{"name":"Zone","value":"No Information"},{"name":"Waiting Room","value":"No Information"},{"name":"Car Park","value":"No Information"},{"name":"Lifts","value":"No Information"},{"name":"Toilets","value":"No Information"}],"childStationIds":[],"lat":0,"lon":0},{"pointType":"Stop","icsId":null,"zone":null,"id":"9400ZZLUMED2","naptanId":"9400ZZLUMED2","name":null,"commonName":"Mile End Underground Station","indicator":null,"stopLetter":null,"hubNaptanCode":null,"lineModeGroups":[],"children":[],"properties":[{"name":"WiFi","value":"No"},{"name":"Zone","value":"No Information"},{"name":"Waiting Room","value":"No Information"},{"name":"Car Park","value":"No Information"},{"name":"Lifts","value":"No Information"},{"name":"Toilets","value":"No Information"}],"childStationIds":[],"lat":0,"lon":0},{"pointType":"Stop","icsId":null,"zone":null,"id":"9400ZZLUMED3","naptanId":"9400ZZLUMED3","name":null,"commonName":"Mile End Underground Station","indicator":null,"stopLetter":null,"hubNaptanCode":null,"lineModeGroups":[],"children":[],"properties":[{"name":"WiFi","value":"No"},{"name":"Zone","value":"No Information"},{"name":"Waiting Room","value":"No Information"},{"name":"Car Park","value":"No Information"},{"name":"Lifts","value":"No Information"},{"name":"Toilets","value":"No Information"}],"childStationIds":[],"lat":0,"lon":0},{"pointType":"Stop","icsId":null,"zone":null,"id":"9400ZZLUMED4","naptanId":"9400ZZLUMED4","name":null,"commonName":"Mile End Underground Station","indicator":null,"stopLetter":null,"hubNaptanCode":null,"lineModeGroups":[],"children":[],"properties":[{"name":"WiFi","value":"No"},{"name":"Zone","value":"No Information"},{"name":"Waiting Room","value":"No Information"},{"name":"Car Park","value":"No Information"},{"name":"Lifts","value":"No Information"},{"name":"Toilets","value":"No Information"}],"childStationIds":[],"lat":0,"lon":0}],"properties":[{"name":"WiFi","value":"yes"},{"name":"Zone","value":"2"},{"name":"Waiting Room","value":"yes"},{"name":"Car Park","value":"No Information"},{"name":"Lifts","value":"0"},{"name":"Toilets","value":"no"}],"childStationIds":["9400ZZLUMED1","9400ZZLUMED2","9400ZZLUMED3","9400ZZLUMED4"],"lat":51.525124,"lon":-0.03364}
""".utf8))
        return stopPoint
    }
    
#endif
}

public enum MapStyle {
    case DefaultLight, DefaultDark, LinesLight, LinesDark
    
    func loadStyle() -> StyleURI {
        switch self {
        case .DefaultDark:
            guard let darkStyle = StyleURI(rawValue: "mapbox://styles/tomknighton/cl145juvf002h14rkofjuct4r") else {
                return .dark
            }
            return darkStyle
        case .DefaultLight:
            guard let lightStyle = StyleURI(rawValue: "mapbox://styles/tomknighton/cl145dxdf000914m7r7ykij8s") else {
                return .light
            }
            return lightStyle
        case .LinesDark:
            guard let lightStyle = StyleURI(rawValue: "mapbox://styles/tomknighton/cl3um447o001m14l9wc1nss1o") else {
                return MapStyle.DefaultDark.loadStyle()
            }
            return lightStyle
        case .LinesLight:
            guard let lightStyle = StyleURI(rawValue: "mapbox://styles/tomknighton/cl3ulo56o000515nv90e8gl41") else {
                return MapStyle.DefaultLight.loadStyle()
            }
            return lightStyle
        }
    }
}
