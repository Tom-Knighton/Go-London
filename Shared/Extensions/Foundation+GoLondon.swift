//
//  Foundation+GoLondon.swift
//  Go London
//
//  Created by Tom Knighton on 19/05/2022.
//

import Foundation
import UIKit
import CoreLocation

protocol WeightedElement {
    var weighting: Int { get set }
}

extension Collection where Element: WeightedElement {
    
    func weightedRandomElement() -> Element? {
        guard !self.isEmpty else {
            return nil
        }
        
        let total = self.map { $0.weighting }.reduce(0, +)
        precondition(total > 0, "The total of all weights must be a positive integer")
        
        let rand = Int.random(in: 0..<total)
        var sum = 0
        for item in self {
            sum += item.weighting
            if rand < sum {
                return item
            }
        }
        
        return nil
    }
}

extension Collection where Element: Codable {
    
    func deepCopy() -> [Element] {
        let json = try? JSONEncoder().encode(self.map { $0 })
        
        guard let json = json else {
            return self.map { $0 }
        }
        
        let toReturn = try? JSONDecoder().decode([Element].self, from: json)
        return toReturn ?? self.map { $0 }
    }
}

extension UIApplication {
    
    var keyWindow: UIWindow? {
        // Get connected scenes
        return UIApplication.shared.connectedScenes
        // Keep only active scenes, onscreen and visible to the user
            .filter { $0.activationState == .foregroundActive }
        // Keep only the first `UIWindowScene`
            .first(where: { $0 is UIWindowScene })
        // Get its associated windows
            .flatMap({ $0 as? UIWindowScene })?.windows
        // Finally, keep only the key window
            .first(where: \.isKeyWindow)
    }
    
}

extension CLLocationCoordinate2D: Hashable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(latitude)
        hasher.combine(longitude)
    }
}

extension Array {
    mutating func mutateEach(by transform: (inout Element) throws -> Void) rethrows {
        self = try map { el in
            var el = el
            try transform(&el)
            return el
        }
    }
}

extension UIView {
    public func addTapAction(_ selector: Selector, target: AnyObject) {
        let gesture = UITapGestureRecognizer(target: target, action: selector)
        self.addGestureRecognizer(gesture)
    }
}
