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
