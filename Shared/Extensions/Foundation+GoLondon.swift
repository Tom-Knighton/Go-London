//
//  Foundation+GoLondon.swift
//  Go London
//
//  Created by Tom Knighton on 19/05/2022.
//

import Foundation
import UIKit

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
