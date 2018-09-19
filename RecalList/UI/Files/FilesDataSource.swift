//
//  FilesDataSource.swift
//  RecalList
//
//  Created by Serge Nes on 9/19/18.
//  Copyright © 2018 Serge Nes. All rights reserved.
//
import UIKit

class FilesDataSource:NSObject, UITableViewDataSource{
    private var viewModel: FilesViewModel
    
    init(viewModel: FilesViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Table Data Source / count
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getFilesCount()
    }
    
    // MARK: - Table Data Source / View
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "fileInfoCell", for: indexPath) as UITableViewCell
        
        let file = viewModel.getFile(index: indexPath.row)
        // set the text from the data model
        cell.textLabel?.text = file.name!
        cell.detailTextLabel?.text = "\(file.modifiedTime!.stringValue)"
        return cell
    }
}
