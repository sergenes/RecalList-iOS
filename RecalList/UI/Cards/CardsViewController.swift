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
import MediaPlayer
import WatchConnectivity

protocol CardsViewContract {
    func getSelectedFile() -> GTLRDrive_File
    func resetCards()
    func getCurrentCardIndex()->Int
    func showNextCard()
    func pause()
}

class CardsViewController: UIViewController, KolodaViewDelegate, CardsViewContract, WatchSyncManagerDelegate {
    
    var watchSyncManager: WatchSyncManager?
    var selectedFile:GTLRDrive_File?
    var cardsDataSource:CardsDataSource?
    
    @IBOutlet weak var syncButton: UIBarButtonItem!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var kolodaView: KolodaView!
    @IBOutlet weak var directionSegmentedControl: UISegmentedControl!
    @IBOutlet weak var playButton: UIBarButtonItem!

    lazy private var viewModel: CardsViewModel = {
        return CardsViewModel(cardsView: self)
    }()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        viewModel.detach()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        syncButton.isEnabled = false
        watchSyncManager = WatchSyncManager(delegate: self)

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

    @IBAction func pressSyncButton(_ sender: UIBarButtonItem) {
        SVProgressHUD.show()
        watchSyncManager?.sendData(cards:viewModel.getData(), name:selectedFile!.name!)
    }
    
    @IBAction func pressSourceButton(_ sender: UIBarButtonItem) {
        if sender.tag == 100 {
            sender.tag = 200
            sender.title = "headset"
            ObjcTools.chooseSource(1)
        }else{
            sender.tag = 100
            sender.title = "speaker"
            ObjcTools.chooseSource(0)
        }
    }
    
    @IBAction func pressPlayPouseButton(_ sender: UIBarButtonItem) {
        if sender.tag == 100 {
           sender.tag = 200
            sender.title = "stop"
            viewModel.playAll()
        }else{
            sender.title = "play"
            sender.tag = 100
            viewModel.stopAll()
        }
    }
    
    @IBAction func pressBack(_ sender: UIButton) {
        NotificationCenter.default.post(
            name: .actionNotification,
            object: Action.backFromCards,
            userInfo: nil)
    }
    
     // MARK: - UISegmentedControl action
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        viewModel.selectedSegmentIndex = sender.selectedSegmentIndex
        self.kolodaView.resetCurrentCardIndex()
    }
    
     // MARK: - KolodaViewDelegate
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        koloda.resetCurrentCardIndex()
        koloda.reloadData()
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        
    }
    
    // MARK: - CardsViewContract
    func resetCards(){
        self.kolodaView.resetCurrentCardIndex()
    }
    
    func getCurrentCardIndex()->Int{
        let index = self.kolodaView.currentCardIndex
        return index
    }
    
    func showNextCard(){
        self.kolodaView.swipe(.left, force: true)
    }
    
    func getSelectedFile() -> GTLRDrive_File {
        return selectedFile!
    }
    
    func pause() {
        pressPlayPouseButton(playButton)
    }
    
    // MARK: - WatchSyncManagerDelegate
    func watchActivated() {
        UI {
            self.syncButton.isEnabled = true
        }
    }
    
    func watchDeactivated(){
        UI {
            self.syncButton.isEnabled = false
        }
    }
    
    func dataSent(sync: Bool){
        UI {
            SVProgressHUD.dismiss()
            if !sync {
                //todo show error
            }
        }
    }
}
