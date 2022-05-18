//
//  View+GoLondon.swift
//  Go London
//
//  Created by Tom Knighton on 01/04/2022.
//

import Foundation
import SwiftUI
import Combine

extension View {
    
    /// Hides the keyboard when an area outside a text field is tapped
    func hideKeyboardWhenTappedAround() -> some View {
        return self.onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
    
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
    
}


struct RoundedCorner: Shape {
    
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

class KeyboardResponder: ObservableObject {
    let willset = PassthroughSubject<CGFloat, Never>()
    private var _center: NotificationCenter
    @Published var currentHeight: CGFloat = 0
    var keyboardDuration: TimeInterval = 0
    
    init(center: NotificationCenter = .default) {
        _center = center
        _center.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        _center.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        _center.removeObserver(self)
    }
    
    @objc func keyBoardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            guard let duration: TimeInterval = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
            keyboardDuration = duration
            
            withAnimation(.interpolatingSpring(stiffness: 100, damping: 15)) {
                self.currentHeight = keyboardSize.height
            }

        }
    }
    
    @objc func keyBoardWillHide(notification: Notification) {
        
        withAnimation(.interpolatingSpring(stiffness: 150, damping: 15)) {
            currentHeight = 0
        }
    }
}
