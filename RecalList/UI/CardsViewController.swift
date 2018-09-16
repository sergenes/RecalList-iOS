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
import Koloda
import SVProgressHUD

class CardsViewController: UIViewController, KolodaViewDelegate, KolodaViewDataSource {
    
    class Card {
        var word : String?
        var translation: String?
        var from: String?
        var to: String?
        
        public init(word:String, translation:String, from:String, to:String){
            self.word = word
            self.translation = translation
            self.from = from
            self.to = to
        }
    }
    
    var selectedFile:GTLRDrive_File?
    
    private var wordsArray:Array<Card> = []
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var kolodaView: KolodaView!
    @IBOutlet weak var directionSegmentedControl: UISegmentedControl!
    
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        self.kolodaView.reloadData()
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        
    }
    
    func kolodaNumberOfCards(_ koloda:KolodaView) -> Int {
        return wordsArray.count
    }
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .fast
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        let card = wordsArray[index]
        let container:UIView = UIView()
        let cardView:CardView = CardView.fromNib()
        cardView.frame = CGRectMake(0,0,koloda.frame.width,koloda.frame.height - 150)
        
        if directionSegmentedControl.selectedSegmentIndex == 0 {
            cardView.frontLabel.text = card.word
            cardView.backLabel.text = card.translation
        }else{
            cardView.frontLabel.text = card.translation
            cardView.backLabel.text = card.word
        }
        
        if index % 2 == 0 {
            cardView.setColor(color: UIColor.init(netHex:0xb6caff))
        }else{
            cardView.setColor(color: UIColor.init(netHex:0xadf4ff))
        }
        
        cardView.countLabel.text = "\(index+1) of \(wordsArray.count)"
        cardView.doRoundCorners()

        container.addSubview(cardView)
        container.backgroundColor = UIColor(red:1,green:1,blue:1,alpha:0)
        
        return container
    }
    
    private let service = GTLRSheetsService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleLabel.text = selectedFile?.name

        self.service.authorizer = GIDSignIn.sharedInstance().currentUser.authentication.fetcherAuthorizer()

        if let spreadsheetId = selectedFile?.identifier {
            let range = "Phrasebook!A1:D"
            let query = GTLRSheetsQuery_SpreadsheetsValuesGet.query(withSpreadsheetId: spreadsheetId, range:range)
            service.executeQuery(query, delegate: self, didFinish:#selector(displayResultWithTicket(ticket:finishedWithObject:error:)))
        }
        
        kolodaView.dataSource = self
        kolodaView.delegate = self
        kolodaView.countOfVisibleCards = 3
        SVProgressHUD.show()
        
    }
    
    
    @IBAction func pressBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
     // MARK: - UISegmentedControl action
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        self.kolodaView.reloadData()
    }
    

    // MARK: - Google Service Spreadsheet callback
    @objc func displayResultWithTicket(ticket: GTLRServiceTicket,
                                     finishedWithObject result : GTLRSheets_ValueRange,
                                     error : NSError?) {
        if let error = error {
            showAlert(title: "Error", message: error.localizedDescription)
            return
        }
        
        let data = result.values!
        self.directionSegmentedControl.setTitle(data.first?[0] as? String, forSegmentAt: 0)
        self.directionSegmentedControl.setTitle(data.first?[1] as? String, forSegmentAt: 1)
        for row in data {
            let word : String = row[2] as! String
            let translation: String = row[3] as! String
            let from: String = row[0] as! String
            let to: String = row[1] as! String
            
            wordsArray.append(Card(word: word, translation: translation, from: from, to:to))
            
            print("\(row[0] as! String) : \(row[1] as! String) : \(row[2] as! String) : \(row[3] as! String)")
            
        }
        self.directionSegmentedControl.setTitle(wordsArray[0].from, forSegmentAt: 0)
        self.directionSegmentedControl.setTitle(wordsArray[0].to, forSegmentAt: 1)
        self.kolodaView.reloadData()
        
        SVProgressHUD.dismiss()
    }
}
