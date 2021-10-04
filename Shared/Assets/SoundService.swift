//
//  SoundService.swift
//  GaryTube
//
//  Created by Tom Knighton on 04/10/2021.
//

import AVFoundation

class SoundService {
    
    static let shared = SoundService()
    
    private var audioPlayer: AVAudioPlayer?
    
    func playSound(soundfile: String) {
        if let path = Bundle.main.path(forResource: soundfile, ofType: nil) {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                try AVAudioSession.sharedInstance().setCategory(.playback)
                audioPlayer?.volume = 0.3
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
            } catch {
                print("Error playing sound \(error.localizedDescription)")
            }
        } else {
            print("Error playing sound: No path")
        }
    }
}
