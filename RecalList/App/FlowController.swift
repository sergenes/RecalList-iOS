//
//  FlowController.swift
//  RecalList
//
//  Created by Serge Nes on 9/17/18.
//  Copyright © 2018 Serge Nes. All rights reserved.
//

import Foundation
import GoogleAPIClientForREST

extension Notification.Name {
    static let dataDownloadCompleted = Notification.Name(
        rawValue: "com.nes.dataDownloadCompleted")
}

protocol AppFlowProtocol {
    var selectedFile:GTLRDrive_File {get set}
    var wordsArray:Array<Card> {get set}
}

protocol FileScreenProtocol:AppFlowProtocol{
    
}

protocol CardsScreenProtocol{
    func sayWord(index:Int)
    func getCardsCount()->Int
    func getDirection()->Int
}

class FlowController {
    
    // MARK: - Properties
    
    static let shared = FlowController()

    fileprivate var selectedFile:GTLRDrive_File?
    
    fileprivate var wordsArray:Array<Card> = []
    
    // Initialization
    
    private init() {
        
    }
}

