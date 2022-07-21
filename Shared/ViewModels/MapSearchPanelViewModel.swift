//
//  MapSearchPanelViewModel.swift
//  Go London
//
//  Created by Tom Knighton on 20/04/2022.
//

import Foundation
import GoLondonSDK

@MainActor
class MapSearchPanelViewModel: ObservableObject {
    
    @Published var searchText: String = ""
    @Published var searchResults: [Point] = []
    @Published var isLoading: Bool = false
    
    func makeSearch() async {
        self.isLoading = true
        Task { [weak self] in
            self?.searchResults = await GLSDK.Search.Search(for: searchText, filterBy: [], includePOI: true, includeAddresses: true)
            self?.isLoading = false
        }
    }
    
    deinit {
        print("****DEINIT: MapSearchPanel")
    }
}
