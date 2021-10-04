//
//  LineStatusView.swift
//  GaryTube
//
//  Created by Tom Knighton on 01/10/2021.
//

import Foundation
import SwiftUI
import Introspect

struct LineStatusView: View {
    
    @State var line: Line
    
    @State var dogGif: DogGif = DogGifController.getRandomDogGif()
    
    var body: some View {
        VStack(spacing: 0) {
            LineStatusViewHeader(lineName: line.name ?? "" , colour: line.tubeColour)
            ScrollView {
                VStack(spacing: 0) {
                    LineStatusCard {
                        HStack {
                            Spacer()
                            Text("\(line.name ?? "") is reporting: ")
                                .bold()
                                .font(.title2)
                            +
                            Text(line.currentStatus?.statusSeverityDescription ?? "")
                                .foregroundColor(line.currentStatus?.severityColour ?? .green)
                                .bold()
                                .font(.title2)
                            Spacer()
                        }
                    }
                    
                    LineStatusCard {
                        Text(line.currentStatus?.reason ?? "")
                    }
                    .isHidden(line.currentStatus?.reason == nil, remove: true)

                    if line.currentStatus?.disruption?.affectedRoutes != nil && line.currentStatus?.disruption?.affectedRoutes?.count != 0 {
                        affectedRoutesSection()
                    }
                    
                    if line.currentStatus?.statusSeverity == 10 {
                        dogView()
                    }
                }
            }
        }
        .background(Color("Section"))
        .navigationBarTitle(Text(line.name ?? ""))
        .navigationBarHidden(true)
        .task {
            self.line = await LineService.getDetailedLineInformation(lineId: line.id ?? "") ?? self.line
        }
    }
    
    @ViewBuilder
    func affectedRoutesSection() -> some View {
        LazyVStack(spacing: 0) {
            Text("Affected Routes:")
                .bold()
                .font(.title)
            ForEach(line.currentStatus?.disruption?.affectedRoutes ?? [], id: \.id) { route in
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
    }
    
    @ViewBuilder
    func dogView() -> some View {
        VStack {
            LottieView(name: self.dogGif.dogGifName, loopMode: .loop)
                .frame(width: 250, height: 250)
                .onTapGesture {
                    SoundService.shared.playSound(soundfile: "dogbark.wav")
                }
            Group {
                Text("Congratulations! This line has good service and ") +
                Text(self.dogGif.dogName)
                    .bold() +
                Text(" is happy :) Turn up your volume and tap \(self.dogGif.dogPronoun) for a barking-mad surprise!")
            }
            .font(.title3)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, alignment: .center)
            
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
            .background(Color("Section2").cornerRadius(15).shadow(radius: 5))
            .padding(.vertical, verticalPadding)
            .padding(.horizontal, 16)
        }
    }
}

fileprivate struct LineStatusViewHeader: View {
    
    var lineName: String
    var colour: Color
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Button(action: { dismiss() } ) {
                    Text(Image(systemName: "chevron.backward")) +
                    Text(" Back")
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            
            Spacer().frame(height: 16)
            Text(lineName)
                .bold()
                .font(.largeTitle)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
            Spacer().frame(height: 8)
        }
        .edgesIgnoringSafeArea(.top)
        .frame(maxWidth: .infinity, minHeight: 90, maxHeight: 90)
        .background(colour.overlay(.ultraThinMaterial).cornerRadius(15, corners: [.bottomLeft, .bottomRight]).edgesIgnoringSafeArea(.top).shadow(radius: 3))
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
