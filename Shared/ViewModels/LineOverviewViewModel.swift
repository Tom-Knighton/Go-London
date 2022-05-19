//
//  LineOverviewViewModel.swift
//  Go London (iOS)
//
//  Created by Tom Knighton on 18/05/2022.
//

import Foundation
import GoLondonSDK

@MainActor
final class LineOverviewViewModel: ObservableObject {
    
    @Published var lines: [Line] = []
    @Published var isLoading: Bool = false
    
    func fetchLines() async {
        Task {
            self.isLoading = true
            let lines = await GLSDK.Lines.Lines(for: self.getLineModesToSearch())
            self.lines = lines.sorted(by: { a, b in
                if a.currentStatus?.statusSeverity != b.currentStatus?.statusSeverity {
                    return a.currentStatus?.statusSeverity != 10
                } else {
                    return (a.name ?? "") < (b.name ?? "")
                }
            })
            self.isLoading = false
        }
    }
    
    private func getLineModesToSearch() -> [LineMode] {
        var modes: [LineMode] = [.tube, .overground, .dlr]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current
        if let elizabethLineDate = dateFormatter.date(from: "2022-05-24T07:00:00"),
            Date() > elizabethLineDate {
            modes.append(.elizabethLine)
        } else {
            modes.append(.tflrail)
        }
        
        return modes
    }
}