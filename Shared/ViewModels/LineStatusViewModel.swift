//
//  LineStatusViewModel.swift
//  Go London
//
//  Created by Tom Knighton on 19/05/2022.
//

import Foundation
import GoLondonSDK

struct DogGif: WeightedElement {
    let dogName: String
    let dogGifName: String
    var weighting: Int
    var isFrog: Bool = false
    
    init(dogName: String, dogGifName: String, weighting: Int, isFrog: Bool = false) {
        self.dogName = dogName
        self.dogGifName = dogGifName
        self.weighting = weighting
        self.isFrog = isFrog
    }
}

@MainActor
final class LineStatusViewModel: ObservableObject {
    
    @Published var line: Line?
    @Published var dogGif: DogGif?
    
    func setup(for line: Line) {
        self.line = line
        self.chooseDogGif()
    }
    
    deinit {
        print("****DEINIT Status")
    }
    
    func chooseDogGif() {
        let dogGifs: [DogGif] = [
            DogGif(dogName: "Prissy Peter", dogGifName: "Dog_Peter", weighting: 100),
            DogGif(dogName: "Funky Franchesca", dogGifName: "Dog_Franchesca", weighting: 100),
            DogGif(dogName: "Fun Frankie", dogGifName: "Dog_Frankie", weighting: 100),
            DogGif(dogName: "Grumpy Gromit", dogGifName: "Dog_Gromit", weighting: 100),
            DogGif(dogName: "Posturing Polly", dogGifName: "Dog_Polly", weighting: 100),
            DogGif(dogName: "Rabid Rambo", dogGifName: "Dog_Rambo", weighting: 100),
            DogGif(dogName: "Troublesome Tom", dogGifName: "Dog_Tom", weighting: 100),
            DogGif(dogName: "Timid Tutu", dogGifName: "Dog_Tutu", weighting: 100),
            DogGif(dogName: "Silly Stephanie", dogGifName: "Dog_Wally", weighting: 100),
            DogGif(dogName: "Farting Fabio", dogGifName: "Dog_Fabio", weighting: 100),
            DogGif(dogName: "Rare Raymond the Frog", dogGifName: "Frog_Raymond", weighting: 70, isFrog: true)
        ]
        
        self.dogGif = dogGifs.weightedRandomElement() ?? dogGifs[0]
    }
    
    func playDogSound() {
        if self.dogGif?.isFrog == true {
            AudioManager.shared.playAudio(fileName: "frogNoise.mp3")
            return
        }
        
        let dogBarks: [String] = ["dogBark1.mp3", "dogBark2.mp3", "dogBark3.mp3", "dogBark4.mp3"]
        AudioManager.shared.playAudio(fileName: dogBarks.randomElement() ?? "dogBark1.mp3")
    }
}
