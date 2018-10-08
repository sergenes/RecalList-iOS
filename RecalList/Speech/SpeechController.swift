//
//  SpeechController.swift
//  RecalList
//
//  Created by Serge Nes on 10/8/18.
//  Copyright © 2018 Serge Nes. All rights reserved.
//
import AVFoundation

enum SpeechMode {
    case ONE_WORD
    case PLAY_ALL_CARDS
    case STOPPED
}

class SpeechController:NSObject, AVSpeechSynthesizerDelegate{
    var currentCard = 0
    var currentSide = CardSide.FRONT
    var speechMode = SpeechMode.ONE_WORD
    
    let synth = AVSpeechSynthesizer()
    var cardsModel: CardsModelContract?
    
    override init() {
        super.init()
        ObjcTools.setupAudioSession()
        synth.delegate = self
    }
    
    func sayOneSide(card: Card) {
        speechMode = SpeechMode.ONE_WORD
        
        let utterance = AVSpeechUtterance(string: card.frontVal)
        utterance.voice = card.fromVoice()!
        synth.speak(utterance)
    }
    
    func sayBothSides(index: Int, side: CardSide) {
        if synth.delegate == nil {
            synth.delegate = self
        }
        currentCard = index
        
        let card = cardsModel!.getCard(index: index)
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
    
    func playSpeech() {
        speechMode = SpeechMode.PLAY_ALL_CARDS
        currentCard = cardsModel!.cardsView.getCurrentCardIndex()
        sayBothSides(index: currentCard, side: currentSide)
    }
    
    func stop() {
        speechMode = SpeechMode.STOPPED
        synth.stopSpeaking(at: .word)
    }
    
    func onDetach() {
        if synth.continueSpeaking() {
            synth.stopSpeaking(at: .immediate)
        }
        synth.delegate = nil
    }
    
    // MARK: - AVSpeechSynthesizerDelegate
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        cardsModel!.cardsView.pause()
    }
    
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        if speechMode != SpeechMode.PLAY_ALL_CARDS{
            return
        }
        if currentSide == CardSide.FRONT {
            currentSide = CardSide.BACK
            Thread.sleep(forTimeInterval: PlayWordsTempo.SIDES.pause())
        } else {
            currentSide = CardSide.FRONT
            if currentCard < cardsModel!.getCardsCount() - 1 {
                currentCard = currentCard + 1
            } else {
                currentCard = 0
            }
            Thread.sleep(forTimeInterval: PlayWordsTempo.WORDS.pause())
            cardsModel?.cardsView.showNextCard()
        }
        sayBothSides(index: currentCard, side: currentSide)
    }
}
