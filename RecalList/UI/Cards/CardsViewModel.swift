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

// MARK: - Card is data model
public class Card {
    var index:Int
    var word : String
    var translation: String
    var from: String
    var to: String
    var peeped: Int = 10
    
    public init(index:Int, word:String, translation:String, from:String, to:String, peeped:Int){
        self.index = index
        self.word = word
        self.translation = translation
        self.from = from
        self.to = to
        self.peeped = peeped
    }
}

protocol SpeakerEventsDelegate {
    func done()
}

class CardsViewModel: NSObject, CardsScreenProtocol, AppAPIServiceDelegate, AppAPIInjector, AVSpeechSynthesizerDelegate {
    var selectedSegmentIndex:Int = 0
    var currentCard = 0
    var currentWord = 0
//    typealias CardsListReadyCompletion = (String) -> Void
//    
//    func cardsListReady(completion: @escaping CardsListReadyCompletion) {
//
//    }
    let synth = AVSpeechSynthesizer()
    let selectedFile:GTLRDrive_File
    var speakerEventsDelegate:SpeakerEventsDelegate? = nil
    
    // MARK: - AppAPIServiceDelegate
    internal var wordsArray:Array<Card> = []
    
    // MARK: - AppAPIServiceDelegate
    func appendCard(card:Card){
         wordsArray.append(card)
    }
        
    init(selectedFile:GTLRDrive_File) {
        self.selectedFile = selectedFile
        super.init()
        wordsArray.removeAll()
        appAPI.requestCards(selectedFile: selectedFile, delegate: self)
        ObjcTools.setupAudioSession()
        synth.delegate = self
    }
    
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance){
        
        if currentWord == 0 {
            currentWord = 1
            Thread.sleep(forTimeInterval: 0.5)
        }else {
            currentWord = 0
            if currentCard < wordsArray.count - 1 {
                currentCard = currentCard + 1
            }else{
                currentCard = 0
            }
            Thread.sleep(forTimeInterval:1.5)
            speakerEventsDelegate?.done()
        }
        sayBothWords(index: currentCard, direction: currentWord)
    }
    
    func sayBothWords(index: Int, direction:Int) {
        if synth.delegate == nil {
           synth.delegate = self
        }
        currentCard = index
        let card = getCard(index: index)
        var wordToSay = card.word
        var voice:AVSpeechSynthesisVoice!
        if card.from.hasPrefix("Russian") {
            voice = AVSpeechSynthesisVoice(language: "ru-RU")
        } else if card.from.hasPrefix("Hebrew") {
            voice = AVSpeechSynthesisVoice(language: "he-IL")
        } else{
             voice = AVSpeechSynthesisVoice(language: "en-US")
        }
        if direction==1 {
            wordToSay = card.translation
            if card.to.hasPrefix("Russian") {
                voice = AVSpeechSynthesisVoice(language: "ru-RU")
            } else if card.to.hasPrefix("Hebrew") {
                voice = AVSpeechSynthesisVoice(language: "he-IL")
            } else{
                voice = AVSpeechSynthesisVoice(language: "en-US")
            }
        }
        
        let utterance = AVSpeechUtterance(string: wordToSay)
        utterance.voice = voice
        
        synth.speak(utterance)
    }
    
    func stop(){
       synth.stopSpeaking(at: .word)
       synth.delegate = nil
    }
    
    func getCard(index:Int)->Card{
        return wordsArray[index]
    }
    
    func getCardByIndex(index:Int)->Card? {
        for card in wordsArray {
            if card.index == index {
                return card
            }
        }
        return nil
    }
    
    func getFirstCard()->Card {
        return wordsArray[0]
    }
    
    // MARK: - CardsScreenProtocol
    func sayWord(index: Int) {
        synth.delegate = nil
        guard let card = getCardByIndex(index: index) else { return }
        let utterance = AVSpeechUtterance(string: card.word)
        if card.from.hasPrefix("Russian") {
            utterance.voice = AVSpeechSynthesisVoice(language: "ru-RU")
        } else if card.from.hasPrefix("Hebrew") {
            utterance.voice = AVSpeechSynthesisVoice(language: "he-IL")
        } else{
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        }
        synth.speak(utterance)
    }
    
    // MARK: - CardsScreenProtocol
    func getCardsCount() -> Int {
        return wordsArray.count
    }
    
    // MARK: - CardsScreenProtocol
    func getDirection()->Int{
        return selectedSegmentIndex
    }
    
    // MARK: - CardsScreenProtocol
    func peepTranslation(index:Int){
        guard let card = getCardByIndex(index: index) else { return }
        card.peeped = card.peeped + 1
        appAPI.requestUpdateACard(card: card, selectedFile: selectedFile, delegate: self)
    }
    
    // MARK: - CardsScreenProtocol
    func markAsLearned(index: Int) {
        guard let card = getCardByIndex(index: index) else { return }
        card.peeped = -1
        appAPI.requestMarkAsKnownACard(card: card, selectedFile: selectedFile, delegate: self)
    }
}
