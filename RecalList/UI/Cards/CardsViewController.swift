//
//  CardsViewController.swift
//  RecalList
//
//  Created by Serge Nes on 9/14/18.
//  Copyright © 2018 Serge Nes. All rights reserved.
//

import AVFoundation
import UIKit
import GoogleAPIClientForREST
import Koloda
import SVProgressHUD


class CardsViewController: UIViewController, KolodaViewDelegate {
    
    var selectedFile:GTLRDrive_File?
    var cardsDataSource:CardsDataSource?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var kolodaView: KolodaView!
    @IBOutlet weak var directionSegmentedControl: UISegmentedControl!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    lazy private var viewModel: CardsViewModel = {
        return CardsViewModel(selectedFile: self.selectedFile!)
    }()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(dataSourceLoaded(_:)), name: .dataDownloadCompleted, object: nil)
        
        self.titleLabel.text = selectedFile?.name

        cardsDataSource = CardsDataSource(viewModel: viewModel)
        kolodaView.dataSource = cardsDataSource
        kolodaView.delegate = self
        kolodaView.countOfVisibleCards = 3
        viewModel.selectedSegmentIndex = 0
        SVProgressHUD.show()  
    }
    
    @objc func dataSourceLoaded(_ notification: Notification) {
        if let error:NSError = notification.userInfo?["Error"] as? NSError {
            SVProgressHUD.dismiss()
            showAlert(title: "Error", message: error.localizedDescription)
            return
        }
        
        self.directionSegmentedControl.setTitle(viewModel.getFirstCard().from, forSegmentAt: 0)
        self.directionSegmentedControl.setTitle(viewModel.getFirstCard().to, forSegmentAt: 1)
        self.kolodaView.reloadData()
        
        SVProgressHUD.dismiss()
    }
    
    @IBAction func pressBack(_ sender: UIButton) {
        appDelegate.appScreensManager?.back()
    }
    
     // MARK: - UISegmentedControl action
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        viewModel.selectedSegmentIndex = sender.selectedSegmentIndex
        self.kolodaView.resetCurrentCardIndex()
    }
    
     // MARK: - KolodaViewDelegate
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        koloda.reloadData()
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        
    }
}
