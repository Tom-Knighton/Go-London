//
//  HomeMapFilterView.swift
//  Go London
//
//  Created by Tom Knighton on 06/06/2022.
//

import Foundation
import SwiftUI
import GoLondonSDK

struct HomeMapFilterView: View {
    
    @ObservedObject var viewModel: HomeViewModel
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var toggleVals: HomeViewModel.LineModeFilters = HomeViewModel.LineModeFilters(HomeViewModel.defaultFilters.filters.compactMap { $0.lineMode })
    
    @State private var isShowingAlert: Bool = false
    @State private var alertDetails: AlertDetails?
    
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
                        ForEach(self.toggleVals.filters, id: \.lineMode) { filter in
                            Button(action: { self.toggle(filter.lineMode) } ) {
                                VStack {
                                    Spacer().frame(height: 8)
                                    Text(filter.lineMode.friendlyName)
                                        .bold()
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(self.toggleVals.isToggled(filter.lineMode) ? .white : .primary)

                                    Spacer()
                                    filter.lineMode.image
                                        .frame(width: 50, height: 50)
                                    
                                    
                                    Spacer().frame(height: 24)
                                }
                            }
                            .buttonStyle(MapFilterButton(height: height, backgroundColour: self.toggleVals.isToggled(filter.lineMode) ? Color.blue : Color.layer2))
                        }
                    }
                }
                
                Spacer()
                
                Button(action: { self.updateFilters() } ) {
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
            self.toggleVals.filters = self.viewModel.filters.filters.deepCopy()
        }
        .alert(self.alertDetails?.title ?? "", isPresented: $isShowingAlert, presenting: self.alertDetails, actions: { details in
            ForEach(details.buttons ?? [], id: \.text) { button in
                Button(button.text, role: button.role, action: button.action)
            }
        }, message: { detail in
            Text(detail.message ?? "")
        })
    }
    
    
    
    /// Toggles a toggleVal value, with an animation and haptic feedback
    /// - Parameter lineMode: The lineMode to toggle
    func toggle(_ lineMode: LineMode) {
        withAnimation(.easeInOut) {
            self.toggleVals.toggleFilter(lineMode)
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }

    /// Evaluates whether to update the filters or not, and saves/dismisses view if necessary
    func updateFilters() {
        
        if self.toggleVals.getAllToggled().count == 0 {
            self.alertDetails = AlertDetails(title: "Error", message: "Please select at least one type of stop point to show on the map", buttons: [AlertButtonType(text: "Ok", action: {})])
            self.isShowingAlert = true
            
            return
        }
        
        self.viewModel.filters = self.toggleVals
        
        self.dismiss()
    }
}
