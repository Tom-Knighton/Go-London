//
//  LinePage.swift
//  Go London
//
//  Created by Tom Knighton on 19/05/2022.
//

import Foundation
import SwiftUI
import GoLondonSDK
import Introspect

struct LinePage: View {
    
    
    @State public var line: Line
    
    @Environment(\.tabBarHeight) private var tabBarHeight: CGFloat
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject private var tabManager: GLTabBarViewModel
    @Namespace private var mapNamespace
    
    @State private var isFullScreenMapShowing: Bool = false
    
    @StateObject private var viewModel: LineStatusViewModel = LineStatusViewModel()
    @StateObject private var lineModel: LineMapViewModel = LineMapViewModel()

    
    var body: some View {
        let status = self.viewModel.line?.currentStatus ?? .none
        ZStack {
            ScrollView {
                VStack(spacing: 0) {
                    LineStatusCard {
                        VStack {
                            Text("\(self.viewModel.line?.name ?? "") is reporting:")
                                .bold()
                                .font(.title2)
                            Text(status?.statusSeverityDescription ?? "")
                                .foregroundColor(self.statusColour(for: status))
                                .bold()
                                .font(.title2)
                        }
                    }

                    if let reason = status?.reason {
                        LineStatusCard {
                            Text(reason)
                        }
                    }

                    if status?.statusSeverity == 10 {
                        self.doggyView()
                    }

                    if !self.isFullScreenMapShowing {
                        ZStack {
                            LineMapView(viewModel: self.lineModel)
                                .allowsHitTesting(false)
                                .matchedGeometryEffect(id: "map", in: mapNamespace)
                            
                            VStack {
                                Spacer().frame(height: 8)
                                HStack {
                                    Spacer()
                                    
                                    Button(action: { self.toggleMapOverlay(to: true) }) {
                                        Image(systemName: "arrow.down.forward.and.arrow.up.backward")
                                    }
                                    .buttonStyle(MapButtonStyle(backgroundColor: .black))
                                    .matchedGeometryEffect(id: "mapExp", in: mapNamespace)
                                    .opacity(0.6)
                                    
                                    Spacer().frame(width: 8)
                                }
                                Spacer()
                            }
                        }
                        .cornerRadius(15)
                        .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 200)
                        .padding(.horizontal)
                        .padding(.top)
                        .shadow(radius: 3)
                        .onTapGesture {
                            self.toggleMapOverlay(to: true)
                        }
                    }
                   
                    
                    if let disruption = status?.disruption,
                       let routes = disruption.affectedRoutes,
                       !routes.isEmpty {
                        self.affectedRoutes(for: disruption)
                    }
                    
                    Spacer().frame(height: self.tabBarHeight)
                }
            }
            
            if self.isFullScreenMapShowing {
                self.fullscreenMapView()
            }
        }
        .onAppear {
            self.viewModel.setup(for: self.line)
            self.lineModel.setup(for: [self.line.id ?? ""])
        }
        .background(Color.layer1)
        .navigationTitle(self.viewModel.line?.name ?? "")
        .introspectNavigationController { navController in
            navController.isNavigationBarHidden = self.isFullScreenMapShowing
        }
    }
    
    
    func toggleMapOverlay(to val: Bool) {
        
        self.tabManager.setTabBarVisibility(to: !val)
        withAnimation {
            self.isFullScreenMapShowing = val
        }
    }
    
    //MARK: - View Builders
    
    func statusColour(for status: LineStatus?) -> Color {
        switch status?.statusSeverity {
        case 10, 18:
            return .green
        case 3, 5, 7, 9, 13, 14, 15, 17, 20, 0:
            return .yellow
        default:
            return .red
        }
    }
    
    
    @ViewBuilder
    /// A view that should overlay the current screen containing the line map + options
    func fullscreenMapView() -> some View {
        ZStack {
            LineMapView(viewModel: self.lineModel)
                .edgesIgnoringSafeArea(.all)
                .matchedGeometryEffect(id: "map", in: mapNamespace)
                .onAppear {
                    self.lineModel.cachedLineRoutes = []
                }
                .onDisappear {
                    self.lineModel.cachedLineRoutes = []
                }
            
            HStack {
                Spacer()
                VStack(spacing: 16) {
                    Spacer().frame(height: 16)
                    
                    Button(action: { self.toggleMapOverlay(to: false) }) {
                        Image(systemName: "arrow.down.forward.and.arrow.up.backward")
                    }
                    .buttonStyle(MapButtonStyle(backgroundColor: .black))
                    .matchedGeometryEffect(id: "mapExp", in: mapNamespace)
                    
                    Button(action: { withAnimation { self.lineModel.filterAccessibility.toggle() } }) {
                        ZStack {
                            Image(systemName: "figure.roll")
                                .shadow(radius: 3)
                                .foregroundColor(self.lineModel.filterAccessibility ? Color.white : Color.primary)
                        }
                    }
                    .buttonStyle(MapButtonStyle(backgroundColor: self.lineModel.filterAccessibility ? Color.blue : Color.layer1))
                    
                    Spacer().frame(width: 16)
                }
                Spacer().frame(width: 16)
            }
        }
    }
    
    /// A view showing an animated dog, when tapped produces a bark sound
    @ViewBuilder
    func doggyView() -> some View {
        VStack {
            if let dog = self.viewModel.dogGif {
                LottieView(name: dog.dogGifName, loopMode: .loop)
                    .frame(width: 250, height: 250)
                    .onTapGesture {
                        self.viewModel.playDogSound()
                    }
                    .id(dog.dogName)
                Group {
                    Text("Yay! This line has good service and ") +
                    Text(dog.dogName)
                        .bold() +
                    Text(" is happy :) Turn up your volume and tap them for a \(dog.isFrog ? "hippity-hoppity" : "barking-mad") surprise!")
                }
                .font(.title3)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal)
            }
        }
    }
    
    /// An expandable section of affected routes from a disruption
    @ViewBuilder
    func affectedRoutes(for disruption: Disruption) -> some View {
        
        DisclosureGroup {
            LazyVStack {
                Spacer().frame(height: 4)
                ForEach(disruption.affectedRoutes ?? [], id: \.id) { route in
                    LineStatusCard(textAlignment: .leading, verticalPadding: 4) {
                        VStack(alignment: .leading) {
                            Text(route.originationName ?? "")
                                .bold()
                                .font(.title3)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("towards")
                                .font(.body)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(route.destinationName ?? "")
                                .bold()
                                .font(.title3)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            }
            .padding(.trailing, -9)
            
        } label: {
            LineStatusCard {
                Text("Affected Routes:")
                    .bold()
                    .font(.title)
                    .foregroundColor(.primary)
            }
        }
        .padding(.trailing, 16)
    }
}


struct LineStatusCard<Content>: View where Content: View {
    var textAlignment: TextAlignment = .center
    var verticalPadding: CGFloat = 16
    var content: () -> Content
    
    var body: some View {
        VStack(spacing: 0) {
            content()
        }
        .multilineTextAlignment(textAlignment)
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .center)
        .background(Color.layer2.cornerRadius(15).shadow(radius: 5))
        .padding(.vertical, verticalPadding)
        .padding(.horizontal, 16)
    }
}
