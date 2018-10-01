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
}
//todo get updated peeks count from the watch
class WatchSyncManager: NSObject, WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Session activation did complete")
        delegate?.watchActivated()
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        print("session did become inactive")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        print("session did deactivate")
    }

    func sendData(cards:Array<Card>, name:String) {
        var dataArray: Array<Data> = []
        for c in cards {
            dataArray.append(c.jsonData)
        }
        let data:[String:Any] = ["com.nes.data":dataArray, "com.nes.name": name]
        do {
            try watchSession?.updateApplicationContext(data)
        } catch {
            print("Error sending dictionary \(data) to Apple Watch!")
        }
    }


    var delegate:WatchSyncManagerDelegate?
    fileprivate var watchSession: WCSession?

    deinit {

    }

    init(delegate:WatchSyncManagerDelegate) {
        super.init()
        self.delegate = delegate
        watchSession = WCSession.default
        watchSession?.delegate = self
        watchSession?.activate()
    }
}
