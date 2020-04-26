//
//  MyFilesVC.swift
//  FilesTeste
//
//  Created by Matheus Lima Ferreira on 4/25/20.
//  Copyright © 2020 Matheus Lima Ferreira. All rights reserved.
//

import MobileCoreServices

import UIKit

class MyFilesVC: UITableViewController {
    
    var listOfFiles = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "My Files"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        self.tabBarItem.image = UIImage(systemName: "house")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        configureNavButtons()
        getFilesName()
    }
    
    func getFilesName() {
        
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        
        var error: NSError? = nil
        NSFileCoordinator().coordinate(readingItemAt: url, error: &error) { (url) in
            
            let keys : [URLResourceKey] = [.nameKey, .isDirectoryKey]
            
            // Get an enumerator for the directory's content.
            guard let fileList =
                FileManager.default.enumerator(at: url, includingPropertiesForKeys: keys) else {
                    print("*** Unable to access the contents of \(url.path) ***\n")
                    return
            }
            
            for case let file as URL in fileList {
                // Also start accessing the content's security-scoped URL.
                //                guard url.startAccessingSecurityScopedResource() else {
                //                    // Handle the failure here.
                //                    continue
                //                }
                
                // Make sure you release the security-scoped resource when you are done.
                defer { url.stopAccessingSecurityScopedResource() }
                
                // Do something with the file here.
                
                listOfFiles.append(file.lastPathComponent)
            }
        }
    }
    
    func configureNavButtons() {
        let showDocumentsButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(showDocuments))
        navigationItem.rightBarButtonItem = showDocumentsButton
    }
    
    @objc func showDocuments() {
        let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypeItem as String], in: .import);
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        documentPicker.documentPickerMode
        present(documentPicker, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        
        cell.selectionStyle = .default
        
        cell.textLabel?.text = listOfFiles[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let file = listOfFiles[indexPath.row]
        let vc = ViewController()
         vc.sendFile(data: file)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfFiles.count
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            listOfFiles.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

///Document picker delegate
extension MyFilesVC: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFileURL = urls.first else { return }
        
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let sandboxFileURL = dir.appendingPathComponent(selectedFileURL.lastPathComponent)
        
//        print(sandboxFileURL.lastPathComponent)
        DispatchQueue.main.async {
            self.listOfFiles.append(sandboxFileURL.lastPathComponent)
            self.tableView.reloadData()
        }
    }
    
    
}



