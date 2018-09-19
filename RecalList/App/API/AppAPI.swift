//
//  AppAPI.swift
//  RecalList
//
//  Created by Serge Nes on 9/19/18.
//  Copyright © 2018 Serge Nes. All rights reserved.
//

import GoogleSignIn
import GoogleAPIClientForREST

protocol AppAPIInjector {
    var appAPI: AppAPI { get }
}

extension AppAPIInjector {
    var appAPI: AppAPI {
        return shared
    }
}

fileprivate let shared = AppAPI()

protocol AppAPIDelegate {}

protocol AppAPIServiceDelegate:AppAPIDelegate {
    func appendCard(card:Card)
}

class AppAPI: NSObject {
    private let scopes = [kGTLRAuthScopeSheetsDrive, kGTLRAuthScopeSheetsSpreadsheets, kGTLRAuthScopeDrive]
    private let service = GTLRSheetsService()
    var delegate:AppAPIDelegate?
    
    fileprivate override init() {
        super.init()
    }
    
    func requestCards(selectedFile:GTLRDrive_File, delegate:AppAPIDelegate) {
        self.delegate = delegate
        self.service.authorizer = GIDSignIn.sharedInstance().currentUser.authentication.fetcherAuthorizer()
        
        if let spreadsheetId = selectedFile.identifier {
            let range = "Phrasebook!A1:E"
            let query = GTLRSheetsQuery_SpreadsheetsValuesGet.query(withSpreadsheetId: spreadsheetId, range:range)
            service.executeQuery(query, delegate: self, didFinish:#selector(displayResultWithTicket(ticket:finishedWithObject:error:)))
        }
    }
    
    func requestUpdateACard(card:Card, selectedFile:GTLRDrive_File, delegate:AppAPIDelegate) {
        self.delegate = delegate
        self.service.authorizer = GIDSignIn.sharedInstance().currentUser.authentication.fetcherAuthorizer()
        
        if let spreadsheetId = selectedFile.identifier {
            let cardIndex:Int = card.index+1
            let range = "Phrasebook!E\(cardIndex):E\(cardIndex)"
            let valueRange = GTLRSheets_ValueRange()
            valueRange.range = "Phrasebook!E\(cardIndex):E\(cardIndex)"
            valueRange.values = [["\(card.peeped)"]]
            valueRange.majorDimension = "COLUMNS"
            
            let query = GTLRSheetsQuery_SpreadsheetsValuesUpdate.query(withObject: valueRange, spreadsheetId: spreadsheetId, range:range)
            query.valueInputOption = "USER_ENTERED"
            service.executeQuery(query, delegate: self, didFinish:#selector(updateCallbackWithTicket(ticket:finishedWithObject:error:)))
        }
    }
    
    // MARK: - Google Service update Spreadsheet callback
    @objc func updateCallbackWithTicket(ticket: GTLRServiceTicket,
                                       finishedWithObject result : GTLRSheets_ValueRange,
                                       error : NSError?) {
        if let error = error {
            NotificationCenter.default.post(name: .googleUpdateNotification,
                                            object: nil,
                                            userInfo: ["Error": error])
            return
        }
        
        NotificationCenter.default.post(name: .googleUpdateNotification,
                                        object: nil,
                                        userInfo: ["Message":"Ok"])
        
    }
    
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
        var cards:Array<Card> = []
        for row in data {
            let word : String = row[2] as! String
            let translation: String = row[3] as! String
            let from: String = row[0] as! String
            let to: String = row[1] as! String
            var peeped:Int = 0
            if row.count == 5 {
               peeped = Int(row[4] as! String) ?? 0
            }
            
            cards.append(Card(index: cards.count, word: word, translation: translation, from: from, to:to, peeped: peeped))
        }
        cards = cards.sorted(by: { $0.peeped > $1.peeped })
        for card in cards{
           (self.delegate as! AppAPIServiceDelegate).appendCard(card:card)
        }
        //        nprint("\(result)")
        NotificationCenter.default.post(name: .dataDownloadCompleted,
                                        object: nil,
                                        userInfo: ["Message":"Ok"])
    }

}
