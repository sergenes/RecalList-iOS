//
//  InterfaceController+SessionDelegate.swift
//  RecalList-Watch Extension
//
//  Created by Serge Nes on 10/8/18.
//  Copyright © 2018 Serge Nes. All rights reserved.
//

import WatchConnectivity
import WatchKit

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
            currentCard = 0
            currentSide = CardSide.FRONT
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
                frontLabel.setText(wordsArray[0].frontVal)
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
        watchSession?.sendMessage([WatchProtocolKeys.confirmationKey:dataOk], replyHandler: nil, errorHandler: { (error) -> Void in
            print("sendMessage to iPhone - OK!")
        })
    }
}
