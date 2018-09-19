//
//  FilesViewController.swift
//  RecalList
//
//  Created by Serge Nes on 9/14/18.
//  Copyright © 2018 Serge Nes. All rights reserved.
//

import UIKit
import GoogleAPIClientForREST
import SVProgressHUD

class FilesViewController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emailLabel: UILabel!
    var filesDataSource:FilesDataSource?
    
    lazy private var viewModel: FilesViewModel = {
        return FilesViewModel()
    }()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(dataSourceLoaded(_:)), name: .filesDownloadCompleted, object: nil)
        
        filesDataSource = FilesDataSource(viewModel: viewModel)
        
        self.emailLabel.text = viewModel.getAccountEmail()
        self.tableView.dataSource = filesDataSource
        
        SVProgressHUD.show()
    }
    
    @objc func dataSourceLoaded(_ notification: Notification) {
        if let error:NSError = notification.userInfo?["Error"] as? NSError {
            SVProgressHUD.dismiss()
            showAlert(title: "Error", message: error.localizedDescription)
            return
        }
        self.tableView.reloadData()
        SVProgressHUD.dismiss()
    }
    
    @IBAction func pressLogout(_ sender: UIButton) {
        let logoutAlert = UIAlertController(title: "Logout", message: "Do you really want to logout from your Google account?", preferredStyle: .alert)
        
        logoutAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            
            // go back to AuthViewController
            self.viewModel.requestLogOut()
            
            NotificationCenter.default.post(
                name: .actionNotification,
                object: Action.logedOut,
                userInfo: nil)
            
        }))
        
        logoutAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        
        present(logoutAlert, animated: true, completion: nil)
    }
    

    // MARK: - Table Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let file = self.viewModel.getFile(index:indexPath.row)
        NotificationCenter.default.post(
            name: .actionNotification,
            object: Action.fileSelected,
            userInfo: ["file":file])
    }
}
