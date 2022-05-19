//
//  LineStatusViewModel.swift
//  Go London
//
//  Created by Tom Knighton on 19/05/2022.
//

import Foundation
import GoLondonSDK

struct DogGif {
    let dogName: String
    let dogGifName: String
    let rarity: Int
}

@MainActor
final class LineStatusViewModel: ObservableObject {
    
    @Published var line: Line
    @Published var dogGif: DogGif?
    
    init(for line: Line) {
        self.line = line
        self.chooseDogGif()
    }
    
    func chooseDogGif() {
        let dogGifs: [DogGif] = [
            DogGif(dogName: "Prissy Peter", dogGifName: "Dog_Peter", rarity: 1),
            DogGif(dogName: "Funky Franchesca", dogGifName: "Dog_Franchesca", rarity: 1),
            DogGif(dogName: "Fun Frankie", dogGifName: "Dog_Frankie", rarity: 1),
            DogGif(dogName: "Grumpy Gromit", dogGifName: "Dog_Gromit", rarity: 1),
            DogGif(dogName: "Licky Louie", dogGifName: "Dog_Louie", rarity: 1),
            DogGif(dogName: "Posturing Polly", dogGifName: "Dog_Polly", rarity: 1),
            DogGif(dogName: "Rabid Rambo", dogGifName: "Dog_Rambo", rarity: 1),
            DogGif(dogName: "Troublesome Tom", dogGifName: "Dog_Tom", rarity: 1),
            DogGif(dogName: "Timid Tutu", dogGifName: "Dog_Tutu", rarity: 1),
            DogGif(dogName: "Silly Stephanie", dogGifName: "Dog_Wally", rarity: 1),
            DogGif(dogName: "Farting Fabio", dogGifName: "Dog_Fabio", rarity: 1),
        ]
        
        self.dogGif = dogGifs.randomElement() ?? dogGifs[0]
    }
}
