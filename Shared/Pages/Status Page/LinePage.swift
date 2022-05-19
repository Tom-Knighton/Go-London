//
//  LinePage.swift
//  Go London
//
//  Created by Tom Knighton on 19/05/2022.
//

import Foundation
import SwiftUI
import GoLondonSDK

struct LinePage: View {
    
    @ObservedObject var viewModel: LineStatusViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        let status = self.viewModel.line.currentStatus
        ScrollView {
            VStack(spacing: 0) {
                LineStatusCard {
                    VStack {
                        Text("\(self.viewModel.line.name ?? "") is reporting:")
                            .bold()
                            .font(.title2)
                        Text(status?.statusSeverityDescription ?? "")
                            .foregroundColor(.green) // TODO: replace
                            .bold()
                            .font(.title2)
                    }
                }
                
                if let reason = status?.reason {
                    LineStatusCard {
                        Text(reason)
                    }
                }
                
                if let disruption = status?.disruption,
                   let routes = disruption.affectedRoutes,
                   !routes.isEmpty {
                    self.affectedRoutes(for: disruption)
                }
                
                if status?.statusSeverity == 10 {
                    self.doggyView()
                }
                
                Spacer().frame(height: 16)
            }
        }
        .background(Color.layer1)
        .navigationTitle(self.viewModel.line.name ?? "")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                self.backButton()
            }
        }
    }
    
    //MARK: - View Builders
    
    /// A view showing an animated dog, when tapped produces a bark sound
    @ViewBuilder
    func doggyView() -> some View {
        VStack {
            if let dog = self.viewModel.dogGif {
                LottieView(name: dog.dogGifName, loopMode: .loop)
                    .frame(width: 250, height: 250)
                    .onTapGesture {
                        //                    SoundService.shared.playSound(soundfile: "dogbark.wav")
                    }
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
    
    /// A custom back button since default does not seem to work?
    @ViewBuilder
    func backButton() -> some View {
        Button(action: { self.presentationMode.wrappedValue.dismiss() }) {
            Text(Image(systemName: "chevron.backward")) + Text("Go back")
        }
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

extension UINavigationController: UIGestureRecognizerDelegate {
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}


struct NavigationLazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}
