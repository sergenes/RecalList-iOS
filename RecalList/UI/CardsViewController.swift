//
//  CardsViewController.swift
//  RecalList
//
//  Created by Serge Nes on 9/14/18.
//  Copyright © 2018 Serge Nes. All rights reserved.
//

import UIKit
import GoogleSignIn
import GoogleAPIClientForREST

class CardsViewController: UIViewController {
    
    private let service = GTLRSheetsService()

    @IBOutlet weak var output: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.service.authorizer = GIDSignIn.sharedInstance().currentUser.authentication.fetcherAuthorizer()

        
        let spreadsheetId = "1apdhKnDAO1gERYc867XDspl8DFKRyeVPRWqG6aM50Sg"
        let range = "Phrasebook!A1:D"
                        let query = GTLRSheetsQuery_SpreadsheetsValuesGet.query(withSpreadsheetId: spreadsheetId, range:range)
                        service.executeQuery(query, delegate: self, didFinish:#selector(displayResultWithTicket(ticket:finishedWithObject:error:)))
    }
    

    // Process the response and display output
        @objc func displayResultWithTicket(ticket: GTLRServiceTicket,
                                     finishedWithObject result : GTLRSheets_ValueRange,
                                     error : NSError?) {

        
        if let error = error {
            showAlert(title: "Error", message: error.localizedDescription)
            return
        }
        
        let data = result.values!
        for row in data {
            
            print("\(row[0] as! String) : \(row[1] as! String) : \(row[2] as! String) : \(row[3] as! String)")
            
        }
        
                var majorsString = ""
                let rows = result.values!
        
                if rows.isEmpty {
                    output.text = "No data found."
                    return
                }
        
                majorsString += "Name, Major:\n"
                for row in rows {
                    let name = row[2]
                    let major = row[3]
        
                    majorsString += "\(name), \(major)\n"
                }
        
                print(majorsString)
        
                output.text = majorsString
    }
    
    // Helper for showing an alert
    func showAlert(title : String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertController.Style.alert
        )
        let ok = UIAlertAction(
            title: "OK",
            style: UIAlertAction.Style.default,
            handler: nil
        )
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }

}
