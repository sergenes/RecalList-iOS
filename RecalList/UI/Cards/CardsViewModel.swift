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

enum Direction {
    case FRONT
    case BACK
}

enum PlayWordsTempo: TimeInterval {
    case SIDES = 0.5, WORDS = 1.5

    func pause()-> TimeInterval{
        return self.rawValue
    }
}

protocol CardsScreenProtocol {
    func peepTranslation(index: Int)
    func markAsLearned(index: Int)
    func sayWord(index: Int)
    func getCardsCount() -> Int
    func getDirection() -> Int
}

// MARK: - Card is data model
public class Card {
    var index: Int
    var word: String
    var translation: String
    var from: String
    var to: String
    var peeped: Int = 10

    public init(index: Int, word: String, translation: String, from: String, to: String, peeped: Int) {
        self.index = index
        self.word = word
        self.translation = translation
        self.from = from
        self.to = to
        self.peeped = peeped
    }

    func fromVoice() -> AVSpeechSynthesisVoice? {
        if from.hasPrefix("Russian") {
            return AVSpeechSynthesisVoice(language: "ru-RU")
        } else if from.hasPrefix("Hebrew") {
            return AVSpeechSynthesisVoice(language: "he-IL")
        } else {
            return AVSpeechSynthesisVoice(language: "en-US")
        }
    }

    func toVoice() -> AVSpeechSynthesisVoice? {
        if to.hasPrefix("Russian") {
            return AVSpeechSynthesisVoice(language: "ru-RU")
        } else if to.hasPrefix("Hebrew") {
            return AVSpeechSynthesisVoice(language: "he-IL")
        } else {
            return AVSpeechSynthesisVoice(language: "en-US")
        }
    }
}

protocol SpeakerEventsDelegate {
    func done()
    func pause()
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

    init(selectedFile: GTLRDrive_File) {
        self.selectedFile = selectedFile
        super.init()
        wordsArray.removeAll()
        appAPI.requestCards(selectedFile: selectedFile, delegate: self)
        ObjcTools.setupAudioSession()
        synth.delegate = self
    }

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
