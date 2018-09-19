//
//  FilesViewModel.swift
//  RecalList
//
//  Created by Serge Nes on 9/19/18.
//  Copyright © 2018 Serge Nes. All rights reserved.
//
import GoogleAPIClientForREST

class FilesViewModel: NSObject, AppAPIFilesDelegate, AppAPIInjector{
    var files:Array<GTLRDrive_File> = []
    
    override init() {
        super.init()
        files.removeAll()
        appAPI.requestListOfFiles(delegate: self)
    }
    
    func requestLogOut(){
        appAPI.requestLogOut()
    }
    
    // MARK: - AppAPIFilesDelegate
    func appendFile(file:GTLRDrive_File){
        files.append(file)
    }
    
    func getFile(index:Int)->GTLRDrive_File{
        return files[index]
    }
    
    func getFilesCount() -> Int {
        return files.count
    }
    
    func getAccountEmail()->String{
       return appAPI.getAccount().email
    }
}
