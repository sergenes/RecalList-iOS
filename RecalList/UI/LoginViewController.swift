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


class LoginViewController: UIViewController, GIDSignInUIDelegate {

    // MARK: - Google Sheets and Drive Services config
    private let scopes = [kGTLRAuthScopeSheetsDriveReadonly, kGTLRAuthScopeSheetsSpreadsheetsReadonly, kGTLRAuthScopeDrive]
    
    @IBOutlet weak var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance()?.scopes = scopes
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(receiveToggleAuthUINotification(_:)),
                                               name: .googleAuthUINotification,
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
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: .googleAuthUINotification,
                                                  object: nil)
    }
    
    // MARK: - Google GoogleSignIn callback
    @objc func receiveToggleAuthUINotification(_ notification: NSNotification) {
        if notification.equal(name:.googleAuthUINotification) {
            if notification.userInfo != nil {
                guard let userInfo = notification.userInfo as? [String:String] else { return }
                print("receiveToggleAuthUINotification: "+userInfo["statusText"]!)
                //wait until SFAuthenticationViewController from Google's lib will dissmissed
                BG {
                    while (self.presentedViewController != nil){
                        print("presentingViewController: \(String(describing: self.presentedViewController))")
                        sleep(1)
                    }
                    UI {
                        self.performSegue(withIdentifier: "segueShowFiles", sender: nil)
                    }
                }
            }else{
                showAlert(title: "Error", message: "Wrong email or password.")
            }
        }
    }
}
