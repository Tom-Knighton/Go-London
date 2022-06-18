//
//  LineStatusPage.swift
//  Go London
//
//  Created by Tom Knighton on 30/04/2022.
//

import Foundation
import SwiftUI
import GoLondonSDK

struct AllLinesStatusPage: View {
    
    @StateObject private var viewModel: LineOverviewViewModel = LineOverviewViewModel()
    
    @State var hasInit: Bool = false
    @State private var selectedLine: Line?
    
    var body: some View {
        ScrollView {
            VStack {
                Spacer()
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
                    self.overviewTooltip()
                    LazyVStack {
                        ForEach(viewModel.lines, id: \.id) { line in
                            NavigationLink(value: line) {
                                LineOverviewRow(line: line)
                            }
                        }
                    }
                }
                Spacer()
                Spacer().frame(height: 16)
            }
            .padding(.horizontal, 16)
        }
        .navigationDestination(for: Line.self, destination: { line in
            LinePage(line: line)
        })
        .navigationTitle("TfL Status:")
        .background(Color.layer1.edgesIgnoringSafeArea(.all))
        .onAppear {
            Task {
                if !hasInit {
                    await self.viewModel.fetchLines()
                    self.hasInit = true
                }
            }
        }
    }
    
    //MARK: - View Builders
    
    @ViewBuilder
    func overviewTooltip() -> some View {
        let overview = self.viewModel.overviewString
        Text(overview == .unk ? "" : overview.rawValue)
            .foregroundColor(self.viewModel.overviewString.textColour)
            .bold()
            .font(.title3)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
