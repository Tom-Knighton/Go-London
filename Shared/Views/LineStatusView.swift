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
    
    var body: some View {
        VStack(spacing: 0) {
            LineStatusViewHeader(lineName: line.name ?? "" , colour: line.tubeColour)
            ScrollView {
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
            }
        }
        .background(Color("Section"))
        .navigationBarTitle(Text(line.name ?? ""))
        .navigationBarHidden(true)
        .task {
            self.line = await LineService.getDetailedLineInformation(lineId: line.id ?? "") ?? self.line
        }
    }
    
    struct LineStatusCard<Content>: View where Content: View {
        var content: () -> Content
        
        var body: some View {
            VStack(spacing: 0) {
                content()
            }
            .multilineTextAlignment(.center)
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .center)
            .background(Color("Section2").cornerRadius(15).shadow(radius: 5))
            .padding(16)
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
        .background(colour.overlay(.ultraThinMaterial).cornerRadius(15).edgesIgnoringSafeArea(.top).shadow(radius: 3))
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
