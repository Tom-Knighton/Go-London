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
    
    var body: some View {
        ScrollView {
            LazyVStack {
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
        }
        .background(Color("Section"))
        .task {
            self.tubeLines = await LineService.getTrainStatus() ?? []
        }
        .navigationTitle("Tube Status:")
    }
}
