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

class FilesViewController: UIViewController {
    
    private let serviceDrive = GTLRDriveService()

    override func viewDidLoad() {
        super.viewDidLoad()
        
                self.serviceDrive.authorizer = GIDSignIn.sharedInstance().currentUser.authentication.fetcherAuthorizer()

        let query = GTLRDriveQuery_FilesList.query()
        query.pageSize = 5
        query.fields = "files"
        serviceDrive.executeQuery(query, delegate: self, didFinish:#selector(displayResultWithTicket(ticket:finishedWithObject:error:)))
    }
    
    
//    GTLRDrive_File 0x2824f1e30:
//    {viewedByMe:1
//    explicitlyTrashed:0
//    id:"1apdhKnDAO1gERYc867XDspl8DFKRyeVPRWqG6aM50Sg"
//    viewedByMeTime:"2018-09-15T02:46:54.623Z"
//    createdTime:"2018-09-14T21:43:45.111Z"
//    isAppAuthorized:0 owners:[1]
//    hasThumbnail:1 permissionIds?:[1] trashed:0 quotaBytesUsed:"0"
//    capabilities://{canListChildren,canAddChildren,canChangeViewersCanCopyContent,canCopy,canDownload,canMoveItemIn//toTeamDrive,canRename,canTrash,canComment,canShare,canRemoveChildren,canChangeCopyRequiresWriter//Permission,canDelete,canUntrash,canEdit,canReadRevisions}
//    parents:[1]
//    version:"7"
//    modifiedTime:"2018-09-14T21:43:46.352Z"
//    viewersCanCopyContent:1
//    spaces:[1]
//    permissions:[1]
//    writersCanShare:1
//    name:"Phrasebook"
//    iconLink:"https://drive-thirdparty.googleusercontent.com/16/type/application/vnd.google-//apps.spreadsheet"
//    copyRequiresWriterPermission?:0
//    lastModifyingUser:{emailAddress,me,kind,displayName,permissionId} ownedByMe:1
//    modifiedByMe:1 starred:0 shared:0 kind:"drive#file" mimeType:"application/vnd.google-apps.spreadsheet" modifiedByMeTime:"2018-09-14T21:43:46.352Z" thumbnailLink:"https://docs.google.com/feeds/vt?gd=true&id=1apdhKnDAO1gERYc867XDspl8DFKRyeVPRWqG6aM50Sg&v=1&s=AMedNnoAAAAAW5yT_pF4gQraTAYp3r2GSFtb7rgB-EUG&sz=s220" thumbnailVersion:"1" webViewLink:"https://docs.google.com/spreadsheets/d/1apdhKnDAO1gERYc867XDspl8DFKRyeVPRWqG6aM50Sg/edit?usp=drivesdk"}
    

    @objc func displayResultWithTicket(ticket: GTLRServiceTicket,
                                       finishedWithObject result : GTLRDrive_FileList,
                                       error : NSError?) {
        
        if let error = error {
            showAlert(title: "Error", message: error.localizedDescription)
            return
        }
        
        let data = result.files!
        for row in data {
            let file:GTLRDrive_File = row
            print(file.mimeType!)//application/vnd.google-apps.spreadsheet
            print(file.identifier!)
            print(file.modifiedTime!)
            print(file.name!)
            
            //            print("\(row[0] as! String) : \(row[1] as! String) : \(row[2] as! String) : \(row[3] as! String)")
            
        }
        self.performSegue(withIdentifier: "segueShowCards", sender: nil)
        
        //        var majorsString = ""
        //        let rows = result.values!
        //
        //        if rows.isEmpty {
        ////            output.text = "No data found."
        //            return
        //        }
        
        //        majorsString += "Name, Major:\n"
        //        for row in rows {
        //            let name = row[2]
        //            let major = row[3]
        //
        //            majorsString += "\(name), \(major)\n"
        //        }
        //
        //        print(majorsString)
        
        //        output.text = majorsString
    }
    
    // Helper for showing an alert
    func showAlert(title : String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertController.Style.alert
        )
        let ok = UIAlertAction(
            title: "OK",
            style: UIAlertAction.Style.default,
            handler: nil
        )
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }

}
