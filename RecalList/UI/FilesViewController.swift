//
//  FilesViewController.swift
//  RecalList
//
//  Created by Serge Nes on 9/14/18.
//  Copyright © 2018 Serge Nes. All rights reserved.
//

import UIKit
import GoogleSignIn
import GoogleAPIClientForREST
import SVProgressHUD

class FilesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private var files:Array<GTLRDrive_File> = []
    private let serviceDrive = GTLRDriveService()
    private var selectedIndex:Int = 0
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.serviceDrive.authorizer = GIDSignIn.sharedInstance().currentUser.authentication.fetcherAuthorizer()
        
        self.emailLabel.text = GIDSignIn.sharedInstance().currentUser.profile.email
        
        SVProgressHUD.show()

        let query = GTLRDriveQuery_FilesList.query()
        query.pageSize = 10
        query.fields = "files"
        serviceDrive.executeQuery(query, delegate: self, didFinish:#selector(displayResultWithTicket(ticket:finishedWithObject:error:)))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueShowCards" {
            let vc = segue.destination as! CardsViewController
            vc.selectedFile = files[selectedIndex]
        }
    }
    
    
    @IBAction func pressLogout(_ sender: UIButton) {
        let refreshAlert = UIAlertController(title: "Logout", message: "Do you really want to logout from your Google account?", preferredStyle: .alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            
            SVProgressHUD.show()
            // go back to AuthViewController
            GIDSignIn.sharedInstance()?.signOut()
            
            self.dismiss(animated: true) {
                
                SVProgressHUD.dismiss()
            }
            
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
    
    // MARK: - Table Data Source / count
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }
    
    // MARK: - Table Data Source / View
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "fileInfoCell", for: indexPath) as UITableViewCell
        
        // set the text from the data model
        cell.textLabel?.text = files[indexPath.row].name!
        cell.detailTextLabel?.text = "\(files[indexPath.row].modifiedTime!.stringValue)"
        return cell
    }
    
    // MARK: - Table Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        self.selectedIndex = indexPath.row
        self.performSegue(withIdentifier: "segueShowCards", sender: nil)
    }
    
    // MARK: - Google Service Drive callback
    @objc func displayResultWithTicket(ticket: GTLRServiceTicket,
                                       finishedWithObject result : GTLRDrive_FileList,
                                       error : NSError?) {
        
        SVProgressHUD.dismiss()
        if let error = error {
            showAlert(title: "Error", message: error.localizedDescription)
            return
        }
        self.files.removeAll()
        let data = result.files!
        for row in data {
            let file:GTLRDrive_File = row
            if file.mimeType!.hasSuffix(".spreadsheet") {
               self.files.append(file)
            }
        }
        self.tableView.reloadData()
    }
}
