//
//  ViewController.swift
//  RecalList
//
//  Created by Serge Nes on 9/14/18.
//  Copyright © 2018 Serge Nes. All rights reserved.
//

import UIKit
import GoogleSignIn
import GoogleAPIClientForREST

class ViewController: UIViewController, GIDSignInUIDelegate {

    private let scopes = [kGTLRAuthScopeSheetsDriveReadonly, kGTLRAuthScopeSheetsSpreadsheetsReadonly, kGTLRAuthScopeDrive]
    
    private let service = GTLRSheetsService()
    private let serviceDrive = GTLRDriveService()
    
    @IBOutlet weak var signInButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance()?.scopes = scopes
        
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(receiveToggleAuthUINotification(_:)),
                                               name: NSNotification.Name(rawValue: "ToggleAuthUINotification"),
                                               object: nil)
        
        if GIDSignIn.sharedInstance().hasAuthInKeychain() {
            GIDSignIn.sharedInstance()?.signInSilently()

        }else{
            
        }
        
        
    }
    
    @IBAction func pressLoginButton(_ sender: Any) {
        
        GIDSignIn.sharedInstance()?.signIn()
    }


    func toggleAuthUI() {
        if GIDSignIn.sharedInstance().hasAuthInKeychain() {
            // Signed in
            signInButton.isHidden = true
//            signOutButton.isHidden = false
//            disconnectButton.isHidden = false
        } else {
            signInButton.isHidden = false
//            signOutButton.isHidden = true
//            disconnectButton.isHidden = true
//            statusText.text = "Google Sign in\niOS Demo"
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name(rawValue: "ToggleAuthUINotification"),
                                                  object: nil)
    }
    
    @objc func receiveToggleAuthUINotification(_ notification: NSNotification) {
        if notification.name.rawValue == "ToggleAuthUINotification" {
//            self.toggleAuthUI()
            if notification.userInfo != nil {
                guard let userInfo = notification.userInfo as? [String:String] else { return }
//                self.statusText.text = userInfo["statusText"]!
                print("receiveToggleAuthUINotification: "+userInfo["statusText"]!)
                
                self.performSegue(withIdentifier: "segueShowFiles", sender: nil)
                
//                self.service.authorizer = GIDSignIn.sharedInstance().currentUser.authentication.fetcherAuthorizer()
//                self.serviceDrive.authorizer = GIDSignIn.sharedInstance().currentUser.authentication.fetcherAuthorizer()
//
//                let spreadsheetId = "1apdhKnDAO1gERYc867XDspl8DFKRyeVPRWqG6aM50Sg"
//                let range = "Phrasebook!A1:D"
////                let query = GTLRSheetsQuery_SpreadsheetsValuesGet.query(withSpreadsheetId: spreadsheetId, range:range)
////                service.executeQuery(query, delegate: self, didFinish:#selector(displayResultWithTicket(ticket:finishedWithObject:error:)))
//
////                let query = GTLRSheetsQuery_SpreadsheetsGet.query(withSpreadsheetId: spreadsheetId)
////                service.executeQuery(query, delegate: self, didFinish:#selector(displayResultWithTicket(ticket:finishedWithObject:error:)))
//
//               let query = GTLRDriveQuery_FilesList.query()
//                query.pageSize = 5
//                query.fields = "files"
//                serviceDrive.executeQuery(query, delegate: self, didFinish:#selector(displayResultWithTicket(ticket:finishedWithObject:error:)))
                
            }
        }
    }
    
//    // Process the response and display output
////    @objc func displayResultWithTicket(ticket: GTLRServiceTicket,
////                                 finishedWithObject result : GTLRSheets_ValueRange,
////                                 error : NSError?) {
//    @objc func displayResultWithTicket(ticket: GTLRServiceTicket,
//                                       finishedWithObject result : GTLRDrive_FileList,
//                                       error : NSError?) {
//
//        if let error = error {
//            showAlert(title: "Error", message: error.localizedDescription)
//            return
//        }
//
//        let data = result.files!
//        for row in data {
//            print(row)
//
////            print("\(row[0] as! String) : \(row[1] as! String) : \(row[2] as! String) : \(row[3] as! String)")
//
//        }
//
////        var majorsString = ""
////        let rows = result.values!
////
////        if rows.isEmpty {
//////            output.text = "No data found."
////            return
////        }
//
////        majorsString += "Name, Major:\n"
////        for row in rows {
////            let name = row[2]
////            let major = row[3]
////
////            majorsString += "\(name), \(major)\n"
////        }
////
////        print(majorsString)
//
////        output.text = majorsString
//    }
//
//    // Helper for showing an alert
//    func showAlert(title : String, message: String) {
//        let alert = UIAlertController(
//            title: title,
//            message: message,
//            preferredStyle: UIAlertController.Style.alert
//        )
//        let ok = UIAlertAction(
//            title: "OK",
//            style: UIAlertAction.Style.default,
//            handler: nil
//        )
//        alert.addAction(ok)
//        present(alert, animated: true, completion: nil)
//    }
}

