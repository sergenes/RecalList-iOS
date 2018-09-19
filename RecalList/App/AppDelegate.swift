//
//  AppDelegate.swift
//  RecalList
//
//  Created by Serge Nes on 9/14/18.
//  Copyright © 2018 Serge Nes. All rights reserved.
//

import UIKit
import GoogleSignIn
import GoogleAPIClientForREST

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    // MARK: - Google Sheets and Drive Services config
    private let scopes = [kGTLRAuthScopeSheetsDriveReadonly, kGTLRAuthScopeSheetsSpreadsheetsReadonly, kGTLRAuthScopeDrive]
    
    var window: UIWindow?
    var appScreensManager:AppNavigator?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        appScreensManager = AppNavigator(with: window!)
        
        // Initialize sign-in
        GIDSignIn.sharedInstance().clientID = Secrets.CLIENT_ID
        GIDSignIn.sharedInstance().delegate = self //todo on abstract Authentication manager
        GIDSignIn.sharedInstance().scopes = scopes
        
        appScreensManager?.start()
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url as URL?,
                                                 sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                                                 annotation: options[UIApplication.OpenURLOptionsKey.annotation])
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        nprint("didSignInFor \(String(describing: user.profile.email))")
        if let error = error {
            print("\(error.localizedDescription)")
        } else {
            // Perform any operations on signed in user here.
            //let userId:String = user.userID                  // For client-side use only!
            //let idToken:String = user.authentication.idToken // Safe to send to the server
            let fullName:String = user.profile.name
            //let givenName:String = user.profile.givenName//
            //let familyName:String = user.profile.familyName
            //let email:String = user.profile.email
            
           //print(userId)
           //print(idToken)
           //print(fullName)
           //print(givenName)
           //print(familyName)
           //print(email)
            
            NotificationCenter.default.post(
                name: .googleAuthUINotification,
                object: nil,
                userInfo: ["statusText": "Signed in user:\n\(fullName)"])
            
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        print("didDisconnectWith \(String(describing: user.profile.email))")
        
    }

}

