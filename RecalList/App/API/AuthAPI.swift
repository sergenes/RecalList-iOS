//
//  AuthAPI.swift
//  RecalList
//
//  Created by Serge Nes on 9/19/18.
//  Copyright © 2018 Serge Nes. All rights reserved.
//

import GoogleSignIn
import GoogleAPIClientForREST

// MARK: - Google Sheets and Drive Services config
private let scopes = [kGTLRAuthScopeSheetsDrive, kGTLRAuthScopeSheetsSpreadsheets, kGTLRAuthScopeDrive]

extension AppAPI: GIDSignInDelegate{

    private func initGoogleSDK(){
        GIDSignIn.sharedInstance().clientID = Secrets.CLIENT_ID
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().scopes = scopes
    }

    func isSignedIn()->Bool {
        initGoogleSDK()
        return GIDSignIn.sharedInstance().hasAuthInKeychain()
    }

    func requestSignInSilently() {
        initGoogleSDK()
        GIDSignIn.sharedInstance()?.signInSilently()
    }

    func requestSignIn(uiDelegate:GIDSignInUIDelegate) {
        initGoogleSDK()
        GIDSignIn.sharedInstance().uiDelegate = uiDelegate
        GIDSignIn.sharedInstance()?.signIn()
    }

    func requestLogOut(){
        GIDSignIn.sharedInstance()?.signOut()
    }

    func getAccount()->GIDProfileData{
        return GIDSignIn.sharedInstance().currentUser.profile
    }

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
            NotificationCenter.default.post(
                name: .googleAuthUINotification,
                object: nil,
                userInfo: ["Error": error.localizedDescription])
        } else {
            nprint("didSignInFor \(String(describing: user.profile.email))")
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
