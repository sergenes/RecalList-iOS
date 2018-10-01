//
//  CardsViewModel.swift
//  RecalList
//
//  Created by Serge Nes on 9/17/18.
//  Copyright © 2018 Serge Nes. All rights reserved.
//

import AVFoundation
import Koloda
import GoogleAPIClientForREST

protocol CardsScreenProtocol {
    func peepTranslation(index: Int)
    func markAsLearned(index: Int)
    func sayWord(index: Int)
    func getCardsCount() -> Int
    func getDirection() -> Int
}

class CardsViewModel: NSObject, CardsScreenProtocol, AppAPIServiceDelegate, AppAPIInjector, AVSpeechSynthesizerDelegate {
    var selectedSegmentIndex: Int = 0
    var currentCard = 0
    var currentWord = Direction.FRONT

    let synth = AVSpeechSynthesizer()
    let selectedFile: GTLRDrive_File
    var speakerEventsDelegate: SpeakerEventsDelegate? = nil

    // MARK: - AppAPIServiceDelegate
    internal var wordsArray: Array<Card> = []

    // MARK: - AppAPIServiceDelegate
    func appendCard(card: Card) {
        wordsArray.append(card)
    }
    
    func getData()->Array<Card>{
        return wordsArray
    }

    init(selectedFile: GTLRDrive_File) {
        self.selectedFile = selectedFile
        super.init()
        wordsArray.removeAll()
        appAPI.requestCards(selectedFile: selectedFile, delegate: self)
        ObjcTools.setupAudioSession()
        synth.delegate = self
    }

    // MARK: - AVSpeechSynthesizerDelegate
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        speakerEventsDelegate?.pause()
    }

    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {

        if currentWord == Direction.FRONT {
            currentWord = Direction.BACK
            Thread.sleep(forTimeInterval: PlayWordsTempo.SIDES.pause())
        } else {
            currentWord = Direction.FRONT
            if currentCard < wordsArray.count - 1 {
                currentCard = currentCard + 1
            } else {
                currentCard = 0
            }
            Thread.sleep(forTimeInterval: PlayWordsTempo.WORDS.pause())
            speakerEventsDelegate?.done()
        }
        sayBothWords(index: currentCard, direction: currentWord)
    }

    func sayBothWords(index: Int, direction: Direction) {
        if synth.delegate == nil {
            synth.delegate = self
        }
        currentCard = index

        let card = getCard(index: index)
        var wordToSay = card.word
        var voice = card.fromVoice()!

        if direction == Direction.BACK {
            wordToSay = card.translation
            voice = card.toVoice()!
        }
        let utterance = AVSpeechUtterance(string: wordToSay)
        utterance.voice = voice

        synth.speak(utterance)
    }

    func stop() {
        synth.stopSpeaking(at: .word)
        synth.delegate = nil
    }

    func getCard(index: Int) -> Card {
        return wordsArray[index]
    }

    func getCardByIndex(index: Int) -> Card? {
        for card in wordsArray {
            if card.index == index {
                return card
            }
        }
        return nil
    }

    func getFirstCard() -> Card {
        return wordsArray[0]
    }

    // MARK: - CardsScreenProtocol
    func sayWord(index: Int) {
        synth.delegate = nil
        guard let card = getCardByIndex(index: index) else {
            return
        }
        let utterance = AVSpeechUtterance(string: card.word)
        utterance.voice = card.fromVoice()!
        synth.speak(utterance)
    }

    // MARK: - CardsScreenProtocol
    func getCardsCount() -> Int {
        return wordsArray.count
    }

    // MARK: - CardsScreenProtocol
    func getDirection() -> Int {
        return selectedSegmentIndex
    }

    // MARK: - CardsScreenProtocol
    func peepTranslation(index: Int) {
        guard let card = getCardByIndex(index: index) else {
            return
        }
        card.peeped = card.peeped + 1
        appAPI.requestUpdateACard(card: card, selectedFile: selectedFile, delegate: self)
    }

    // MARK: - CardsScreenProtocol
    func markAsLearned(index: Int) {
        guard let card = getCardByIndex(index: index) else {
            return
        }
        if card.peeped == -1 {
            card.peeped = 0
        } else {
            card.peeped = -1
        }

        appAPI.requestMarkAsKnownACard(card: card, selectedFile: selectedFile, delegate: self)
    }
}
