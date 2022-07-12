//
//  AudioManager.swift
//  Go London (iOS)
//
//  Created by Tom Knighton on 12/07/2022.
//

import Foundation
import AVFoundation

class AudioManager {
    
    var audioPlayer = AVAudioPlayer()
    
    static let shared = AudioManager()
    
    init () {
        try? AVAudioSession.sharedInstance().setCategory(.ambient)
    }
    
    func playAudio(fileName: String, loop: Bool = false) {
        let url = URL(fileReferenceLiteralResourceName: fileName)
        if let player = try? AVAudioPlayer(contentsOf: url) {
            audioPlayer = player
            audioPlayer.play()
            audioPlayer.numberOfLoops = loop ? -1 : 0
        }
    }
    
    func stop() {
        self.audioPlayer.stop()
    }
}
