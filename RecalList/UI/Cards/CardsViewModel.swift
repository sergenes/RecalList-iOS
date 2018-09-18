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
import GoogleSignIn

// MARK: - Card is data model
public class Card {
    var index:Int
    var word : String
    var translation: String
    var from: String
    var to: String
    
    public init(index:Int, word:String, translation:String, from:String, to:String){
        self.index = index
        self.word = word
        self.translation = translation
        self.from = from
        self.to = to
    }
}

class CardsViewModel: NSObject, CardsScreenProtocol {
    private var selectedSegmentIndex:Int?
//    typealias CardsListReadyCompletion = (String) -> Void
//    
//    func cardsListReady(completion: @escaping CardsListReadyCompletion) {
//
//    }
    
    private var wordsArray:Array<Card> = []
    
    private let service = GTLRSheetsService()
    
    init(selectedFile:GTLRDrive_File) {
        super.init()
        self.service.authorizer = GIDSignIn.sharedInstance().currentUser.authentication.fetcherAuthorizer()
        
        if let spreadsheetId = selectedFile.identifier {
            let range = "Phrasebook!A1:D"
            let query = GTLRSheetsQuery_SpreadsheetsValuesGet.query(withSpreadsheetId: spreadsheetId, range:range)
            service.executeQuery(query, delegate: self, didFinish:#selector(displayResultWithTicket(ticket:finishedWithObject:error:)))
        }
    }
    
    func getCard(index:Int)->Card{
        return wordsArray[index]
    }
    
    func getFirstCard()->Card {
        return wordsArray[0]
    }
    
    // MARK: - CardsScreenProtocol
    func sayWord(index: Int) {
        let card = wordsArray[index]
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
        return selectedSegmentIndex!
    }
    
    let synth = AVSpeechSynthesizer()

    // MARK: - Google Service Spreadsheet callback
    @objc func displayResultWithTicket(ticket: GTLRServiceTicket,
                                       finishedWithObject result : GTLRSheets_ValueRange,
                                       error : NSError?) {
        if let error = error {
            NotificationCenter.default.post(name: .dataDownloadCompleted,
                                            object: nil,
                                            userInfo: ["Error": error])
            return
        }
        
        let data = result.values!
        for row in data {
            let word : String = row[2] as! String
            let translation: String = row[3] as! String
            let from: String = row[0] as! String
            let to: String = row[1] as! String
            
            wordsArray.append(Card(index: wordsArray.count,word: word, translation: translation, from: from, to:to))
            
            print("\(row[0] as! String) : \(row[1] as! String) : \(row[2] as! String) : \(row[3] as! String)")
            
            NotificationCenter.default.post(name: .dataDownloadCompleted,
                                            object: nil,
                                            userInfo: ["Message":"Ok"])
            
        }
    }
}
