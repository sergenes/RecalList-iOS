//
//  WatchSyncManager.swift
//  RecalList
//
//  Created by Serge Nes on 10/1/18.
//  Copyright © 2018 Serge Nes. All rights reserved.
//

import UIKit
import WatchConnectivity

protocol WatchSyncManagerDelegate {
    func watchActivated()
    func watchDeactivated()
    func dataSent(sync:Bool)
}
//todo get updated peeks count from the watch
class WatchSyncManager: NSObject, WCSessionDelegate {
    func sessionReachabilityDidChange(_ session: WCSession) {
        print("sessionReachabilityDidChange ")
    }

    func session(_ session: WCSession, didFinish userInfoTransfer: WCSessionUserInfoTransfer, error: Error?) {
        print("userInfoTransfer ")
    }

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        print("didReceiveUserInfo ")
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        print("didReceiveMessage ")
        let response = message[WatchProtocolKeys.confirmationKey] as? Bool ?? false
        delegate?.dataSent(sync: response)
    }

    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        print("didReceiveMessageData 1")
    }

    func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
        print("didReceiveMessageData 2")
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Session activation did complete")
        delegate?.watchActivated()
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        print("session did become inactive")
        delegate?.watchDeactivated()
    }

    func sessionDidDeactivate(_ session: WCSession) {
        print("session did deactivate")
        delegate?.watchDeactivated()
    }
    
    func sessionWatchStateDidChange(_ session: WCSession){
        print("sessionWatchStateDidChange")
        if WCSession.isSupported() && watchSession?.activationState != .activated {
            watchSession?.activate()
        }
    }

    
   func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]){
        print("didReceiveApplicationContext")

    }

    func sendData(cards:Array<Card>, name:String) {
        var dataArray: Array<Data> = []
        for c in cards {
            dataArray.append(c.jsonData)
        }
        let data:[String:Any] = [WatchProtocolKeys.payloadKey:dataArray, WatchProtocolKeys.nameKey: name]
        do {
            try watchSession?.updateApplicationContext(data)
        } catch {
            print("Error sending dictionary \(data) to Apple Watch!")
        }
    }


    var delegate:WatchSyncManagerDelegate?
    fileprivate var watchSession: WCSession?

    deinit {
        watchSession?.delegate = nil
        delegate = nil
        
    }

    init(delegate:WatchSyncManagerDelegate) {
        super.init()
        
        self.delegate = delegate
        watchSession = WCSession.default
        print("WatchSyncManager - init()")
        watchSession?.delegate = self
        if watchSession?.activationState == .activated {
            print("WatchSyncManager - init(1)")
            delegate.watchActivated()
        }else{
            print("WatchSyncManager - init(2)")
            watchSession?.activate()
        }
        
    }
}
