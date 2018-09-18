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
    
    @IBOutlet weak var signInButton: UIButton!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    
    @IBAction func pressLoginButton(_ sender: Any) {
        GIDSignIn.sharedInstance().uiDelegate = self
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(receiveToggleAuthUINotification(_:)),
                                               name: .googleAuthUINotification,
                                               object: nil)
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
                        self.appDelegate.appScreensManager?.showFiles()
//                        self.performSegue(withIdentifier: "segueShowFiles", sender: nil)
                    }
                }
            }else{
                showAlert(title: "Error", message: "Wrong email or password.")
            }
        }
    }
}
