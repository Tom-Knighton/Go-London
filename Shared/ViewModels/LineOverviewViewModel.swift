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
    @Published var overviewString: LineModeGroupStatusType = .unk
    
    func fetchLines() async {
        Task {
            self.isLoading = true
            let lines = await GLSDK.Lines.Lines(for: self.getLineModesToSearch(), includeDetails: true)
            self.lines = lines.sorted(by: { a, b in
                if a.currentStatus?.statusSeverity != b.currentStatus?.statusSeverity {
                    return a.currentStatus?.statusSeverity != 10
                } else {
                    return (a.name ?? "") < (b.name ?? "")
                }
            })
            
            await self.fetchOverview()
            
            self.isLoading = false
        }
    }
    
    func fetchOverview() async {
        Task {
            self.overviewString = await GLSDK.Lines.Status(for: self.getLineModesToSearch())
        }
    }
    
    private func getLineModesToSearch() -> [LineMode] {
        let modes: [LineMode] = [.tube, .overground, .dlr, .elizabethLine]
        return modes
    }
}
