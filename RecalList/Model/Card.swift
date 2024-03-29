//
//  Card.swift
//  RecalList
//
//  Created by Serge Nes on 9/30/18.
//  Copyright © 2018 Serge Nes. All rights reserved.
//

import Foundation
import AVFoundation

public enum CardSide {
    case FRONT
    case BACK
}

public enum PlayWordsTempo: TimeInterval {
    case SIDES = 0.5, WORDS = 1.5
    
    func pause()-> TimeInterval{
        return self.rawValue
    }
}

public protocol SpeakerEventsDelegate {
    func done()
    func pause()
}

// MARK: - Card is data model
public class Card {
    var index: Int
    var frontVal: String
    var backVal: String
    var from: String
    var to: String
    var peeped: Int = 10
    
    var jsonString : String {
        let dict:[String : Any] = ["index" : index, "front" : frontVal, "back" : backVal, "from" : from, "to" : to, "peeped" : peeped]
        let data =  try! JSONSerialization.data(withJSONObject: dict, options: [])
        return String(data:data, encoding:.utf8)!
    }
    
    var jsonData : Data {
        let dict:[String : Any] = ["index" : index, "front" : frontVal, "back" : backVal, "from" : from, "to" : to, "peeped" : peeped]
        let data =  try! JSONSerialization.data(withJSONObject: dict, options: [])
        return data
    }
    
    public init(dictData:[String: Any]) {
            self.index = dictData["index" ] as! Int
            self.frontVal = dictData["front"] as! String
            self.backVal = dictData["back"] as! String
            self.from = dictData["from"] as! String
            self.to = dictData["to"] as! String
            self.peeped =  dictData["peeped" ] as! Int
    }
    
    public init(index: Int, front: String, back: String, from: String, to: String, peeped: Int) {
        self.index = index
        self.frontVal = front
        self.backVal = back
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
