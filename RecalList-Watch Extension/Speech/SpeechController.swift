//
//  SpeechController.swift
//  RecalList
//
//  Created by Serge Nes on 10/8/18.
//  Copyright © 2018 Serge Nes. All rights reserved.
//

import AVFoundation
import WatchKit
import Foundation


enum Mode {
    case idle
    case playing
}

class SpeechController:NSObject, AVSpeechSynthesizerDelegate{
    let synth = AVSpeechSynthesizer()
    let sessionAudio = AVAudioSession.sharedInstance()
    var interfaceController: CardsViewContract
    
    var currentSide = CardSide.FRONT
    var mode = Mode.idle
    
    init(delegate: CardsViewContract) {
        interfaceController = delegate
        super.init()
        synth.delegate = self
        do {
            // keep app on the screen
            try sessionAudio.setCategory(AVAudioSession.Category.playback,
                                         mode: .spokenAudio,
                                         policy: .longForm,
                                         options: [])
        }
        catch let error {
            fatalError("*** Unable to set up the audio session: \(error.localizedDescription) ***")
        }
    }
    
    func playSpeech(doPlay: @escaping () -> Void, doStop: () -> Void) {
        // Activate and request the route.
        if mode == .idle {
            mode = .playing
            BG{
                self.sessionAudio.activate(options: [], completionHandler: { (_, error) in
                    guard error == nil else {
                        print("*** An error occurred: \(error!.localizedDescription) ***")
                        // Handle the error here.
                        UI{
                            self.mode = .idle
                            self.interfaceController.pause()
                        }
                        return
                    }
                    UI{
                       self.sayBothWords(side: self.currentSide)
                    }
                })
            }
            doPlay()
        }else{
            mode = .idle
            BG{
               UI{
                self.synth.stopSpeaking(at: .word)
               }
            }
            doStop()
            
        }
        
        
    }
    
    func sayBothWords(side: CardSide) {
        let card = interfaceController.getCurrentCard()
        var wordToSay = card.frontVal
        var voice = card.fromVoice()!
        
        if side == CardSide.BACK {
            wordToSay = card.backVal
            voice = card.toVoice()!
        }
        let utterance = AVSpeechUtterance(string: wordToSay)
        utterance.voice = voice
        
        synth.speak(utterance)
    }
    
    //MARK: - AVSpeechSynthesizerDelegate
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        mode = .idle
        interfaceController.pause()
    }
    
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        if mode == .idle {
            return
        }
        if currentSide == CardSide.FRONT {
            currentSide = CardSide.BACK
            Thread.sleep(forTimeInterval: PlayWordsTempo.SIDES.pause())
        } else {
            currentSide = CardSide.FRONT
            Thread.sleep(forTimeInterval: PlayWordsTempo.WORDS.pause())
            interfaceController.showNextCard()
        }
        sayBothWords(side: currentSide)
    }
}
