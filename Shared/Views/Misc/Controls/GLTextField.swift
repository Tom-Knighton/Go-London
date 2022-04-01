//
//  GLTextField.swift
//  Go London
//
//  Created by Tom Knighton on 01/04/2022.
//

import Foundation
import SwiftUI
import Combine

struct GLTextField: View {
    
    @State private var leftSystemImageName: String?
    @State private var leftImageName: String?
    @State private var leftImageIsSystem: Bool?
    @State private var hasLeftImage: Bool
    
    @State private var isSecure: Bool
    @State private var maxCharacters: Int?
    @State private var characterSet: String?
    
    @Binding var text: String
    @State private var prompt: String
    
    private var isFocused: FocusState<Bool>.Binding
    
    init(text: Binding<String>, prompt: String? = "", leftImage: String? = nil, isSecure: Bool = false, allowedCharacters: String = "", maxCharacters: Int = -1, isFocused: FocusState<Bool>.Binding) {
        self._text = text
        self.leftImageName = leftImage
        self.hasLeftImage = true
        self.isSecure = isSecure
        self.characterSet = allowedCharacters
        self.maxCharacters = maxCharacters
        self.isFocused = isFocused
        self.prompt = prompt ?? ""
    }
    
    init(text: Binding<String>, prompt: String? = "", leftSystemImage: String? = nil, isSecure: Bool = false, allowedCharacters: String = "", maxCharacters: Int = -1, isFocused: FocusState<Bool>.Binding) {
        self._text = text
        self._leftSystemImageName = State(initialValue: leftSystemImage)
        self.hasLeftImage = true
        self.isSecure = isSecure
        self.characterSet = allowedCharacters
        self.maxCharacters = maxCharacters
        self.isFocused = isFocused
        self.prompt = prompt ?? ""
    }
    
    var body: some View {
        HStack {
            if hasLeftImage {
                imageToDisplay
            }
            
            textFieldToDisplay
                .foregroundColor(.white)
                .focused(isFocused)
        }
        .foregroundColor(.white)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(Color.layer1)
        )
    }
    
    @ViewBuilder
    var imageToDisplay: some View {
        if let sysName = leftSystemImageName {
            Image(systemName: sysName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 25, height: 25)
        } else {
            Image(leftImageName ?? "")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 25, height: 25)
        }
    }
    
    @ViewBuilder
    var textFieldToDisplay: some View {
        if isSecure == true {
            SecureField(self.prompt, text: $text)
        } else {
            TextField(self.prompt, text: $text)
        }
    }
    
    func filtered(range: String, text: String) -> Bool {
        let charset = NSCharacterSet(charactersIn: range).inverted
        let filtered = text.components(separatedBy: charset).joined(separator: "")
        return text == filtered
    }
}
