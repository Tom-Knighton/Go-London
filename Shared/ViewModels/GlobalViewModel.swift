//
//  GlobalViewModel.swift
//  Go London
//
//  Created by Tom Knighton on 04/06/2022.
//

import Foundation
import GoLondonSDK

@MainActor
public class GlobalViewModel: ObservableObject {
    
    @Published var iradData: [StopPointAccessibility]
    
    init() {
        if let data = UserDefaults.standard.data(forKey: "iradData"),
           let decompiled = try? JSONDecoder().decode([StopPointAccessibility].self, from: data) {
            self.iradData = decompiled
        } else {
            self.iradData = []
            Task {
                await getIradData()
            }
        }
    }
    
    private func getIradData() async {
        let data = await GLSDK.Meta.GetAccessibilityData()
        self.iradData = data
        
        let dataRepresentation = data.jsonEncode() ?? Data()
        UserDefaults.standard.set(dataRepresentation, forKey: "iradData")
    }
}
