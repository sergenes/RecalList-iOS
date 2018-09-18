//
//  AppCoordinator.swift
//  RecalList
//
//  Created by Serge Nes on 9/16/18.
//  Copyright © 2018 Serge Nes. All rights reserved.
//

import UIKit
import SVProgressHUD
import GoogleSignIn

class Coordinator { }

class AppCoordinator {
    var launchStoryboard:UIStoryboard?
    var authStoryboard:UIStoryboard?
    var mainStoryboard:UIStoryboard?
    let window: UIWindow
    fileprivate let navigationController:UINavigationController
    fileprivate var childCoordinators = [Coordinator]()
    
    init(with window:UIWindow, navigationController:UINavigationController) {
        self.window = window
        self.navigationController = navigationController
    }
    
    deinit {
        print("deallocing \(self)")
    }
    
    func start() {
        launchStoryboard = UIStoryboard.init(name: "LaunchScreen", bundle: nil)
        
        let vc = launchStoryboard?.instantiateViewController(withIdentifier: "launchScreen")  
        window.rootViewController = vc
        window.makeKeyAndVisible()
        SVProgressHUD.show()
        
        BG {
            Thread.sleep(forTimeInterval: 2)
            if GIDSignIn.sharedInstance().hasAuthInKeychain() {
                GIDSignIn.sharedInstance()?.signInSilently()
            }else{
                self.showAuthentication()
            }
        }
    }
    
    fileprivate func showProfile() {
        
    }
    
    fileprivate func showAuthentication() {
        UI {
            self.authStoryboard = UIStoryboard.init(name: "Auth", bundle: nil)
            let lvc = self.authStoryboard?.instantiateViewController(withIdentifier: "loginViewController")
            self.window.rootViewController = lvc
            SVProgressHUD.dismiss()
        }
    }
    
}

