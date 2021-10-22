//
//  Foundation+GoLondon.swift
//  Go London
//
//  Created by Tom Knighton on 21/10/2021.
//

import Foundation

extension Array where Element: Equatable {
    func removeDuplicates() -> [Element] {
        var result = [Element]()
        
        for value in self {
            if result.contains(value) == false {
                result.append(value)
            }
        }
        
        return result
    }
}

extension String {
    func trim() -> String {
        return self.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
    }
    
    var isRealNumber: Bool {
        guard let first = first else { return false }
        return first.isNumber
    }
}
