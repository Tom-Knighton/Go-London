//
//  LineOverviewRow.swift
//  Go London (iOS)
//
//  Created by Tom Knighton on 18/05/2022.
//

import Foundation
import SwiftUI
import GoLondonSDK

struct LineOverviewRow: View {
    
    @State var line: Line
    
    var body: some View {
        ZStack {
            LineMode.lineColour(for: line.id ?? "")
                .cornerRadius(15)
            
            VStack {
                Text(line.name ?? "")
                    .bold()
                    .font(.title3)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 8)
                
                self.statusText()
            }
            .padding(16)
            .cornerRadius(15, antialiased: true)
            .shadow(radius: 15)
        }
//        .foregroundColor(line.id == "northern" ? .white : .primary)
        .foregroundColor(.white)
    }
    
    
    //MARK: - View Builders
    
    /// Displays a brief `Text` view for the line
    @ViewBuilder
    func statusText() -> some View {
        if let status = self.line.currentStatus {
            let isGood = status.statusSeverity == 10
            
            HStack {
                if !isGood {
                    Text(Image(systemName: "exclamationmark.triangle.fill"))
                }
                Text("Status - \(status.statusSeverityDescription ?? "")")
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 8)
                if !isGood {
                    Text(Image(systemName: "exclamationmark.triangle.fill"))
                }
            }
        }
    }
}
