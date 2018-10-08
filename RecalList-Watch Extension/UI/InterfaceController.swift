//
//  InterfaceController.swift
//  RecalList-Watch Extension
//
//  Created by Serge Nes on 9/20/18.
//  Copyright © 2018 Serge Nes. All rights reserved.
//

import WatchKit
import Foundation
import AVFoundation
import WatchConnectivity

func BG(_ block: @escaping ()->Void) {
    DispatchQueue.global(qos: .default).async(execute: block)
}

func UI(_ block: @escaping ()->Void) {
    DispatchQueue.main.async(execute: block)
}

enum StorageKeys {
    static let storageNameKey = "com.nes.recallist.app"
    static let nameKey = "com.nes.data.name"
    static let arrayKey = "com.nes.data.array"
}

protocol CardsViewContract {
    func getCurrentCard()->Card
    func showNextCard()
    func pause()
}

class InterfaceController: WKInterfaceController, WKCrownDelegate, CardsViewContract {
    var speechController:SpeechController?
    var watchSession: WCSession? {
        didSet {
            if let session = watchSession {
                session.delegate = self
                session.activate()
            }
        }
    }
    @IBOutlet weak var nameLabel: WKInterfaceLabel!
    @IBOutlet weak var counterLabel: WKInterfaceLabel!
    
    @IBOutlet weak var frontLabel: WKInterfaceLabel!
    @IBOutlet weak var peepButton: WKInterfaceButton!
    @IBOutlet weak var playButton: WKInterfaceButton!
    
    
    @IBOutlet weak var cardContainer: WKInterfaceGroup!
    @IBOutlet weak var fixFullScreenBug: WKInterfaceSKScene!
    @IBOutlet weak var mainContainer: WKInterfaceGroup!
    @IBOutlet weak var toolBarContainer: WKInterfaceGroup!
    
    var wordsArray: Array<Card> = []
    
    var currentSide = CardSide.FRONT
    var currentCard = 0
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        speechController = SpeechController(delegate: self)
        
        let device = WKInterfaceDevice.current()
        let bounds = device.screenBounds
        let height = bounds.height
        let width = bounds.width
        mainContainer.setWidth(width)
        mainContainer.setHeight(height)
        mainContainer.setVerticalAlignment(.top)
        mainContainer.setHorizontalAlignment(.left)
        toolBarContainer.setWidth(width)
        cardContainer.setHeight(height - (18 + 38 + 38))
        
        
        let sharedDefault = UserDefaults(suiteName: StorageKeys.storageNameKey)
        if let nameData = sharedDefault?.string(forKey: StorageKeys.nameKey) {
            nameLabel.setText(nameData)
        }
        if let dataArray = sharedDefault?.array(forKey: StorageKeys.arrayKey) as? Array<Data> {
            for data in dataArray {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]{
                        wordsArray.append(Card(dictData: json))
                    }
                } catch {
                    print("error 111")
                    return
                }
            }
            counterLabel.setText("\(currentCard + 1) of \(wordsArray.count)")
            frontLabel.setText(wordsArray[0].frontVal)
        }else{
            frontLabel.setText("There is no cards")
            counterLabel.setText("...")
        }
        
        watchSession = WCSession.default
        crownSequencer.delegate = self
    }
    
    override func didAppear() {
        crownSequencer.focus()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @IBAction func pressedPeepButton() {
        flipCard()
    }
    
    func flipCard() {
        if currentSide == .FRONT {
            currentSide = .BACK
            wordsArray[currentCard].peeped += 1
            
            peepButton.setTitle("back")
            frontLabel.setText(wordsArray[currentCard].backVal)
        }else{
            currentSide = .FRONT
            peepButton.setTitle("peep")
            frontLabel.setText(wordsArray[currentCard].frontVal)
        }
    }
    
    @IBAction func pressedPlayButton() {
        speechController?.playSpeech(doPlay: {
            self.playButton.setTitle("stop")
        }, doStop:{
            self.playButton.setTitle("play")
        })
    }
    
    @IBAction func tapUpdated(_ sender: WKTapGestureRecognizer) {
        showNextCard()
    }
    
    //MARK: CardsViewContract
    func showNextCard(){
        if currentCard < wordsArray.count - 1 {
            currentCard = currentCard + 1
        } else {
            currentCard = 0
        }
        frontLabel.setText(wordsArray[currentCard].frontVal)
        counterLabel.setText("\(currentCard + 1) of \(wordsArray.count)")
    }
    
    func getCurrentCard() -> Card {
        let card = wordsArray[currentCard]
        return card
    }
    
    func pause(){
        self.playButton.setTitle("stop")
    }
    
    //MARK: crownSequencer Delegates
    func crownDidRotate(_ crownSequencer: WKCrownSequencer?, rotationalDelta: Double) {
        //        value += rotationalDelta
        //        let rps = (crownSequencer?.rotationsPerSecond)!
        if (abs(rotationalDelta) > 0.05) {
            showNextCard()
        }
        print(rotationalDelta)
    }
}
