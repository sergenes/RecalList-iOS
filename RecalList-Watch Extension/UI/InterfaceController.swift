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

enum StorageKeys {
    static let storageNameKey = "com.nes.recallist.app"
    static let nameKey = "com.nes.data.name"
    static let arrayKey = "com.nes.data.array"
}

enum Mode {
    case idle
    case playing
}

class InterfaceController: WKInterfaceController, AVSpeechSynthesizerDelegate {
    let synth = AVSpeechSynthesizer()
    let sessionAudio = AVAudioSession.sharedInstance()
    
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
    
    internal var wordsArray: Array<Card> = []
    
    var currentWord = Direction.FRONT
    var currentCard = 0
    var mode = Mode.idle
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
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
            frontLabel.setText(wordsArray[0].word)
        }else{
            frontLabel.setText("There is no cards")
            counterLabel.setText("...")
        }
        
        watchSession = WCSession.default
        do {
            try sessionAudio.setCategory(AVAudioSession.Category.playback,
                                    mode: .default,
                                    policy: .longForm,
                                    options: [])
        }
        catch let error {
            fatalError("*** Unable to set up the audio session: \(error.localizedDescription) ***")
        }
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
        if currentWord == .FRONT {
            currentWord = .BACK
            peepButton.setTitle("back")
            frontLabel.setText(wordsArray[currentCard].translation)
        }else{
            currentWord = .FRONT
            peepButton.setTitle("peep")
            frontLabel.setText(wordsArray[currentCard].word)
        }
        
    }
    
    @IBAction func pressedPlayButton() {
        // Activate and request the route.
        if mode == .idle {
            mode = .playing
            playButton.setTitle("stop")
            sessionAudio.activate(options: [], completionHandler: { (_, error) in
                guard error == nil else {
                    print("*** An error occurred: \(error!.localizedDescription) ***")
                    // Handle the error here.
                    return
                }
                
                self.sayBothWords(index: self.currentCard, direction: self.currentWord)
            })
        }else{
            mode = .idle
            playButton.setTitle("play")
            synth.stopSpeaking(at: .word)
        }
        
        
    }
    
    // MARK: - AVSpeechSynthesizerDelegate
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        
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
            //speakerEventsDelegate?.done()
        }
        sayBothWords(index: currentCard, direction: currentWord)
    }
    
    func sayBothWords(index: Int, direction: Direction) {
        if synth.delegate == nil {
            synth.delegate = self
        }
        currentCard = index
        
        let card = wordsArray[currentCard]
        var wordToSay = card.word
        var voice = card.fromVoice()!
        
        if direction == Direction.BACK {
            wordToSay = card.translation
            voice = card.toVoice()!
        }
        let utterance = AVSpeechUtterance(string: wordToSay)
        utterance.voice = voice
        
        synth.speak(utterance)
        frontLabel.setText(wordsArray[currentCard].word)
        counterLabel.setText("\(currentCard + 1) of \(wordsArray.count)")
    }
}

extension InterfaceController: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Session activation did complete")
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("watch received app context: ", applicationContext)
        let sharedDefault = UserDefaults(suiteName: StorageKeys.storageNameKey)
        if let nameData = applicationContext[WatchProtocolKeys.nameKey] as? String {
           nameLabel.setText(nameData)
           sharedDefault?.set(nameData, forKey: StorageKeys.nameKey)
        }
        
        if let dataArray = applicationContext[WatchProtocolKeys.payloadKey] as? Array<Data> {
            sharedDefault?.set(dataArray, forKey: StorageKeys.arrayKey)
            sharedDefault?.synchronize()
            wordsArray.removeAll()
            for data in dataArray {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]{
                        wordsArray.append(Card(dictData: json))
                    }
                } catch {
                    print("error 111")
                }
            }
            if (wordsArray.count > 0){
                frontLabel.setText(wordsArray[0].word)
                counterLabel.setText("\(currentCard + 1) of \(wordsArray.count)")
                WKInterfaceDevice.current().play(.success)
               
                sendAK(session:session, dataOk: true)
            }else{
                 WKInterfaceDevice.current().play(.failure)
                frontLabel.setText("There is no cards")
                counterLabel.setText("...")
                sendAK(session:session, dataOk: false)
            }
            
        }
    }
    
    func sendAK(session: WCSession, dataOk:Bool){
//        do {
            //try session.updateApplicationContext([WatchProtocolKeys.confirmationKey:dataOk])
            
            watchSession?.sendMessage([WatchProtocolKeys.confirmationKey:dataOk], replyHandler: nil, errorHandler: { (error) -> Void in
                print("sendMessage to iPhone - OK!")
            })
//        } catch {
//            print("Error sending dictionary to iPhone!")
//        }
    }
}
