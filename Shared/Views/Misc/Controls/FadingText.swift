//
//  FadingText.swift
//  Go London
//
//  Created by Tom Knighton on 02/04/2022.
//

import Foundation
import SwiftUI
import Combine

struct FadingTextView: View {
    
    @Binding var source: String
    var prefix: String
    var transitionTime: Double
    
    @State private var currentText: String? = nil
    @State private var visible: Bool = false
    private var publisher: AnyPublisher<[String.Element], Never> {
        source
            .publisher
            .collect()
            .eraseToAnyPublisher()
    }
    
    init(text: Binding<String>, prefix: String? = nil, transitionTime: Double = 1) {
        self._source = text
        self.transitionTime = transitionTime / 3
        self.prefix = prefix ?? ""
    }
    
    private func update(_: Any) {
        guard currentText != nil else {
            self.currentText = source
            DispatchQueue.main.asyncAfter(deadline: .now() + transitionTime) {
                self.visible = true
            }
            return
        }
        
        guard source != currentText else { return }
        
        self.visible = false
        DispatchQueue.main.asyncAfter(deadline: .now() + transitionTime) {
            self.currentText = source
            DispatchQueue.main.asyncAfter(deadline: .now() + transitionTime) {
                self.visible = true
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Text(self.prefix)
            Text(self.currentText ?? "")
                .opacity(self.visible ? 1 : 0)
                .animation(.linear(duration: self.transitionTime), value: self.visible)
                .onReceive(publisher, perform: self.update(_:))
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}
