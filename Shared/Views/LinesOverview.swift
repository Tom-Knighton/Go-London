//
//  LinesOverview.swift
//  GaryTube
//
//  Created by Tom Knighton on 01/10/2021.
//

import Foundation
import SwiftUI

struct LinesOverviewView: View {
    
    @State var tubeLines: [Line] = []
    @Environment(\.safeAreaInsets) var edges

    var body: some View {
        ScrollView {
            LazyVStack {
                statusOverviewTooltip()
                ForEach(self.tubeLines, id: \.id) { line in
                    NavigationLink(destination: NavigationLazyView(LineStatusView(line: line))) {
                        ZStack {
                            line.tubeColour.cornerRadius(15)
                            VStack {
                                Text(line.name ?? "")
                                    .bold()
                                    .font(.title3)
                                    .frame(maxWidth: .infinity)
                                    .padding(.horizontal, 8)
                                HStack {
                                    Text(Image(systemName: "exclamationmark.triangle.fill"))
                                        .foregroundColor(line.currentStatus?.severityColour)
                                        .isHidden(line.currentStatus?.statusSeverity == 10, remove: true)
                                    Text("Status - \(line.currentStatus?.statusSeverityDescription ?? "")")
                                        .frame(maxWidth: .infinity)
                                        .padding(.horizontal, 8)
                                    Text(Image(systemName: "exclamationmark.triangle.fill"))
                                        .foregroundColor(line.currentStatus?.severityColour)
                                        .isHidden(line.currentStatus?.statusSeverity == 10, remove: true)
                                }
                            }
                            .padding(.all, 16)
                            .background(Material.thinMaterial)
                            .cornerRadius(15, antialiased: true)
                            .shadow(radius: 3)
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, edges.bottom + (edges.bottom == 0 ? 80 : 40))
        }
        .background(Color("Section"))
        .task {
            self.tubeLines = await LineService.getTrainStatus() ?? []
        }
        .navigationTitle("Tube Status:")
    }
    
    @ViewBuilder
    func statusOverviewTooltip() -> some View {
        let totalLines = self.tubeLines.count == 0 ? 10 : self.tubeLines.count
        let totalGood = self.tubeLines.filter({ $0.currentStatus?.statusSeverity == 10 }).count
        let percentageGood: Int = Int((Double(totalGood) / Double(totalLines)) * 100)
        
        Group {
            if percentageGood == 100 {
                Text("All lines are experiencing Good Service!")
                    .bold()
                    .font(.title3)
                    .foregroundColor(.green)
            } else if percentageGood < 100 && percentageGood >= 40 {
                Text("Some lines are experiencing problems")
                    .bold()
                    .font(.title3)
                    .foregroundColor(.yellow)
            } else if percentageGood < 40 && percentageGood > 0 {
                Text("Many lines are experiencing problems")
                    .bold()
                    .font(.title3)
                    .foregroundColor(.orange)
            } else {
                Text("All lines are experiencing problems")
                    .bold()
                    .font(.title3)
                    .foregroundColor(.red)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .isHidden(self.tubeLines.count == 0, remove: true)
        
    }
}
