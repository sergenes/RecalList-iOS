//
//  AppCoordinator.swift
//  RecalList
//
//  Created by Serge Nes on 9/16/18.
//  Copyright © 2018 Serge Nes. All rights reserved.
//

import UIKit
import SVProgressHUD
import GoogleAPIClientForREST


enum Action {
    case loggedIn
    case loggedOut
    case fileSelected
    case backFromCards
}

class AppNavigator: NSObject, AppAPIInjector {
    fileprivate var window: UIWindow
    fileprivate let navigationController:UINavigationController
    
    init(with window:UIWindow) {
        self.window = window
        self.navigationController = UINavigationController()
        super.init()
        
        self.navigationController.navigationBar.isHidden = true
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.onActionReceived(_:)),
                                               name: .actionNotification,
                                               object: nil)
    }
    
    deinit {
        nprint("deallocing \(self)")
        NotificationCenter.default.removeObserver(self,
                                                  name: .googleAuthUINotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: .actionNotification,
                                                  object: nil)
    }
    
    func start() {
        nprint("start...")
        window.rootViewController = UIStoryboard.init(name: "LaunchScreen", bundle: nil)
            .instantiateViewController(withIdentifier: "launchScreen")
        window.makeKeyAndVisible()
        BG {
            Thread.sleep(forTimeInterval: 2)
            
            if self.appAPI.isSignedIn() {
                UI {
                    NotificationCenter.default.addObserver(self,
                                                           selector: #selector(self.receiveToggleAuthUINotification(_:)),
                                                           name: .googleAuthUINotification,
                                                           object: nil)
                    self.appAPI.requestSignInSilently()
                }
            }else{
                self.showAuthentication(error: nil)
            }
        }
        SVProgressHUD.show()
    }
    
    fileprivate func back() {
        self.navigationController.popViewController(animated: true)
    }
    
    fileprivate func afterLogOutNavigation(){
        let count = self.navigationController.viewControllers.count
        if  count < 2 || !(self.navigationController.viewControllers[count - 2] is LoginViewController) {
            let authStoryboard = UIStoryboard.init(name: "Auth", bundle: nil)
            let lvc:LoginViewController = authStoryboard.instantiateViewController(withIdentifier: "loginViewController") as! LoginViewController
            self.navigationController.viewControllers.insert(lvc, at: self.navigationController.viewControllers.count - 1)
        }
        self.navigationController.popViewController(animated: true)
    }
    
    fileprivate func showCards(file:GTLRDrive_File) {
        nprint("showCards...")
        UI {
            let mainStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
            let lvc = mainStoryboard.instantiateViewController(withIdentifier: "cardsViewController") as! CardsViewController
            lvc.selectedFile = file
            self.navigationController.show(lvc, sender: self)

            SVProgressHUD.dismiss()
        }
    }
    
    fileprivate func showFiles() {
        nprint("showFiles...")
        UI {
            let mainStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
            let lvc = mainStoryboard.instantiateViewController(withIdentifier: "filesViewController")
            
            if self.window.rootViewController is UINavigationController {
                self.navigationController.pushViewController(lvc, animated: true)
            }else{
                 let clvc = self.window.rootViewController
                UIView.transition(from:clvc!.view! , to: lvc.view!, duration: 1.0, options: .transitionCrossDissolve) {[unowned self] (finished) in
                    self.window.rootViewController = self.navigationController
                    self.navigationController.pushViewController(lvc, animated: false)
                }
            }
            
            SVProgressHUD.dismiss()
        }
    }
    
    fileprivate func showAuthentication(error:String?) {
        nprint("showAuthentication...")
        UI {
            let authStoryboard = UIStoryboard.init(name: "Auth", bundle: nil)
            let lvc:LoginViewController = authStoryboard.instantiateViewController(withIdentifier: "loginViewController") as! LoginViewController
            let clvc = self.window.rootViewController
            
            UIView.transition(from:clvc!.view! , to: lvc.view!, duration: 1.0, options: .transitionCrossDissolve) {[unowned self] (finished) in
               self.navigationController.pushViewController(lvc, animated: false)
               self.window.rootViewController = self.navigationController
                
                if error != nil {
                    self.window.rootViewController?.showAlert(title: "Auth Error", message: error!)
                }
            }

            SVProgressHUD.dismiss()
        }
    }
    
    // MARK: - Google GoogleSignIn callback
    @objc func receiveToggleAuthUINotification(_ notification: NSNotification) {
        if notification.equal(name:.googleAuthUINotification) {
            if notification.userInfo != nil {
                guard let userInfo = notification.userInfo as? [String:String] else { return }
                if let errorMessage = userInfo["Error"] {
                    self.showAuthentication(error: errorMessage)
                    return
                }
                print("receiveToggleAuthUINotification: "+userInfo["statusText"]!)
                self.showFiles()
            }else{
                showAuthentication(error: nil)
            }
        }
    }
    
    @objc func onActionReceived(_ notification: NSNotification) {
        if notification.equal(name:.actionNotification) {
            if notification.object != nil {
                guard let action = notification.object as? Action else { return }
                
                switch action {
                    case .loggedIn:
                        showFiles()
                        break
                    case .loggedOut:
                        afterLogOutNavigation()
                        break
                    case .fileSelected:
                        let file:GTLRDrive_File = notification.userInfo?["file"] as! GTLRDrive_File
                        showCards(file: file)
                        break
                    case .backFromCards:
                        back()
                }
                
            }
        }
    }
}

