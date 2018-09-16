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
import SVProgressHUD


class AuthViewController: UIViewController, GIDSignInUIDelegate {

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
        
        
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        if GIDSignIn.sharedInstance().hasAuthInKeychain() {
            SVProgressHUD.show()
            GIDSignIn.sharedInstance()?.signInSilently()
        }else{
            SVProgressHUD.dismiss()
        }
    }
    
    @IBAction func pressLoginButton(_ sender: Any) {
        SVProgressHUD.show()
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name(rawValue: "ToggleAuthUINotification"),
                                                  object: nil)
    }
    
    @objc func receiveToggleAuthUINotification(_ notification: NSNotification) {
        if notification.name.rawValue == "ToggleAuthUINotification" {
            if notification.userInfo != nil {
                guard let userInfo = notification.userInfo as? [String:String] else { return }
                print("receiveToggleAuthUINotification: "+userInfo["statusText"]!)
                SVProgressHUD.dismiss()
                
                self.performSegue(withIdentifier: "segueShowFiles", sender: nil)
            }else{
                SVProgressHUD.dismiss()
                showAlert(title: "Error", message: "Wrong email or password.")
            }
        }
    }
}

