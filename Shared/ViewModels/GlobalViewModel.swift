//
//  GlobalViewModel.swift
//  Go London
//
//  Created by Tom Knighton on 04/06/2022.
//

import Foundation
import GoLondonSDK
import SwiftUI

@MainActor
public class GlobalViewModel: ObservableObject {
    
    @Published var iradData: [StopPointAccessibility] = []
    
    func setup() async {
        let lastCachedAccessibility = await GLSDK.Meta.GetLastAccessibilityCacheTime()
        let lastCachedLocalInt = UserDefaults.standard.double(forKey: "lastCachedLradTime")
        let lastCachedLocal = Date(timeIntervalSince1970: lastCachedLocalInt)
        
        
        if lastCachedLocalInt == 0 {
            
            await getIradData()
            return
        }
        
        if lastCachedLocalInt != 0,
            let lastCachedAccessibility = lastCachedAccessibility,
            lastCachedAccessibility > lastCachedLocal {
        
            await getIradData()
            return
        }
        
        if let data = UserDefaults.standard.data(forKey: "iradData"),
           let decompiled = try? JSONDecoder().decode([StopPointAccessibility].self, from: data) {

            self.iradData = decompiled
        } else {
            
            await getIradData()
        }
    }
    
    private func getIradData() async {
        let data = await GLSDK.Meta.GetAccessibilityData()
        self.iradData = data
        
        let dataRepresentation = data.jsonEncode() ?? Data()
        UserDefaults.standard.set(dataRepresentation, forKey: "iradData")
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "lastCachedLradTime")
    }
}
