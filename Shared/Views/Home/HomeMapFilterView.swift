//
//  HomeMapFilterView.swift
//  Go London
//
//  Created by Tom Knighton on 06/06/2022.
//

import Foundation
import SwiftUI

struct HomeMapFilterView: View {
    
    @ObservedObject var viewModel: HomeViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State var toggleVals: [HomeMapFilterToggle] = []
    
    
    var body: some View {
        let threeGridColumn = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
        
        NavigationView {
            VStack {
                Text("Enable/disable certain types of stops when searching on the map")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                
                
                GeometryReader { geo in
                    
                    let height: CGFloat = (geo.size.height - (16 * CGFloat(3 - 1))) / CGFloat(3)
                    
                    LazyVGrid(columns: threeGridColumn, spacing: 16) {
                        ForEach(self.toggleVals, id: \.filter) { filter in
                            VStack {
                                Spacer().frame(height: 8)
                                Text(filter.filter.lineMode.friendlyName)
                                    .bold()
                                    .multilineTextAlignment(.center)

                                Spacer()
                                filter.filter.lineMode.image
                                    .frame(width: 50, height: 50)
                                
                                
                                Spacer().frame(height: 24)
                            }
                            .frame(maxWidth: .infinity, minHeight: height, maxHeight: .infinity)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 2)
                            .background(Color.layer2)
                            .cornerRadius(15)
                            .shadow(radius: 3)
                        }
                        
                    }
                }
                
                Spacer()
                
                Button(action: {} ) {
                    Text("Save Filters")
                        .padding()
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
               
                Spacer().frame(height: 16)
            }
            .padding(.horizontal, 16)
            .navigationTitle("Filters:")
        }
        .edgesIgnoringSafeArea(.all)
        .navigationTitle("Filters:")
        .background(Color.layer1.edgesIgnoringSafeArea(.all))
        .edgesIgnoringSafeArea(.all)
        .padding(.vertical, 12)
        .interactiveDismissDisabled()
        .onAppear {
            self.toggleVals = self.viewModel.filters.makeTempStructs()
        }
    }
    
    func updateTest() {
        
        
        self.dismiss()
    }
}
