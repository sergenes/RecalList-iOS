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
    static let filesDownloadCompleted = Notification.Name(
        rawValue: "com.nes.filesDownloadCompleted")
    static let actionNotification = Notification.Name(
        rawValue: "com.nes.actionNotification")
    static let googleAuthUINotification = Notification.Name(
        rawValue: "ToggleAuthUINotification")
    static let googleUpdateNotification = Notification.Name(
        rawValue: "googleUpdateNotification")
}

extension NSNotification {
    func equal(name:Notification.Name)->Bool{
        return self.name.rawValue == name.rawValue
    }
}

protocol CardsScreenProtocol{
    func peepTranslation(index:Int)
    func sayWord(index:Int)
    func getCardsCount()->Int
    func getDirection()->Int
}

protocol FlowControllerInjector {
    var flowController: FlowController { get }
}

extension FlowControllerInjector {
    var flowController: FlowController {
        return shared
    }
}

fileprivate let shared = FlowController()

class FlowController {
    

}

