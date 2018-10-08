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

protocol CardsModelContract {
    var cardsView:CardsViewContract {get}
    func peepTranslation(index: Int)
    func markAsLearned(index: Int)
    func getCardsCount() -> Int
    func getCard(index: Int) -> Card
    func getCardSide() -> Int
    func getCurrentCard() -> Int
    func sayPressed(index: Int)
    func playAll()
    func stopAll()
    func detach()
}

class CardsViewModel:NSObject, CardsModelContract, AppAPIServiceDelegate, AppAPIInjector {

    let speechController:SpeechController
    let cardsView: CardsViewContract
    
    var selectedSegmentIndex: Int = 0

    internal var wordsArray: Array<Card> = []
    
    func getData()->Array<Card>{
        return wordsArray
    }

    init(cardsView:CardsViewContract) {
        self.cardsView = cardsView
        self.speechController = SpeechController()
        super.init()
        
        wordsArray.removeAll()
        appAPI.requestCards(selectedFile: cardsView.getSelectedFile(), delegate: self)
        self.speechController.cardsModel = self
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
    
    // MARK: - CardsModelContract
    func getCurrentCard() -> Int {
        return cardsView.getCurrentCardIndex()
    }
    
    func sayPressed(index: Int){
        let card = getCard(index: index)
        speechController.sayOneSide(card: card)
    }
    
    func playAll(){
        speechController.playSpeech()
    }
    
    func stopAll(){
        speechController.stop()
    }
    
    func getCard(index: Int) -> Card {
        return wordsArray[index]
    }

    func getCardsCount() -> Int {
        return wordsArray.count
    }

    func getCardSide() -> Int {
        return selectedSegmentIndex
    }

    func peepTranslation(index: Int) {
        guard let card = getCardByIndex(index: index) else {
            return
        }
        card.peeped = card.peeped + 1
        appAPI.requestUpdateACard(card: card, selectedFile: cardsView.getSelectedFile(), delegate: self)
    }

    func markAsLearned(index: Int) {
        guard let card = getCardByIndex(index: index) else {
            return
        }
        if card.peeped == -1 {
            card.peeped = 0
        } else {
            card.peeped = -1
        }

        appAPI.requestMarkAsKnownACard(card: card, selectedFile: cardsView.getSelectedFile(), delegate: self)
    }
    
    func detach(){
        speechController.onDetach()
    }
    
    
    // MARK: - AppAPIServiceDelegate
    func appendCard(card: Card) {
        wordsArray.append(card)
    }
}
