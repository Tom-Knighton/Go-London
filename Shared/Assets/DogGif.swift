//
//  DogGif.swift
//  GaryTube
//
//  Created by Tom Knighton on 04/10/2021.
//

import Foundation

struct DogGif {
    let dogName: String
    let dogGifName: String
    let dogPronoun: String
    let rarity: Int
}

struct DogGifController {
    private static let dogGifs: [DogGif] =
    [
        DogGif(dogName: "Prissy Peter", dogGifName: "Dog_Peter", dogPronoun: "him", rarity: 1),
        DogGif(dogName: "Funky Franchesca", dogGifName: "Dog_Franchesca", dogPronoun: "her", rarity: 1),
        DogGif(dogName: "Fun Frankie", dogGifName: "Dog_Frankie", dogPronoun: "him", rarity: 1),
        DogGif(dogName: "Grumpy Gromit", dogGifName: "Dog_Gromit", dogPronoun: "him", rarity: 1),
        DogGif(dogName: "Licky Louie", dogGifName: "Dog_Louie", dogPronoun: "him", rarity: 1),
        DogGif(dogName: "Posturing Polly", dogGifName: "Dog_Polly", dogPronoun: "her", rarity: 1),
        DogGif(dogName: "Rabid Rambo", dogGifName: "Dog_Rambo", dogPronoun: "him", rarity: 1),
        DogGif(dogName: "Troublesome Tom", dogGifName: "Dog_Tom", dogPronoun: "him", rarity: 1),
        DogGif(dogName: "Timid Tutu", dogGifName: "Dog_Tutu", dogPronoun: "her", rarity: 1),
        DogGif(dogName: "Silly Stephanie", dogGifName: "Dog_Wally", dogPronoun: "her", rarity: 1),
        DogGif(dogName: "Farting Fabio", dogGifName: "Dog_Fabio", dogPronoun: "him", rarity: 1),
    ]
    
    static func getRandomDogGif() -> DogGif {
        let dog = dogGifs.randomElement() ?? dogGifs[0]
        return dog
    }
}
