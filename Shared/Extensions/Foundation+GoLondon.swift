//
//  Foundation+GoLondon.swift
//  Go London
//
//  Created by Tom Knighton on 19/05/2022.
//

import Foundation


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
