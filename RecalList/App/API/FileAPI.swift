//
//  FileAPI.swift
//  RecalList
//
//  Created by Serge Nes on 9/19/18.
//  Copyright © 2018 Serge Nes. All rights reserved.
//
import GoogleSignIn
import GoogleAPIClientForREST

protocol AppAPIFilesDelegate:AppAPIDelegate {
    func appendFile(file:GTLRDrive_File)
}

extension AppAPI {
    
    func requestListOfFiles(delegate:AppAPIDelegate){
        self.delegate = delegate
        let serviceDrive = GTLRDriveService()
        serviceDrive.authorizer = GIDSignIn.sharedInstance().currentUser.authentication.fetcherAuthorizer()
        
        
        let query = GTLRDriveQuery_FilesList.query()
        query.pageSize = 10
        query.fields = "files"
        serviceDrive.executeQuery(query, delegate: self, didFinish:#selector(filesResultWithTicket(ticket:finishedWithObject:error:)))
    }
    
    // MARK: - Google Service Drive callback
    @objc func filesResultWithTicket(ticket: GTLRServiceTicket,
                                       finishedWithObject result : GTLRDrive_FileList,
                                       error : NSError?) {
        if let error = error {
            NotificationCenter.default.post(name: .filesDownloadCompleted,
                                            object: nil,
                                            userInfo: ["Error": error])
            return
        }
        let data = result.files!
        for row in data {
            let file:GTLRDrive_File = row
            if file.mimeType!.hasSuffix(".spreadsheet") {
                (self.delegate as! AppAPIFilesDelegate).appendFile(file:file)
            }
        }
        NotificationCenter.default.post(name: .filesDownloadCompleted,
                                        object: nil,
                                        userInfo: ["Message":"Ok"])
    }
}
