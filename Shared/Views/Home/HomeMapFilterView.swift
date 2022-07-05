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
    
    @ObservedObject var viewModel: MainMapViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State var toggleVals: [MainMapFilter] = []
    
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
                        ForEach(self.toggleVals, id: \.lineMode) { filter in
                            Button(action: { self.toggle(filter.lineMode) } ) {
                                VStack {
                                    Spacer().frame(height: 8)
                                    Text(filter.lineMode.friendlyName)
                                        .bold()
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(filter.toggled ? .white : .primary)

                                    Spacer()
                                    filter.lineMode.image
                                        .frame(width: 50, height: 50)
                                    
                                    
                                    Spacer().frame(height: 24)
                                }
                            }
                            .buttonStyle(MapFilterButton(height: height, backgroundColour: filter.toggled ? Color.blue : Color.layer2))
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
            self.toggleVals = GoLondon.homeFilterCache.deepCopy()
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
            if let index = self.toggleVals.firstIndex(where: { $0.lineMode == lineMode }) {
                self.toggleVals[index].toggled.toggle()
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
            }
        }
    }

    /// Evaluates whether to update the filters or not, and saves/dismisses view if necessary
    func updateFilters() {
        
        if self.toggleVals.filter({ $0.toggled }).count == 0 {
            self.alertDetails = AlertDetails(title: "Error", message: "Please select at least one type of stop point to show on the map", buttons: [AlertButtonType(text: "Ok", action: {})])
            self.isShowingAlert = true
            
            return
        }
        
        self.viewModel.filters = self.toggleVals
        GoLondon.homeFilterCache = self.toggleVals
        
        self.dismiss()
    }
}
