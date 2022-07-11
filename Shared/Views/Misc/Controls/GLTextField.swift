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
    @Binding private var prompt: String
    private var promptPrefix: String?

    private var isFocused: FocusState<Bool>.Binding
    
    init(text: Binding<String>, prompt: Binding<String>? = nil, promptPrefix: String? = nil, leftImage: String? = nil, isSecure: Bool = false, allowedCharacters: String = "", maxCharacters: Int = -1, isFocused: FocusState<Bool>.Binding) {
        
        self._text = text
        self.leftImageName = leftImage
        self.hasLeftImage = true
        self.isSecure = isSecure
        self.characterSet = allowedCharacters
        self.maxCharacters = maxCharacters
        self.isFocused = isFocused
        self._prompt = prompt ?? .constant("")
        self.promptPrefix = promptPrefix
    }
    
    init(text: Binding<String>, prompt: Binding<String>? = nil, promptPrefix: String? = nil, leftSystemImage: String? = nil, isSecure: Bool = false, allowedCharacters: String = "", maxCharacters: Int = -1, isFocused: FocusState<Bool>.Binding) {
        self._text = text
        self._leftSystemImageName = State(initialValue: leftSystemImage)
        self.hasLeftImage = true
        self.isSecure = isSecure
        self.characterSet = allowedCharacters
        self.maxCharacters = maxCharacters
        self.isFocused = isFocused
        self._prompt = prompt ?? .constant("")
        self.promptPrefix = promptPrefix
    }
    
    var body: some View {
        HStack {
            if hasLeftImage {
                imageToDisplay
                    .foregroundColor(.primary)
            }
            
            textFieldToDisplay
                .foregroundColor(.primary)
                .focused(isFocused)
        }
        .foregroundColor(.white)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.primary, lineWidth: 2)
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
        ZStack {
            if self.text.isEmpty {
                HStack(spacing: 0) {
                    Text(self.promptPrefix ?? "")
                        .foregroundColor(.gray)
                    Text(self.prompt)
                        .foregroundColor(.gray)
                        .contentTransition(.interpolate)
                    Spacer()
                }
               
               
            }
            if isSecure == true {
                SecureField("", text: $text)
            } else {
                TextField("", text: $text)
                    .background(.clear)
            }
        }
    }
    
    func filtered(range: String, text: String) -> Bool {
        let charset = NSCharacterSet(charactersIn: range).inverted
        let filtered = text.components(separatedBy: charset).joined(separator: "")
        return text == filtered
    }
}
