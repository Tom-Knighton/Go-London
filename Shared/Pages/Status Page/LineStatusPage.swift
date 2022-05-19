//
//  LineStatusPage.swift
//  Go London
//
//  Created by Tom Knighton on 30/04/2022.
//

import Foundation
import SwiftUI

struct LineStatusPage: View {
    
    @StateObject private var viewModel: LineOverviewViewModel = LineOverviewViewModel()
    
    var body: some View {
        ScrollView {
            if viewModel.isLoading {
                VStack {
                    Spacer()
                    LottieView(name: "Dog_PurpleWalking", loopMode: .loop)
                        .frame(width: 200, height: 200, alignment: .center)
                    Text("Loading...")
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .center)
                    Spacer()
                }
            } else {
                LazyVStack {
                    ForEach(viewModel.lines, id: \.id) { line in
                        LineOverviewRow(line: line)
                    }
                }
            }
        }
        .onAppear {
            Task {
                await self.viewModel.fetchLines()
            }
        }
    }
}
